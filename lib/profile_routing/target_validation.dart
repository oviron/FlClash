library;

import 'package:yaml/yaml.dart';

import 'rule_codec.dart';

const _builtinTargets = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'PASS',
  'GLOBAL',
  'COMPATIBLE',
};

/// Names a rule target may legitimately reference in [yaml]: every proxy-group
/// name plus every proxy name. Empty when the document fails to parse.
Set<String> configTargets(String yaml) {
  final Object? doc;
  try {
    doc = loadYaml(yaml);
  } on YamlException {
    return const {};
  }
  if (doc is! YamlMap) return const {};
  final names = <String>{};
  for (final key in const ['proxy-groups', 'proxies']) {
    final list = doc[key];
    if (list is! YamlList) continue;
    for (final item in list) {
      if (item is YamlMap && item['name'] is String) {
        names.add(item['name'] as String);
      }
    }
  }
  final subRules = doc['sub-rules'];
  if (subRules is YamlMap) {
    for (final key in subRules.keys) {
      names.add(key.toString());
    }
  }
  return names;
}

/// Targets of typed and logical rules that resolve to neither a builtin policy
/// nor a name in [valid], i.e. dangling after a subscription renamed/removed a
/// group. De-duplicated, order-preserving. Passthrough rules are skipped.
List<String> danglingTargets(List<RoutingRule> rules, Set<String> valid) {
  final out = <String>[];
  void check(String target) {
    if (target.isEmpty) return;
    if (_builtinTargets.contains(target) || valid.contains(target)) return;
    if (!out.contains(target)) out.add(target);
  }

  for (final r in rules) {
    switch (r) {
      case TypedRule():
        check(r.target);
      case LogicalRule():
        check(r.target);
      case AppToSubRuleRoute():
        check(r.subRuleName);
      case SubRuleRoute():
        check(r.subRuleName);
      case PassthroughRule():
        break;
    }
  }
  return out;
}
