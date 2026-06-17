library;

import 'package:yaml/yaml.dart';

const _unset = Object();

/// One `proxy-providers:`/`rule-providers:` entry as a lossless ordered map.
/// Typed accessors cover the fields the editor manages; every other key
/// (`size-limit`, `proxy`, `override`, ...) is preserved verbatim so a
/// round-trip never drops a mihomo option the model does not know about.
class ProviderSpec {
  final Map<String, dynamic> raw;

  const ProviderSpec(this.raw);

  factory ProviderSpec.fromYaml(YamlMap node) =>
      ProviderSpec((_deep(node) as Map).cast<String, dynamic>());

  factory ProviderSpec.create({required String type}) =>
      ProviderSpec({'type': type});

  static const _known = {
    'type',
    'url',
    'path',
    'interval',
    'behavior',
    'format',
    'health-check',
  };

  /// `http` (subscription), `file`, or `inline`.
  String get type => (raw['type'] ?? 'http').toString();

  String? get url => raw['url']?.toString();

  String? get path => raw['path']?.toString();

  int? get interval {
    final v = raw['interval'];
    return v is int ? v : int.tryParse('$v');
  }

  /// rule-providers only: `domain` | `ipcidr` | `classical`.
  String? get behavior => raw['behavior']?.toString();

  /// rule-providers only: `yaml` | `text` | `mrs`.
  String? get format => raw['format']?.toString();

  Map<String, dynamic>? get healthCheck {
    final v = raw['health-check'];
    return v is Map ? v.cast<String, dynamic>() : null;
  }

  /// Keys not surfaced as typed fields; shown to the user as preserved-as-is.
  List<String> get extraKeys =>
      raw.keys.where((k) => !_known.contains(k)).toList();

  ProviderSpec copyWith({
    String? type,
    Object? url = _unset,
    Object? path = _unset,
    Object? interval = _unset,
    Object? behavior = _unset,
    Object? format = _unset,
    Object? healthCheck = _unset,
  }) {
    final m = Map<String, dynamic>.of(raw);
    if (type != null) m['type'] = type;
    _put(m, 'url', url);
    _put(m, 'path', path);
    _put(m, 'interval', interval);
    _put(m, 'behavior', behavior);
    _put(m, 'format', format);
    _put(m, 'health-check', healthCheck);
    return ProviderSpec(m);
  }

  static void _put(Map<String, dynamic> m, String key, Object? value) {
    if (identical(value, _unset)) return;
    value == null ? m.remove(key) : m[key] = value;
  }

  static Object? _deep(Object? node) {
    if (node is YamlMap) {
      return {for (final e in node.entries) e.key.toString(): _deep(e.value)};
    }
    if (node is YamlList) return node.map(_deep).toList();
    if (node is YamlScalar) return node.value;
    return node;
  }
}
