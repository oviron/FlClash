library;

import 'package:fl_clash/common/yaml.dart';
import 'package:yaml/yaml.dart';

const _unset = Object();

/// One `proxy-groups:` entry as a lossless ordered map: typed accessors for the
/// fields the editor manages, while every other key (strategy, filter,
/// exclude-type, use, icon, ...) is preserved verbatim so a round-trip never
/// drops a mihomo option the model does not know about.
class GroupSpec {
  final Map<String, dynamic> raw;

  const GroupSpec(this.raw);

  factory GroupSpec.fromYaml(YamlMap node) =>
      GroupSpec((yamlToDart(node) as Map).cast<String, dynamic>());

  factory GroupSpec.create({required String name, required String type}) =>
      GroupSpec({'name': name, 'type': type, 'proxies': <String>[]});

  static const _known = {'name', 'type', 'proxies', 'url', 'interval', 'lazy'};

  String get name => (raw['name'] ?? '').toString();

  String get type => (raw['type'] ?? 'select').toString();

  List<String> get proxies => _strings(raw['proxies']);

  String? get url => raw['url']?.toString();

  int? get interval {
    final v = raw['interval'];
    return v is int ? v : int.tryParse('$v');
  }

  bool get lazy => raw['lazy'] == true;

  /// Keys not surfaced as typed fields; shown to the user as preserved-as-is.
  List<String> get extraKeys =>
      raw.keys.where((k) => !_known.contains(k)).toList();

  GroupSpec copyWith({
    String? name,
    String? type,
    List<String>? proxies,
    Object? url = _unset,
    Object? interval = _unset,
    bool? lazy,
  }) {
    final m = Map<String, dynamic>.of(raw);
    if (name != null) m['name'] = name;
    if (type != null) m['type'] = type;
    if (proxies != null) m['proxies'] = proxies;
    if (!identical(url, _unset)) {
      url == null ? m.remove('url') : m['url'] = url;
    }
    if (!identical(interval, _unset)) {
      interval == null ? m.remove('interval') : m['interval'] = interval;
    }
    if (lazy != null) {
      lazy ? m['lazy'] = true : m.remove('lazy');
    }
    return GroupSpec(m);
  }

  static List<String> _strings(Object? v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];
}
