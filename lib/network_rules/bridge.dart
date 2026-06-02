// Bridges Dart rule state to the resident Kotlin service: writes the rules
// mirror on every change, starts/stops the service with the master toggle, and
// feeds the service's pushed status back into providers for the editor. Replaces
// the old in-UI RuleEngineRunner, which died whenever the UI was backgrounded.

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/network_rules/mirror.dart';
import 'package:fl_clash/network_rules/plugin.dart';
import 'package:fl_clash/providers/network_rules.dart';
import 'package:fl_clash/providers/network_rules_settings.dart';
import 'package:fl_clash/providers/network_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkRulesBridge extends ConsumerStatefulWidget {
  final Widget child;

  const NetworkRulesBridge({super.key, required this.child});

  @override
  ConsumerState<NetworkRulesBridge> createState() => _NetworkRulesBridgeState();
}

class _NetworkRulesBridgeState extends ConsumerState<NetworkRulesBridge> {
  static const _plugin = NetworkRulesPlugin();
  bool? _lastEnabled;

  @override
  void initState() {
    super.initState();
    _plugin.setStatusHandler(_onStatus);
    ref.listenManual(networkRulesStreamProvider, (_, _) => _onRulesChanged());
    ref.listenManual(
      networkRulesSettingsProvider,
      (_, _) => _onSettingsChanged(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    _plugin.clearStatusHandler();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final settings = ref.read(networkRulesSettingsProvider);
    _lastEnabled = settings.enabled;
    await _writeMirror();
    if (settings.enabled) {
      await _plugin.setEnabled(true);
      final status = await _plugin.getStatus();
      if (status != null) _onStatus(status);
    }
  }

  Future<void> _writeMirror() async {
    final settings = ref.read(networkRulesSettingsProvider);
    final rules = ref.read(networkRulesStreamProvider).value ?? const [];
    final json = encodeNetworkRulesMirror(
      enabled: settings.enabled,
      defaultAction: settings.defaultAction,
      rules: rules,
    );
    await writeNetworkRulesMirror(await appPath.homeDirPath, json);
  }

  Future<void> _onRulesChanged() async {
    await _writeMirror();
    if (ref.read(networkRulesSettingsProvider).enabled) {
      await _plugin.reevaluate();
    }
  }

  Future<void> _onSettingsChanged() async {
    final enabled = ref.read(networkRulesSettingsProvider).enabled;
    await _writeMirror();
    final wasEnabled = _lastEnabled;
    _lastEnabled = enabled;
    if (wasEnabled != enabled) {
      await _plugin.setEnabled(enabled);
    } else if (enabled) {
      await _plugin.reevaluate();
    }
  }

  void _onStatus(NetworkRuleStatus status) {
    if (!mounted) return;
    ref.read(currentNetworkSnapshotProvider.notifier).update(status.snapshot);
    ref.read(lastNetworkRuleStatusProvider.notifier).update(status);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
