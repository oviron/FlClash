// Network Rules v1: data model.
//
// Domain types for the auto-on/off VPN feature. We deliberately use
// NetworkRule / NetworkAction / NetworkCondition prefixes because the
// existing fl_clash codebase already has a `Rule` type in
// lib/models/clash_config.dart for clash routing rules and reusing the
// same name would force every consumer to alias one of them.

import 'dart:convert';

import 'package:fl_clash/common/common.dart';

/// What the rule engine should do when a rule matches the current network.
enum NetworkAction {
  /// Switch the VPN on.
  turnOn,

  /// Switch the VPN off.
  turnOff,

  /// Do nothing, leave the VPN as it is.
  keep,
}

/// Convenience alias kept for callers that import from this file directly
/// and do not want to spell out NetworkAction. The engine_test currently
/// references `Action.keep`.
typedef Action = NetworkAction;

/// What kind of network the device is currently on.
enum NetworkType { wifi, cellular, none }

/// Snapshot of the current network state. Created by the probe on every
/// connectivity change and fed into the engine.
class NetworkSnapshot {
  final NetworkType type;

  /// Wi-Fi SSID. Only meaningful when type == wifi. Can be null even on
  /// Wi-Fi if the OS denied us ACCESS_FINE_LOCATION or returned the
  /// Android stub `<unknown ssid>`.
  final String? ssid;

  const NetworkSnapshot._(this.type, this.ssid);

  const NetworkSnapshot.wifi({this.ssid}) : type = NetworkType.wifi;

  const NetworkSnapshot.cellular()
    : type = NetworkType.cellular,
      ssid = null;

  const NetworkSnapshot.none() : type = NetworkType.none, ssid = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkSnapshot && other.type == type && other.ssid == ssid;

  @override
  int get hashCode => Object.hash(type, ssid);

  @override
  String toString() => 'NetworkSnapshot(type: $type, ssid: $ssid)';
}

/// A single match clause. Multiple conditions on a rule are combined with AND.
sealed class NetworkCondition {
  const NetworkCondition();

  /// Returns true when this condition matches the given snapshot.
  bool matches(NetworkSnapshot snapshot);

  Map<String, dynamic> toJson();

  static NetworkCondition fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String?;
    switch (kind) {
      case 'wifi_named':
        return WifiNamed(json['ssid'] as String);
      case 'any_wifi':
        return const AnyWifi();
      case 'any_cellular':
        return const AnyCellular();
      default:
        throw FormatException(
          'Unknown NetworkCondition kind: $kind in $json',
        );
    }
  }
}

/// Matches when the current network is a Wi-Fi with the exact SSID
/// (case-insensitive). If the snapshot has no SSID (no permission or
/// Android stub), this condition does NOT match — the engine moves on.
class WifiNamed extends NetworkCondition {
  final String ssid;

  const WifiNamed(this.ssid);

  @override
  bool matches(NetworkSnapshot snapshot) {
    if (snapshot.type != NetworkType.wifi) return false;
    final candidate = snapshot.ssid;
    if (candidate == null) return false;
    return candidate.toLowerCase() == ssid.toLowerCase();
  }

  @override
  Map<String, dynamic> toJson() => {'kind': 'wifi_named', 'ssid': ssid};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiNamed && other.ssid.toLowerCase() == ssid.toLowerCase();

  @override
  int get hashCode => ssid.toLowerCase().hashCode;

  @override
  String toString() => 'WifiNamed($ssid)';
}

/// Matches any Wi-Fi network regardless of SSID.
class AnyWifi extends NetworkCondition {
  const AnyWifi();

  @override
  bool matches(NetworkSnapshot snapshot) =>
      snapshot.type == NetworkType.wifi;

  @override
  Map<String, dynamic> toJson() => const {'kind': 'any_wifi'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnyWifi;

  @override
  int get hashCode => 'any_wifi'.hashCode;

  @override
  String toString() => 'AnyWifi()';
}

/// Matches any cellular (mobile data) network.
class AnyCellular extends NetworkCondition {
  const AnyCellular();

  @override
  bool matches(NetworkSnapshot snapshot) =>
      snapshot.type == NetworkType.cellular;

  @override
  Map<String, dynamic> toJson() => const {'kind': 'any_cellular'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnyCellular;

  @override
  int get hashCode => 'any_cellular'.hashCode;

  @override
  String toString() => 'AnyCellular()';
}

/// JSON helpers for storing a list of conditions in a single TEXT column.
class NetworkConditionListCodec {
  const NetworkConditionListCodec._();

  static String encode(List<NetworkCondition> conditions) {
    return jsonEncode(conditions.map((c) => c.toJson()).toList());
  }

  static List<NetworkCondition> decode(String raw) {
    if (raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException(
        'Expected JSON array of conditions, got: $raw',
      );
    }
    // Skip individual unknown / malformed entries instead of failing the
    // whole list. A single bad record (e.g. a condition kind written by
    // a future version) used to bubble out of NetworkRulesDao.watchAll
    // and turn the entire stream into an empty list, wiping every rule
    // from the user's UI.
    final result = <NetworkCondition>[];
    for (final entry in decoded) {
      try {
        result.add(NetworkCondition.fromJson(entry as Map<String, dynamic>));
      } catch (e) {
        commonPrint.log(
          'network-rules: skipping unknown condition $entry: $e',
        );
      }
    }
    return List.unmodifiable(result);
  }
}

/// A single network rule: when ALL conditions match the current snapshot,
/// produce [action]. Lower [priority] runs first.
class NetworkRule {
  /// Drift-assigned id. 0 means "not yet persisted" and is the marker the
  /// repository uses to switch between insert and update.
  final int id;

  final String? name;

  /// Conditions are ANDed together when evaluating.
  final List<NetworkCondition> conditions;

  final NetworkAction action;

  /// Lower priority value runs first. Ties break by id ascending.
  final int priority;

  final bool enabled;

  const NetworkRule({
    this.id = 0,
    this.name,
    this.conditions = const [],
    required this.action,
    required this.priority,
    this.enabled = true,
  });

  NetworkRule copyWith({
    int? id,
    String? name,
    List<NetworkCondition>? conditions,
    NetworkAction? action,
    int? priority,
    bool? enabled,
  }) {
    return NetworkRule(
      id: id ?? this.id,
      name: name ?? this.name,
      conditions: conditions ?? this.conditions,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkRule &&
          other.id == id &&
          other.name == name &&
          other.action == action &&
          other.priority == priority &&
          other.enabled == enabled &&
          _conditionsEqual(other.conditions, conditions);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    action,
    priority,
    enabled,
    Object.hashAll(conditions),
  );

  @override
  String toString() =>
      'NetworkRule(id: $id, name: $name, conditions: $conditions, '
      'action: $action, priority: $priority, enabled: $enabled)';
}

bool _conditionsEqual(List<NetworkCondition> a, List<NetworkCondition> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
