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
  return names;
}

/// Targets of typed rules that resolve to neither a builtin policy nor a name
/// in [valid], i.e. dangling after a subscription renamed/removed a group.
/// De-duplicated, order-preserving. Passthrough (logical) rules are skipped.
List<String> danglingTargets(List<RoutingRule> rules, Set<String> valid) {
  final out = <String>[];
  for (final r in rules) {
    if (r is! TypedRule) continue;
    final target = r.target;
    if (target.isEmpty) continue;
    if (_builtinTargets.contains(target) || valid.contains(target)) continue;
    if (!out.contains(target)) out.add(target);
  }
  return out;
}
