// Debounce, not cooldown: Wi-Fi↔cellular handovers fire bursts and a
// cooldown would silently drop the final stable state.

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/engine.dart';
import 'package:fl_clash/providers/network_rules.dart';
import 'package:fl_clash/providers/network_rules_settings.dart';
import 'package:fl_clash/providers/network_state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RuleEngineRunner extends ConsumerStatefulWidget {
  final Widget child;

  const RuleEngineRunner({super.key, required this.child});

  @override
  ConsumerState<RuleEngineRunner> createState() => _RuleEngineRunnerState();
}

class _RuleEngineRunnerState extends ConsumerState<RuleEngineRunner> {
  static const _debounceWindow = Duration(seconds: 2);

  Timer? _debounce;
  bool _dispatching = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(currentNetworkSnapshotProvider, (_, _) => _schedule());
    ref.listenManual(networkRulesStreamProvider, (_, _) => _schedule());
    ref.listenManual(networkRulesSettingsProvider, (_, _) => _schedule());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(_debounceWindow, _dispatch);
  }

  Future<void> _dispatch() async {
    if (_dispatching) return;
    if (!mounted) return;
    _dispatching = true;
    try {
      final settings = ref.read(networkRulesSettingsProvider);
      if (!settings.enabled) return;

      final rules = ref.read(networkRulesStreamProvider).value ?? const [];
      final snap = ref.read(currentNetworkSnapshotProvider);

      final action = evaluate(rules: rules, snapshot: snap);
      if (action == null) return;
      // Legacy data may still carry NetworkAction.keep. The redesigned
      // UI never produces it, but old persisted rows do. Treat as no
      // opinion rather than coercing the VPN either way.
      if (action == NetworkAction.keep) return;

      final desiredOn = action == NetworkAction.turnOn;
      final isOn = ref.read(isStartProvider);
      final snapDescr = _describeSnapshot(snap);

      if (desiredOn == isOn) {
        _log('action ${action.name} equals current state, skip ($snapDescr)');
        return;
      }

      final reason = _matchReason(rules, snap);
      _log(
        '$reason, action=${action.name} -> '
        '${desiredOn ? "starting" : "stopping"} VPN',
      );

      try {
        await appController.updateStatus(desiredOn);
      } catch (e) {
        if (!mounted) return;
        _log('dispatch failed for ${action.name}: $e');
      }
    } finally {
      _dispatching = false;
    }
  }

  String _matchReason(List<NetworkRule> rules, NetworkSnapshot snap) {
    final ordered = [...rules]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    for (final rule in ordered) {
      if (!rule.enabled) continue;
      if (rule.conditions.isEmpty) continue;
      final allMatch = rule.conditions.every((c) => c.matches(snap));
      if (allMatch) {
        final label = (rule.name == null || rule.name!.isEmpty)
            ? 'anonymous#${rule.id}'
            : rule.name!;
        return "matched rule '$label' on ${_describeSnapshot(snap)}";
      }
    }
    return 'no rule matched on ${_describeSnapshot(snap)}';
  }

  String _describeSnapshot(NetworkSnapshot snap) {
    switch (snap.type) {
      case NetworkType.wifi:
        return snap.ssid != null ? 'wifi:${snap.ssid}' : 'wifi:<unknown>';
      case NetworkType.cellular:
        return 'cellular';
      case NetworkType.none:
        return 'none';
    }
  }

  void _log(String message) {
    if (!mounted) return;
    final line = 'network-rules: $message';
    commonPrint.log(line);
    ref.read(logsProvider.notifier).addLog(Log.app(line));
  }
}
