// Network* prefix avoids collision with the existing clash routing `Rule`.

import 'dart:convert';

import 'package:fl_clash/common/common.dart';

enum NetworkVpnMode { turnOn, turnOff, leave }

/// A rule's action: what to do with the VPN, and optionally which profile to
/// switch to. [profileId] null = leave the active profile untouched.
class NetworkAction {
  final NetworkVpnMode vpn;
  final int? profileId;

  const NetworkAction({required this.vpn, this.profileId});

  static const turnOn = NetworkAction(vpn: NetworkVpnMode.turnOn);
  static const turnOff = NetworkAction(vpn: NetworkVpnMode.turnOff);

  Map<String, dynamic> toJson() => {
    'vpn': vpn.name,
    if (profileId != null) 'profileId': profileId,
  };

  factory NetworkAction.fromJson(Map<String, dynamic> json) => NetworkAction(
    vpn: NetworkVpnMode.values.firstWhere(
      (m) => m.name == json['vpn'],
      orElse: () => NetworkVpnMode.turnOn,
    ),
    profileId: json['profileId'] as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkAction &&
          other.vpn == vpn &&
          other.profileId == profileId;

  @override
  int get hashCode => Object.hash(vpn, profileId);

  @override
  String toString() => 'NetworkAction(vpn: $vpn, profileId: $profileId)';
}

enum NetworkType { wifi, cellular, ethernet, none }

class NetworkSnapshot {
  final NetworkType type;

  /// Wi-Fi SSID. Only meaningful when type == wifi. Can be null even on
  /// Wi-Fi if the OS denied us ACCESS_FINE_LOCATION or returned the
  /// Android stub `<unknown ssid>`.
  final String? ssid;

  const NetworkSnapshot.wifi({this.ssid}) : type = NetworkType.wifi;

  const NetworkSnapshot.cellular() : type = NetworkType.cellular, ssid = null;

  const NetworkSnapshot.ethernet() : type = NetworkType.ethernet, ssid = null;

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

/// Everything a condition may match against: the network snapshot plus the
/// active profile id (for profile-gate conditions). Network conditions read
/// only [snapshot]; the profile axis is kept out of [NetworkSnapshot] on
/// purpose (it is app state, not network state).
class NetworkMatchContext {
  final NetworkSnapshot snapshot;
  final int? activeProfileId;

  const NetworkMatchContext({required this.snapshot, this.activeProfileId});
}

/// A single match clause. Multiple conditions on a rule are combined with AND.
sealed class NetworkCondition {
  const NetworkCondition();

  bool matches(NetworkMatchContext ctx);

  Map<String, dynamic> toJson();

  /// Higher = more specific. A named Wi-Fi (2) wins over a type-level clause
  /// (1) regardless of user-defined priority, so a `Home` rule is never
  /// shadowed by an `any wifi` rule. Keep in sync with the Kotlin engine.
  int get specificity;

  static NetworkCondition fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String?;
    switch (kind) {
      case 'wifi_named':
        return WifiNamed(json['ssid'] as String);
      case 'any_wifi':
        return const AnyWifi();
      case 'any_cellular':
        return const AnyCellular();
      case 'any_ethernet':
        return const AnyEthernet();
      case 'profile_is':
        return ProfileIs(json['profileId'] as int);
      default:
        throw FormatException('Unknown NetworkCondition kind: $kind in $json');
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
  bool matches(NetworkMatchContext ctx) {
    final snapshot = ctx.snapshot;
    if (snapshot.type != NetworkType.wifi) return false;
    final candidate = snapshot.ssid;
    if (candidate == null) return false;
    return candidate.toLowerCase() == ssid.toLowerCase();
  }

  @override
  Map<String, dynamic> toJson() => {'kind': 'wifi_named', 'ssid': ssid};

  @override
  int get specificity => 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiNamed && other.ssid.toLowerCase() == ssid.toLowerCase();

  @override
  int get hashCode => ssid.toLowerCase().hashCode;

  @override
  String toString() => 'WifiNamed($ssid)';
}

class AnyWifi extends NetworkCondition {
  const AnyWifi();

