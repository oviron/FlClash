// Dart side of the network-rules bridge. The resident Kotlin service owns the
// decision; this just toggles it on/off, pushes rule changes, and surfaces the
// service's latest status for the editor. Channel name mirrors
// NetworkRulesPlugin.kt; method names live in lib/plugins/method_names.dart.

import 'package:fl_clash/network_rules/engine.dart';
import 'package:fl_clash/plugins/method_names.dart';
import 'package:flutter/services.dart';

class NetworkRuleStatus {
  final NetworkSnapshot snapshot;
  final NetworkDecision decision;
  final String reason;
  final bool overridden;

  const NetworkRuleStatus({
    required this.snapshot,
    required this.decision,
    required this.reason,
    required this.overridden,
  });
}

class NetworkRulesPlugin {
  const NetworkRulesPlugin();

  static const _channel = MethodChannel('com.follow.clash/network_rules');

  Future<void> setEnabled(bool enabled) =>
      _channel.invokeMethod(NetworkRulesMethod.setEnabled, enabled);

  Future<void> reevaluate() =>
      _channel.invokeMethod(NetworkRulesMethod.reevaluate);

  Future<NetworkRuleStatus?> getStatus() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      NetworkRulesMethod.getStatus,
    );
    return raw == null ? null : _parse(raw);
  }

  void setHandlers({
    required void Function(NetworkRuleStatus status) onStatus,
    required void Function(int profileId) onSwitchProfile,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case NetworkRulesMethod.statusChanged:
          onStatus(_parse((call.arguments as Map).cast<String, dynamic>()));
        case NetworkRulesMethod.switchProfile:
          onSwitchProfile(call.arguments as int);
      }
      return null;
    });
  }

  void clearHandlers() => _channel.setMethodCallHandler(null);

  /// Visible for testing. Maps the resident's status payload to Dart.
  static NetworkRuleStatus parseStatus(Map<String, dynamic> map) =>
      const NetworkRulesPlugin()._parse(map);

  NetworkRuleStatus _parse(Map<String, dynamic> map) {
    return NetworkRuleStatus(
      snapshot: _snapshot(map['type'] as String?, map['ssid'] as String?),
      decision: _decision(map['decision'] as String?),
      reason: (map['reason'] as String?) ?? '',
      overridden: (map['overridden'] as bool?) ?? false,
    );
  }

  NetworkSnapshot _snapshot(String? type, String? ssid) {
    switch (type) {
      case 'WIFI':
        return NetworkSnapshot.wifi(ssid: ssid);
      case 'CELLULAR':
        return const NetworkSnapshot.cellular();
      case 'ETHERNET':
        return const NetworkSnapshot.ethernet();
      default:
        return const NetworkSnapshot.none();
    }
  }

  NetworkDecision _decision(String? value) {
    switch (value) {
      case 'START':
        return NetworkDecision.start;
      case 'STOP':
        return NetworkDecision.stop;
      default:
        return NetworkDecision.leaveAsIs;
    }
  }
}
