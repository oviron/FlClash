library;

import 'package:fl_clash/enum/enum.dart';

/// A single mihomo `rules:` entry: [TypedRule] when it parses into typed
/// fields, else [PassthroughRule] (logical/nested/odd grammar kept verbatim).
/// Round-trips byte-for-byte for the canonical comma-joined form.
sealed class RoutingRule {
  const RoutingRule();

  String serialize();

  static RoutingRule parse(String line) => _parse(line);
}

final class TypedRule extends RoutingRule {
  final RuleAction action;
  final String value; // empty for MATCH (it carries only a target)
  final String target;
  final bool noResolve;
  final bool src;

  const TypedRule({
    required this.action,
    required this.value,
    required this.target,
    this.noResolve = false,
    this.src = false,
  });

  bool get isAppRouting => const {
    RuleAction.PROCESS_NAME,
    RuleAction.PROCESS_NAME_REGEX,
    RuleAction.PROCESS_PATH,
    RuleAction.PROCESS_PATH_REGEX,
    RuleAction.UID,
  }.contains(action);

  TypedRule copyWith({
    RuleAction? action,
    String? value,
    String? target,
    bool? noResolve,
    bool? src,
  }) => TypedRule(
    action: action ?? this.action,
    value: value ?? this.value,
    target: target ?? this.target,
    noResolve: noResolve ?? this.noResolve,
    src: src ?? this.src,
  );

  @override
  String serialize() => [
    action.value,
    if (action != RuleAction.MATCH) value,
    target,
    if (src) 'src',
    if (noResolve) 'no-resolve',
  ].join(',');

  @override
  bool operator ==(Object other) =>
      other is TypedRule &&
      other.action == action &&
      other.value == value &&
      other.target == target &&
      other.noResolve == noResolve &&
      other.src == src;

  @override
  int get hashCode => Object.hash(action, value, target, noResolve, src);
}

final class PassthroughRule extends RoutingRule {
  final String raw;

  const PassthroughRule(this.raw);

  @override
  String serialize() => raw;

  @override
  bool operator ==(Object other) =>
      other is PassthroughRule && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;
}

/// The single-clause `SUB-RULE,(PROCESS-NAME,<pkg>),<name>` shape: routes one
/// app into a named sub-rule. Modeled separately from [TypedRule] because a
/// plain PROCESS-NAME rule cannot target a sub-rule. Multi-clause SUB-RULEs
/// (AND/OR payloads) stay [PassthroughRule].
final class AppToSubRuleRoute extends RoutingRule {
  final String packageName;
  final String subRuleName;

  const AppToSubRuleRoute({
    required this.packageName,
    required this.subRuleName,
  });

  @override
  String serialize() => 'SUB-RULE,(PROCESS-NAME,$packageName),$subRuleName';

  @override
  bool operator ==(Object other) =>
      other is AppToSubRuleRoute &&
      other.packageName == packageName &&
      other.subRuleName == subRuleName;

  @override
  int get hashCode => Object.hash(packageName, subRuleName);
}

/// Rule actions authorable in the typed editor as a flat `TYPE,value,target`.
/// Drops the logical forms (AND/OR/NOT need nested rules); RULE-SET is flat
/// (`RULE-SET,<set>,<target>`) so it is offered back (it is common in sub-rules).
List<RuleAction> get editableRuleActions => [
  ...RuleAction.addedRuleActions.where((a) => !_logical.contains(a)),
  RuleAction.RULE_SET,
];

List<RoutingRule> parseRoutingRules(List<String> lines) =>
    lines.map(RoutingRule.parse).toList();

List<String> serializeRoutingRules(List<RoutingRule> rules) =>
    rules.map((r) => r.serialize()).toList();

const _logical = {
  RuleAction.AND,
  RuleAction.OR,
  RuleAction.NOT,
  RuleAction.SUB_RULE,
};
const _flags = {'src', 'no-resolve'};

RuleAction? _actionOf(String value) {
  for (final a in RuleAction.values) {
    if (a.value == value) return a;
  }
  return null;
}

RoutingRule _parse(String line) {
  final fields = _splitTopLevel(line);

  var end = fields.length;
  var src = false;
  var noResolve = false;
  while (end > 0 && _flags.contains(fields[end - 1])) {
    if (fields[end - 1] == 'src') src = true;
    if (fields[end - 1] == 'no-resolve') noResolve = true;
    end--;
  }
  final core = fields.sublist(0, end);

  final action = core.isEmpty ? null : _actionOf(core.first);
  if (action == RuleAction.SUB_RULE && !src && !noResolve) {
    return _parseAppSubRule(core) ?? PassthroughRule(line);
  }
  if (action == null || _logical.contains(action)) {
    return PassthroughRule(line);
  }
  // Defensive: any surviving paren means a nested form we do not model.
  if (core.any((f) => f.contains('(') || f.contains(')'))) {
    return PassthroughRule(line);
  }

  if (action == RuleAction.MATCH) {
    if (core.length != 2) return PassthroughRule(line);
    return TypedRule(
      action: action,
      value: '',
      target: core[1],
      src: src,
      noResolve: noResolve,
    );
  }
  if (core.length != 3) return PassthroughRule(line);
  return TypedRule(
    action: action,
    value: core[1],
    target: core[2],
    src: src,
    noResolve: noResolve,
  );
}

// Recognizes `SUB-RULE,(PROCESS-NAME,<pkg>),<name>` (one PROCESS-NAME clause).
// Returns null for any other SUB-RULE payload, which stays Passthrough.
AppToSubRuleRoute? _parseAppSubRule(List<String> core) {
  if (core.length != 3) return null;
  final clause = core[1];
  if (!clause.startsWith('(') || !clause.endsWith(')')) return null;
  final inner = clause.substring(1, clause.length - 1);
  if (inner.contains('(') || inner.contains(')')) return null;
  final parts = inner.split(',');
  if (parts.length != 2) return null;
  if (_actionOf(parts[0]) != RuleAction.PROCESS_NAME) return null;
  if (parts[1].isEmpty || core[2].isEmpty) return null;
  return AppToSubRuleRoute(packageName: parts[1], subRuleName: core[2]);
}

// Split on commas at paren-depth 0 only; preserves bytes (no trimming) so a
// typed rule re-serializes identically. Nested `(...)` in AND/OR/NOT/SUB-RULE
// stays in one field, which then routes to PassthroughRule.
List<String> _splitTopLevel(String line) {
  final out = <String>[];
  final buf = StringBuffer();
  var depth = 0;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '(') {
      depth++;
    } else if (ch == ')') {
      if (depth > 0) depth--;
    }
    if (ch == ',' && depth == 0) {
      out.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  out.add(buf.toString());
  return out;
}
