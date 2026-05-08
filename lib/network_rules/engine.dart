// Pure rule engine: no IO, no platform calls, no logging. The runtime
// dispatcher consumes [evaluate] and turns the returned action into
// VPN start/stop calls.

import 'model.dart';

export 'model.dart';

/// Decide what the VPN should do for [snapshot] given the user's [rules].
///
/// Rule iteration order: ascending [NetworkRule.priority] (lower number runs
/// first). Disabled rules are skipped. A rule matches when ALL of its
/// conditions match the snapshot. The redesigned UI always produces single
/// element condition lists, but the existing `every` predicate handles both
/// shapes correctly so legacy multi-condition rows (if any) still match the
/// same way they did before. The first matching rule wins; remaining rules
/// are not evaluated. When no rule matches, the engine returns `null` so the
/// runner can decide to do nothing instead of forcing a fallback action.
///
/// A rule with an empty conditions list never matches: we treat empty as
/// "no opinion" rather than "match everything" so a half-edited rule cannot
/// hijack the engine.
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
