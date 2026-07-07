import 'package:fl_clash/common/yaml.dart';
import 'package:yaml/yaml.dart';

const _unset = Object();

// Lossless ordered map: unmodeled keys are preserved verbatim so a
// fresh write never drops a mihomo option the model does not know.
class GroupSpec {
  final Map<String, dynamic> raw;

  const GroupSpec(this.raw);

  factory GroupSpec.fromYaml(YamlMap node) =>
      GroupSpec((yamlToDart(node) as Map).cast<String, dynamic>());

  factory GroupSpec.create({required String name, required String type}) =>
      GroupSpec({'name': name, 'type': type, 'proxies': <String>[]});

  static const _known = {
    'name',
    'type',
    'proxies',
    'url',
    'interval',
    'lazy',
    'use',
    'filter',
    'hidden',
    'tolerance',
  };

  String get name => (raw['name'] ?? '').toString();

  String get type => (raw['type'] ?? 'select').toString();

  List<String> get proxies => _strings(raw['proxies']);

  List<String> get use => _strings(raw['use']);

  // Regex over provider members.
  String? get filter => raw['filter']?.toString();

  String? get url => raw['url']?.toString();

  int? get interval => asInt(raw['interval']);

  bool get lazy => raw['lazy'] == true;

  bool get hidden => raw['hidden'] == true;

  // url-test tolerance in ms before switching.
  int? get tolerance => asInt(raw['tolerance']);

  List<String> get extraKeys =>
      raw.keys.where((k) => !_known.contains(k)).toList();

  Map<String, dynamic> get extra => {for (final k in extraKeys) k: raw[k]};

  GroupSpec copyWith({
    String? name,
    String? type,
    List<String>? proxies,
    List<String>? use,
    Object? filter = _unset,
    Object? url = _unset,
    Object? interval = _unset,
    bool? lazy,
    bool? hidden,
    Object? tolerance = _unset,
  }) {
    final m = Map<String, dynamic>.of(raw);
    if (name != null) m['name'] = name;
    if (type != null) m['type'] = type;
    if (proxies != null) m['proxies'] = proxies;
    if (use != null) {
      use.isEmpty ? m.remove('use') : m['use'] = use;
    }
    if (!identical(filter, _unset)) {
      filter == null ? m.remove('filter') : m['filter'] = filter;
    }
    if (!identical(url, _unset)) {
      url == null ? m.remove('url') : m['url'] = url;
    }
    if (!identical(interval, _unset)) {
      interval == null ? m.remove('interval') : m['interval'] = interval;
    }
    if (lazy != null) {
      lazy ? m['lazy'] = true : m.remove('lazy');
    }
    if (hidden != null) {
      hidden ? m['hidden'] = true : m.remove('hidden');
    }
    if (!identical(tolerance, _unset)) {
      tolerance == null ? m.remove('tolerance') : m['tolerance'] = tolerance;
    }
    return GroupSpec(m);
  }

  static List<String> _strings(Object? v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];
}
