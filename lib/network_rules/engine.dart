// Pure rule engine: no IO, no platform calls, no logging. The runtime
// dispatcher consumes [evaluate] and turns the returned action into
// VPN start/stop calls.

import 'model.dart';

export 'model.dart';

// Empty conditions => no match (not "match everything"), so a half-edited
// rule cannot hijack the engine.
NetworkAction? evaluate({
  required List<NetworkRule> rules,
  required NetworkSnapshot snapshot,
}) {
  final ordered = [...rules]..sort((a, b) => a.priority.compareTo(b.priority));

  for (final rule in ordered) {
    if (!rule.enabled) continue;
    if (rule.conditions.isEmpty) continue;
    final allMatch = rule.conditions.every((c) => c.matches(snapshot));
    if (allMatch) return rule.action;
  }

  return null;
}
