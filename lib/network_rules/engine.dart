// Pure rule engine: no IO, no platform calls, no logging. Mirrors the
// authoritative Kotlin engine; kept for in-app preview and unit tests.

import 'package:fl_clash/enum/enum.dart';

import 'model.dart';

export 'model.dart';

/// Final outcome the actuator applies: start the VPN, stop it, or do nothing.
enum NetworkDecision { start, stop, leaveAsIs }

// Empty conditions => no match (not "match everything"), so a half-edited
// rule cannot hijack the engine. Order is most-specific-first (see
// [compareNetworkRules]): a named-Wi-Fi rule beats an any-wifi rule even when
// the latter has a lower user priority.
NetworkAction? evaluate({
  required List<NetworkRule> rules,
  required NetworkSnapshot snapshot,
  int? activeProfileId,
}) {
  final ordered = [...rules]..sort(compareNetworkRules);
  final ctx = NetworkMatchContext(
    snapshot: snapshot,
    activeProfileId: activeProfileId,
  );

  for (final rule in ordered) {
    if (!rule.enabled) continue;
    if (rule.conditions.isEmpty) continue;
    final allMatch = rule.conditions.every((c) => c.matches(ctx));
    if (allMatch) return rule.action;
  }

  return null;
}

/// Resolve the snapshot to a final decision: a matching rule wins; otherwise
/// [defaultAction] is the baseline (leaveAsIs => do nothing, the sticky-safe
/// default). This is the whole engine contract minus the manual-override
/// window, which is layered on by the stateful runtime.
NetworkDecision resolveNetworkDecision({
  required List<NetworkRule> rules,
  required NetworkSnapshot snapshot,
  required DefaultNetworkAction defaultAction,
  int? activeProfileId,
}) {
  final matched = evaluate(
    rules: rules,
    snapshot: snapshot,
    activeProfileId: activeProfileId,
  );
  switch (matched?.vpn) {
    case NetworkVpnMode.turnOn:
      return NetworkDecision.start;
    case NetworkVpnMode.turnOff:
      return NetworkDecision.stop;
    case NetworkVpnMode.leave:
    case null:
      switch (defaultAction) {
        case DefaultNetworkAction.turnOn:
          return NetworkDecision.start;
        case DefaultNetworkAction.turnOff:
          return NetworkDecision.stop;
        case DefaultNetworkAction.leaveAsIs:
          return NetworkDecision.leaveAsIs;
      }
  }
}
