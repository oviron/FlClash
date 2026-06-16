library;

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'rule_codec.dart';

/// Reads/rewrites the `rules:` block of a raw mihomo config via `yaml_edit`,
/// preserving other keys, ordering, and comments. Comments *inside* the rules
/// block are best-effort (the block is rewritten whole).
class ProfileRulesDocument {
  final String raw;

  const ProfileRulesDocument(this.raw);

  /// Parsed `rules:` entries; empty when the key is absent, not a list, or the
  /// document fails to parse (a half-written file must not throw).
  List<RoutingRule> get rules {
    final Object? doc;
    try {
      doc = loadYaml(raw);
    } on YamlException {
      return const [];
    }
    if (doc is! YamlMap) return const [];
    final node = doc['rules'];
    if (node is! YamlList) return const [];
    return parseRoutingRules(node.map((e) => e.toString()).toList());
  }

  /// New document string with the `rules:` list replaced by [rules]. Throws
  /// [ProfileRulesWriteException] when the root is not a YAML map.
  String withRules(List<RoutingRule> rules) {
    final editor = YamlEditor(raw);
    final root = editor.parseAt([]);
    if (root is! YamlMap) {
      throw const ProfileRulesWriteException('config root is not a YAML map');
    }
    editor.update(['rules'], serializeRoutingRules(rules));
    return editor.toString();
  }

  /// Packages under `tun.exclude-package` (the out-of-tunnel deny-list); empty
  /// when absent. Managing only exclude-package is correct in both modes:
  /// aclFromTunYaml computes the effective allow-list as include \ exclude.
  List<String> get excludedPackages {
    final Object? doc;
    try {
      doc = loadYaml(raw);
    } on YamlException {
      return const [];
    }
    final tun = doc is YamlMap ? doc['tun'] : null;
    final node = tun is YamlMap ? tun['exclude-package'] : null;
    if (node is! YamlList) return const [];
    return node.whereType<String>().toList();
  }

  /// New document with `tun.exclude-package` set to [packages] (creates `tun`
  /// or the key when absent; an empty list removes the key). Other tun fields
  /// and document parts are preserved.
  String withExcludedPackages(List<String> packages) {
    final editor = YamlEditor(raw);
    final root = editor.parseAt([]);
    if (root is! YamlMap) {
      throw const ProfileRulesWriteException('config root is not a YAML map');
    }
    final tun = root['tun'];
    if (packages.isEmpty) {
      if (tun is YamlMap && tun.containsKey('exclude-package')) {
        editor.remove(['tun', 'exclude-package']);
      }
      return editor.toString();
    }
    if (tun is YamlMap) {
      editor.update(['tun', 'exclude-package'], packages);
    } else {
      editor.update(['tun'], {'exclude-package': packages});
    }
    return editor.toString();
  }
}

class ProfileRulesWriteException implements Exception {
  final String message;

  const ProfileRulesWriteException(this.message);

  @override
  String toString() => 'ProfileRulesWriteException: $message';
}
