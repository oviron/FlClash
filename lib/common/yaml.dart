import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Recursively unwraps `package:yaml` nodes into plain Dart maps/lists/scalars,
/// so downstream code never re-encodes a YamlScalar as a quoted string.
Object? yamlToDart(Object? node) {
  if (node is YamlMap) {
    return {
      for (final e in node.entries) e.key.toString(): yamlToDart(e.value),
    };
  }
  if (node is YamlList) return node.map(yamlToDart).toList();
  if (node is YamlScalar) return node.value;
  return node;
}

class Yaml {
  static Yaml? _instance;

  Yaml._internal();

  factory Yaml() {
    _instance ??= Yaml._internal();
    return _instance!;
  }

  String encode(Object? value) {
    return YamlWriter().convert(value);
  }
}

final yaml = Yaml();
