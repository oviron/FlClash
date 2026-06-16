// Bridges Dart rule state to the resident Kotlin service: writes the mirror on
// every change, toggles the service with the master switch, and feeds pushed
// status back into providers for the editor.

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/network_rules/mirror.dart';
import 'package:fl_clash/network_rules/plugin.dart';
import 'package:fl_clash/providers/config.dart';
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
    _plugin.setHandlers(onStatus: _onStatus, onSwitchProfile: _onSwitchProfile);
    ref.listenManual(networkRulesStreamProvider, (_, _) => _onRulesChanged());
    ref.listenManual(
      networkRulesSettingsProvider,
      (_, _) => _onSettingsChanged(),
    );
    // Keep activeProfileId fresh in the mirror so the resident can tell a manual
    // profile switch from its own. No reevaluate: a manual switch must not make
    // the engine immediately re-apply.
    ref.listenManual(currentProfileIdProvider, (_, _) => _writeMirror());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    _plugin.clearHandlers();
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
    // Bake the cache (writes <id>.yaml files) BEFORE publishing the mirror that
    // references them, so the resident never reads a rule whose config is absent.
    final profileIds = <int>{
      for (final r in rules)
        if (r.enabled && r.action.profileId != null) r.action.profileId!,
    };
    final entries = await appController.rebuildNetworkRulesCache(profileIds);
    final json = encodeNetworkRulesMirror(
      enabled: settings.enabled,
      defaultAction: settings.defaultAction,
      rules: rules,
      selectedMaps: {
        for (final e in entries.entries) e.key: e.value.selectedMap,
      },
      profileNames: {for (final e in entries.entries) e.key: e.value.name},
      activeProfileId: ref.read(currentProfileIdProvider),
    );
    await writeNetworkRulesMirror(await appPath.homeDirPath, json);
  }

  // Engine asked (Flutter alive) for a profile switch: route it through the
  // app's own machinery so currentProfile + config + UI stay coherent, rather
  // than the resident swapping config.yaml behind Dart's back.
  void _onSwitchProfile(int profileId) {
    if (ref.read(currentProfileIdProvider) == profileId) return;
    ref.read(currentProfileIdProvider.notifier).value = profileId;
    appController.applyProfileDebounce(force: true);
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
