// Debounce, not cooldown: Wi-Fi↔cellular handovers fire bursts and a
// cooldown would silently drop the final stable state.

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/manager/effects/network_rule_effect.dart';
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
  bool _pendingDispatch = false;

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
    if (_dispatching) {
      _pendingDispatch = true;
      return;
    }
    if (!mounted) return;
    _dispatching = true;
    _pendingDispatch = false;
    try {
      final settings = ref.read(networkRulesSettingsProvider);
      if (!settings.enabled) return;

      final rules = ref.read(networkRulesStreamProvider).value ?? const [];
      final snap = ref.read(currentNetworkSnapshotProvider);
      final decision = decideNetworkRuleDispatch(
        enabled: settings.enabled,
        rules: rules,
        snapshot: snap,
        isOn: ref.read(isStartProvider),
      );

      if (!decision.shouldDispatch) {
        if (decision.shouldLog) {
          _log(decision.message);
        }
        return;
      }

      final action = decision.action;
      if (action == null) return;
      final desiredOn = action == NetworkAction.turnOn;
      _log(decision.message);

      try {
        await appController.updateStatus(desiredOn);
      } catch (e) {
        if (!mounted) return;
        _log('dispatch failed for ${action.name}: $e');
      }
    } finally {
      _dispatching = false;
      if (mounted && _pendingDispatch) {
        _debounce = Timer(_debounceWindow, _dispatch);
      }
    }
  }

  void _log(String message) {
    if (!mounted) return;
    final line = 'network-rules: $message';
    commonPrint.log(line);
    ref.read(logsProvider.notifier).addLog(Log.app(line));
  }
}
