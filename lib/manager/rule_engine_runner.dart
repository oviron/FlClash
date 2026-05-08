// Runtime dispatcher for the rule engine.
//
// Two safeguards on top of `evaluate` so flaky networks do not toggle
// the VPN repeatedly:
//   * dedup — if the desired state already equals the current VPN state,
//     no dispatch happens (also keeps the cooldown disarmed for noops).
//   * cooldown — after every actual turnOn/turnOff a 10 second window
//     defers the opposite action, so a brief drop and reconnect cannot
//     start-stop-start the core.
//
// Flipping the master toggle off resets the cooldown so a future re-enable
// starts from a clean slate instead of inheriting stale state.

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
  static const _cooldown = Duration(seconds: 10);

  DateTime? _lastAutoActionAt;
  NetworkAction? _lastDispatchedAction;
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    // React on any of the three inputs the engine depends on. ref.listen
    // fires after build, so this is safe to register eagerly.
    ref.listenManual(currentNetworkSnapshotProvider, (_, _) => _evaluate());
    ref.listenManual(networkRulesStreamProvider, (_, _) => _evaluate());
    ref.listenManual(networkRulesSettingsProvider, (prev, next) {
      // Master toggle flipped to off: drop cooldown so a future re-enable
      // starts from a clean slate.
      if (prev?.enabled == true && next.enabled == false) {
        _lastAutoActionAt = null;
        _lastDispatchedAction = null;
      }
      _evaluate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _evaluate() async {
    // Reentrancy guard: appController.updateStatus can take seconds
    // (handleStart spins up the core), and during that await another
    // listener (drift batch from reorder, rapid network change) could
    // fire and re-enter _evaluate. Drop the second call rather than
    // race the first one.
    if (_evaluating) return;
    _evaluating = true;
    try {
      final settings = ref.read(networkRulesSettingsProvider);
      if (!settings.enabled) {
        return;
      }

      final rules = ref.read(networkRulesStreamProvider).value ?? const [];
      final snap = ref.read(currentNetworkSnapshotProvider);

      final action = evaluate(rules: rules, snapshot: snap);

      // No rule matched. Do nothing; no fallback, no cooldown arming.
      if (action == null) {
        return;
      }

      // The redesigned UI never produces NetworkAction.keep, but legacy
      // persisted rules from before may still carry it. Treat as null
      // (no opinion) so we do nothing rather than fight the user.
      if (action == NetworkAction.keep) {
        return;
      }

      final desiredOn = action == NetworkAction.turnOn;
      final isOn = ref.read(isStartProvider);
      final snapDescr = _describeSnapshot(snap);

      if (desiredOn == isOn) {
        _log(
          'action ${action.name} equals current state, skip ($snapDescr)',
        );
        return;
      }

      if (_isCoolingDown(action)) {
        final remaining = _cooldownRemaining();
        _log(
          'cooldown active (${remaining}s remaining), deferring ${action.name} '
          '($snapDescr)',
        );
        return;
      }

      final reason = _matchReason(rules, snap);
      _log('$reason, action=${action.name} -> ${desiredOn ? "starting" : "stopping"} VPN');

      try {
        await appController.updateStatus(desiredOn);
        if (!mounted) return;
        _lastAutoActionAt = DateTime.now();
        _lastDispatchedAction = action;
      } catch (e) {
        if (!mounted) return;
        _log('dispatch failed for ${action.name}: $e');
      }
    } finally {
      _evaluating = false;
    }
  }

  bool _isCoolingDown(NetworkAction next) {
    final last = _lastAutoActionAt;
    final lastAction = _lastDispatchedAction;
    if (last == null || lastAction == null) return false;
    if (DateTime.now().difference(last) >= _cooldown) return false;
    // Cooldown only matters when we are about to flip in the opposite
    // direction. Same-direction repeats are caught by dedup before this.
    return next != lastAction;
  }

  int _cooldownRemaining() {
    final last = _lastAutoActionAt;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last);
    final remaining = _cooldown - elapsed;
    if (remaining.isNegative) return 0;
    return remaining.inSeconds;
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
