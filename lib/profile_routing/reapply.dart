import 'rule_codec.dart';
import 'yaml_rules_io.dart';

class ReapplyResult {
  /// Merged config; identical to the input `fresh` when nothing changed.
  final String content;

  /// User app-rules the fresh subscription lacked, re-added (prepended).
  final int overlaid;

  /// User app-rules the fresh subscription redefined; the user's target won.
  final int conflicts;

  const ReapplyResult({
    required this.content,
    required this.overlaid,
    required this.conflicts,
  });

  bool get changed => overlaid > 0 || conflicts > 0;
}

// An app-routing rule's identity for carry-across-refresh. A flat PROCESS-*/UID
// rule and an app->sub-rule route both key on the targeted app, so the two never
// co-exist for one app and a same-app conflict resolves prefer-user. The tab
// separator is collision-safe (an enum token and a package never contain one).
String? _appKey(RoutingRule r) {
  if (r is TypedRule && r.isAppRouting) return '${r.action.value}\t${r.value}';
  if (r is AppToSubRuleRoute) return 'PROCESS-NAME\t${r.packageName}';
  return null;
}

/// Re-applies the user's per-app routing (PROCESS-*/UID rules and app->sub-rule
/// routes) from [previous] onto a [fresh] download: prefer-user on a same-app
/// conflict, dropped rules re-added at the front. Other rules ride along.
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