  @override
  bool matches(NetworkMatchContext ctx) =>
      ctx.snapshot.type == NetworkType.wifi;

  @override
  Map<String, dynamic> toJson() => const {'kind': 'any_wifi'};

  @override
  int get specificity => 1;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AnyWifi;

  @override
  int get hashCode => 'any_wifi'.hashCode;

  @override
  String toString() => 'AnyWifi()';
}

class AnyCellular extends NetworkCondition {
  const AnyCellular();

  @override
  bool matches(NetworkMatchContext ctx) =>
      ctx.snapshot.type == NetworkType.cellular;

  @override
  Map<String, dynamic> toJson() => const {'kind': 'any_cellular'};

  @override
  int get specificity => 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnyCellular;

  @override
  int get hashCode => 'any_cellular'.hashCode;

  @override
  String toString() => 'AnyCellular()';
}

class AnyEthernet extends NetworkCondition {
  const AnyEthernet();

  @override
  bool matches(NetworkMatchContext ctx) =>
      ctx.snapshot.type == NetworkType.ethernet;

  @override
  Map<String, dynamic> toJson() => const {'kind': 'any_ethernet'};

  @override
  int get specificity => 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnyEthernet;

  @override
  int get hashCode => 'any_ethernet'.hashCode;

  @override
  String toString() => 'AnyEthernet()';
}

/// Matches when the given profile is the active one. Used as an optional gate
/// on a rule (AND'd with a network condition). Evaluated against the snapshot's
/// active profile, so it only re-checks when the engine re-evaluates (i.e. on a
/// network change), not the instant the profile changes.
class ProfileIs extends NetworkCondition {
  final int profileId;

  const ProfileIs(this.profileId);

  @override
  bool matches(NetworkMatchContext ctx) => ctx.activeProfileId == profileId;

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'profile_is',
    'profileId': profileId,
  };

  @override
  int get specificity => 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileIs && other.profileId == profileId;

  @override
  int get hashCode => Object.hash('profile_is', profileId);

  @override
  String toString() => 'ProfileIs($profileId)';
}

class NetworkConditionListCodec {
  const NetworkConditionListCodec._();

  static String encode(List<NetworkCondition> conditions) {
    return jsonEncode(conditions.map((c) => c.toJson()).toList());
  }

  static List<NetworkCondition> decode(String raw) {
    if (raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('Expected JSON array of conditions, got: $raw');
    }
    // Skip unknown entries individually: a single bad record (e.g. future
    // version's condition kind) used to bubble out of watchAll and wipe
    // every rule from the UI.
    final result = <NetworkCondition>[];
    for (final entry in decoded) {
      try {
        result.add(NetworkCondition.fromJson(entry as Map<String, dynamic>));
      } catch (e) {
        commonPrint.log('network-rules: skipping unknown condition $entry: $e');
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

  final List<NetworkCondition> conditions;

  final NetworkAction action;

  /// Lower priority value runs first.
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

  /// Convenience accessor for the redesigned UI which only ever creates
  /// single-condition rules. Returns null for legacy empty-conditions rows.
  /// We keep `conditions` as a list in storage for forward compat.
  NetworkCondition? get condition =>
      conditions.isNotEmpty ? conditions.first : null;

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

/// A rule's specificity is its most specific condition (empty => 0).
int networkRuleSpecificity(NetworkRule rule) {
  var best = 0;
  for (final c in rule.conditions) {
    if (c.specificity > best) best = c.specificity;
  }
  return best;
}

/// Evaluation order: most specific first, then user priority (lower first),
/// then id. Shared by the engine and the reason builder so the rule the user
/// is told matched is exactly the one that fired. Mirror in the Kotlin engine.
int compareNetworkRules(NetworkRule a, NetworkRule b) {
  final sa = networkRuleSpecificity(a);
  final sb = networkRuleSpecificity(b);
  if (sa != sb) return sb.compareTo(sa);
  if (a.priority != b.priority) return a.priority.compareTo(b.priority);
  return a.id.compareTo(b.id);
}
