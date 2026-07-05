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
    RuleAction.PROCESS_NAME_WILDCARD,
    RuleAction.PROCESS_PATH,
    RuleAction.PROCESS_PATH_REGEX,
    RuleAction.PROCESS_PATH_WILDCARD,
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

/// The single-clause `SUB-RULE,(PROCESS-NAME,<pkg>),<name>` shape. Modeled apart
/// from [TypedRule] because a plain PROCESS-NAME rule cannot target a sub-rule;
/// multi-clause SUB-RULEs (AND/OR payloads) stay [PassthroughRule].
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

/// A `SUB-RULE,(<TYPE>,<params>),<name>` with a single flat non-logical clause
/// that is not PROCESS-NAME (those are [AppToSubRuleRoute]); round-trips
/// byte-for-byte. Multi-clause or logical payloads stay [PassthroughRule].
final class SubRuleRoute extends RoutingRule {
  final RuleAction action;
  final String
  params; // everything after the type, e.g. "ya.ru" or "CN,no-resolve"
  final String subRuleName;

  const SubRuleRoute({
    required this.action,
    required this.params,
    required this.subRuleName,
  });

  String get _clause =>
      params.isEmpty ? action.value : '${action.value},$params';

  @override
  String serialize() => 'SUB-RULE,($_clause),$subRuleName';

  @override
  bool operator ==(Object other) =>
      other is SubRuleRoute &&
      other.action == action &&
      other.params == params &&
      other.subRuleName == subRuleName;

  @override
  int get hashCode => Object.hash(action, params, subRuleName);
}

/// One clause inside a [LogicalRule]: a non-logical condition type plus its raw
/// remaining params, kept verbatim so an unedited clause re-serializes exactly.
final class LogicalClause {
  final RuleAction action;
  final String
  params; // everything after the type, e.g. "a.com" or "CN,no-resolve"

  const LogicalClause({required this.action, required this.params});

  String serialize() =>
      params.isEmpty ? action.value : '${action.value},$params';

  @override
  bool operator ==(Object other) =>
      other is LogicalClause &&
      other.action == action &&
      other.params == params;

  @override
  int get hashCode => Object.hash(action, params);
}

/// A flat-clause logical rule (`AND`/`OR`/`NOT` over parenthesized clauses),
/// round-tripped byte-for-byte. A clause that is itself logical or nested keeps
/// the whole rule as [PassthroughRule] (deep nesting is not modeled).
final class LogicalRule extends RoutingRule {
  final RuleAction op; // AND, OR, or NOT
  final List<LogicalClause> clauses;
  final String target;
  final bool noResolve;
  final bool src;

  const LogicalRule({
    required this.op,
    required this.clauses,
    required this.target,
    this.noResolve = false,
    this.src = false,
  });

  LogicalRule copyWith({
    RuleAction? op,
    List<LogicalClause>? clauses,
    String? target,
    bool? noResolve,
    bool? src,
  }) => LogicalRule(
    op: op ?? this.op,
    clauses: clauses ?? this.clauses,
    target: target ?? this.target,
    noResolve: noResolve ?? this.noResolve,
    src: src ?? this.src,
  );

  @override
  String serialize() {
    final body = clauses.map((c) => '(${c.serialize()})').join(',');
    return [
      op.value,
      '($body)',
      target,
      if (src) 'src',
      if (noResolve) 'no-resolve',
    ].join(',');
  }

  @override
  bool operator ==(Object other) =>
      other is LogicalRule &&
      other.op == op &&
      other.target == target &&
      other.noResolve == noResolve &&
      other.src == src &&
      _listEq(other.clauses, clauses);

  @override
  int get hashCode =>
      Object.hash(op, target, noResolve, src, Object.hashAll(clauses));

  static bool _listEq(List<LogicalClause> a, List<LogicalClause> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

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
    return _parseSubRule(core) ?? PassthroughRule(line);
  }
  if (action == RuleAction.AND ||
      action == RuleAction.OR ||
      action == RuleAction.NOT) {
    return _parseLogical(action!, core, src: src, noResolve: noResolve) ??
        PassthroughRule(line);
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

// `SUB-RULE,(<TYPE>,<params>),<name>` with a single flat non-logical clause: a
// PROCESS-NAME clause is [AppToSubRuleRoute], any other matcher a [SubRuleRoute].
// Multi-clause/logical/empty payloads return null (stay Passthrough).
RoutingRule? _parseSubRule(List<String> core) {
  if (core.length != 3) return null;
  final name = core[2];
  if (name.isEmpty) return null;
  final clause = core[1];
  if (!clause.startsWith('(') || !clause.endsWith(')')) return null;
  final inner = clause.substring(1, clause.length - 1);
  if (inner.contains('(') || inner.contains(')')) return null;
  final fields = _splitTopLevel(inner);
  final action = fields.isEmpty ? null : _actionOf(fields.first);
  if (action == null || _logical.contains(action)) return null;
  final params = fields.sublist(1).join(',');
  if (params.isEmpty) return null;
  if (action == RuleAction.PROCESS_NAME) {
    return AppToSubRuleRoute(packageName: params, subRuleName: name);
  }
  return SubRuleRoute(action: action, params: params, subRuleName: name);
}

// Recognizes `AND`/`OR`/`NOT,(<clauses>),<target>` with flat `(TYPE,params)`
// clauses. Returns null (-> Passthrough) on nested logical clauses, a NOT with
// other than one clause, or any malformed shape, so odd grammar is never reshaped.
LogicalRule? _parseLogical(
  RuleAction op,
  List<String> core, {
  required bool src,
  required bool noResolve,
}) {
  if (core.length != 3) return null;
  final payload = core[1];
  if (!payload.startsWith('(') || !payload.endsWith(')')) return null;
  final target = core[2];
  if (target.isEmpty) return null;
  final parts = _splitTopLevel(payload.substring(1, payload.length - 1));
  if (parts.isEmpty) return null;
  if (op == RuleAction.NOT && parts.length != 1) return null;
  final clauses = <LogicalClause>[];
  for (final part in parts) {
    if (!part.startsWith('(') || !part.endsWith(')')) return null;
    final clause = _parseClause(part.substring(1, part.length - 1));
    if (clause == null) return null;
    clauses.add(clause);
  }
  return LogicalRule(
    op: op,
    clauses: clauses,
    target: target,
    src: src,
    noResolve: noResolve,
  );
}

// One flat clause body, e.g. `DOMAIN,a.com` or `GEOIP,CN,no-resolve`. Nested
// parens or a logical type yield null so the parent rule stays Passthrough.
LogicalClause? _parseClause(String body) {
  if (body.contains('(') || body.contains(')')) return null;
  final fields = _splitTopLevel(body);
  final action = fields.isEmpty ? null : _actionOf(fields.first);
  if (action == null || _logical.contains(action)) return null;
  return LogicalClause(action: action, params: fields.sublist(1).join(','));
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
