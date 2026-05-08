// Network Rules v1: runtime dispatcher.
//
// Subscribes to the live network snapshot, the persisted rules list, and
// the master settings (enabled + fallback). On any change it runs the pure
// engine and dispatches the resulting NetworkAction to the existing VPN
// machinery via appController.updateStatus.
//
// Two safeguards keep the dispatcher well-behaved on flaky networks:
//   * dedup: if the desired state already equals the current VPN state we
//     skip the call entirely.
//   * cooldown: a 10 second window after every dispatched turnOn/turnOff
//     during which the opposite action is deferred. Same-direction noops
//     (caught by dedup) do not arm the cooldown.
//
// Master toggle: when networkRulesSettings.enabled is false the runner
// becomes a noop — providers keep updating so the UI still works, but no
// dispatch happens and the cooldown is reset so a re-enable starts clean.

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
    final settings = ref.read(networkRulesSettingsProvider);
    if (!settings.enabled) {
      return;
    }

    final rules = ref.read(networkRulesStreamProvider).value ?? const [];
    final snap = ref.read(currentNetworkSnapshotProvider);

    final action = evaluate(
      rules: rules,
      snapshot: snap,
      fallback: settings.fallback,
    );

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

    final reason = _matchReason(rules, snap, settings.fallback);
    _log('$reason, action=${action.name} -> ${desiredOn ? "starting" : "stopping"} VPN');

    try {
      await appController.updateStatus(desiredOn);
      _lastAutoActionAt = DateTime.now();
      _lastDispatchedAction = action;
    } catch (e) {
      _log('dispatch failed for ${action.name}: $e');
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

  String _matchReason(
    List<NetworkRule> rules,
    NetworkSnapshot snap,
    NetworkAction fallback,
  ) {
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
    return 'no rule matched on ${_describeSnapshot(snap)}, '
        'fallback=${fallback.name}';
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
    final line = 'network-rules: $message';
    commonPrint.log(line);
    ref.read(logsProvider.notifier).addLog(Log.app(line));
  }
}
