// Network Rules v1: pure rule engine.
//
// Single entry point: [evaluate]. Given the user's rule list, the current
// network snapshot, and a fallback action, return the action of the first
// matching rule (priority ascending, AND across conditions). Disabled rules
// and rules with empty condition lists never match. WifiNamed degrades
// gracefully to non-match when the snapshot SSID is null (e.g. the user
// has not granted ACCESS_FINE_LOCATION).
//
// This file MUST stay pure: no IO, no platform calls, no logging. The
// runtime dispatcher in Wave 6 will sit on top and translate the returned
// action into VPN start/stop calls.

import 'model.dart';

export 'model.dart';

/// Decide what the VPN should do for [snapshot] given the user's [rules].
///
/// Rule iteration order: ascending [NetworkRule.priority] (lower number runs
/// first). Disabled rules are skipped. A rule matches when ALL of its
/// conditions match the snapshot (AND). The first matching rule wins;
/// remaining rules are not evaluated. If no rule matches, [fallback] is
/// returned.
///
/// A rule with an empty conditions list never matches: we treat empty as
/// "no opinion" rather than "match everything" so a half-edited rule cannot
/// hijack the engine.
NetworkAction evaluate({
  required List<NetworkRule> rules,
  required NetworkSnapshot snapshot,
  required NetworkAction fallback,
}) {
  final ordered = [...rules]..sort((a, b) => a.priority.compareTo(b.priority));

  for (final rule in ordered) {
    if (!rule.enabled) continue;
    if (rule.conditions.isEmpty) continue;
    final allMatch = rule.conditions.every((c) => c.matches(snapshot));
    if (allMatch) return rule.action;
  }

  return fallback;
}
