import 'rule_codec.dart';
import 'yaml_rules_io.dart';

class ReapplyResult {
  // Identical to the input `fresh` when nothing changed.
  final String content;

  // User app-rules the fresh sub lacked, re-added at front.
  final int overlaid;

  // User app-rules the fresh sub redefined; the user's target won.
  final int conflicts;

  const ReapplyResult({
    required this.content,
    required this.overlaid,
    required this.conflicts,
  });

  bool get changed => overlaid > 0 || conflicts > 0;
}

// Rule identity for carry-across-refresh; tab separator is collision-safe
// (an enum token and a package name never contain a tab).
String? _appKey(RoutingRule r) {
  if (r is TypedRule && r.isAppRouting) return '${r.action.value}\t${r.value}';
  if (r is AppToSubRuleRoute) return 'PROCESS-NAME\t${r.packageName}';
  return null;
}

ReapplyResult reapplyAppRouting({
  required String previous,
  required String fresh,
}) {
  final prior = ProfileRulesDocument(
    previous,
  ).rules.where((r) => _appKey(r) != null).toList();
  if (prior.isEmpty) {
    return ReapplyResult(content: fresh, overlaid: 0, conflicts: 0);
  }

  final doc = ProfileRulesDocument(fresh);
  final freshRules = doc.rules;
  final index = <String, int>{};
  for (var i = 0; i < freshRules.length; i++) {
    final k = _appKey(freshRules[i]);
    if (k != null) index[k] = i;
  }

  final merged = List<RoutingRule>.of(freshRules);
  final prepend = <RoutingRule>[];
  var overlaid = 0;
  var conflicts = 0;
  for (final intent in prior) {
    final at = index[_appKey(intent)!];
    if (at == null) {
      prepend.add(intent);
      overlaid++;
    } else if (merged[at] != intent) {
      merged[at] = intent;
      conflicts++;
    }
  }
  if (overlaid == 0 && conflicts == 0) {
    return ReapplyResult(content: fresh, overlaid: 0, conflicts: 0);
  }
  return ReapplyResult(
    content: doc.withRules([...prepend, ...merged]),
    overlaid: overlaid,
    conflicts: conflicts,
  );
}
