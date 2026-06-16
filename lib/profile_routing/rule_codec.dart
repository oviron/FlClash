library;

import 'package:fl_clash/enum/enum.dart';

/// A single mihomo `rules:` entry. Either parsed into typed fields, or kept
/// verbatim as [PassthroughRule] when the grammar is beyond the typed model
/// (logical AND/OR/NOT, SUB-RULE, nested parens, or an unexpected field count).
/// Round-trips byte-for-byte for the canonical comma-joined form FlClash emits.
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
