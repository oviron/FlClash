import 'model.dart';

String _slugify(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'-+$|^-+'), '');

Map<String, dynamic> injectByeDpiConfig({
  required Map<String, dynamic> rawConfig,
  required ByeDpiSettings settings,
  required List<BypassProfile> profiles,
}) {
  if (!settings.enabled) return rawConfig;
  final active = profiles
      .where((p) => p.enabled && p.apps.isNotEmpty && p.domains.isNotEmpty)
      .toList();
  if (active.isEmpty) return rawConfig;

  final proxies = _ensureList(rawConfig, 'proxies');
  if (!proxies.any((p) => p is Map && p['name'] == 'byedpi-local')) {
    proxies.add({
      'name': 'byedpi-local',
      'type': 'socks5',
      'server': '127.0.0.1',
      'port': settings.port,
    });
  }
  rawConfig['proxies'] = proxies;

  final groups = _ensureList(rawConfig, 'proxy-groups');
  final subRules = _ensureMap(rawConfig, 'sub-rules');
  final rules = _ensureList(rawConfig, 'rules');

  final List<String> prependRules = [];

  for (final profile in active) {
    final slug = _slugify(profile.name);
    final groupName = '$slug-route';
    final subRuleKey = '$slug-rules';

    if (!groups.any((g) => g is Map && g['name'] == groupName)) {
      groups.add({
        'name': groupName,
        'type': 'fallback',
        'proxies': ['byedpi-local', settings.fallbackGroup],
        'url': 'https://www.gstatic.com/generate_204',
        'interval': 60,
        'lazy': true,
      });
    }

    if (!subRules.containsKey(subRuleKey)) {
      final List<String> entries = [
        for (final d in profile.domains) 'DOMAIN-SUFFIX,$d,$groupName',
        'MATCH,${settings.fallbackGroup}',
      ];
      subRules[subRuleKey] = entries;
    }

    for (final app in profile.apps) {
      final entry = 'SUB-RULE,(PROCESS-NAME,$app),$subRuleKey';
      if (!prependRules.contains(entry)) {
        prependRules.add(entry);
      }
    }
  }

  rawConfig['proxy-groups'] = groups;
  rawConfig['sub-rules'] = subRules;

  for (final r in prependRules.reversed) {
    if (!rules.contains(r)) {
      rules.insert(0, r);
    }
  }
  rawConfig['rules'] = rules;

  return rawConfig;
}

List<dynamic> _ensureList(Map<String, dynamic> config, String key) {
  final v = config[key];
  if (v is List) return List<dynamic>.from(v);
  return <dynamic>[];
}

Map<String, dynamic> _ensureMap(Map<String, dynamic> config, String key) {
  final v = config[key];
  if (v is Map) return Map<String, dynamic>.from(v);
  return <String, dynamic>{};
}
