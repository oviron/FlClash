library;

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'rule_codec.dart';

/// Reads and rewrites the `rules:` block of a raw mihomo config, preserving
/// every other part of the document (keys, ordering, comments) through
/// `yaml_edit`. Comments *inside* the rules block are best-effort: the block
/// is rewritten as a whole, so only comments on other keys are guaranteed.
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
}

class ProfileRulesWriteException implements Exception {
  final String message;

  const ProfileRulesWriteException(this.message);

  @override
  String toString() => 'ProfileRulesWriteException: $message';
}
