import 'model.dart';

void injectByeDpi({
  required Map<String, dynamic> rawConfig,
  required ByeDpiSettings settings,
  required List<String> hosts,
}) {
  if (!settings.enabled) return;

  final proxies = _ensureList(rawConfig, 'proxies');
  if (!proxies.any((p) => p is Map && p['name'] == 'byedpi-local')) {
    proxies.add({
      'name': 'byedpi-local',
      'type': 'socks5',
      'server': '127.0.0.1',
      'port': settings.port,
      'udp': false,
    });
    rawConfig['proxies'] = proxies;
  }

  if (settings.mode != ByeDpiMode.auto) return;

  final cleanedHosts = hosts
      .map((h) => h.trim())
      .where((h) => h.isNotEmpty && !h.startsWith('#'))
      .toList(growable: false);
  if (cleanedHosts.isEmpty) return;

  final target = settings.fallbackEnabled && settings.fallbackGroup.isNotEmpty
      ? 'byedpi-fallback'
      : 'byedpi-local';

  if (target == 'byedpi-fallback') {
    final groups = _ensureList(rawConfig, 'proxy-groups');
    if (!groups.any((g) => g is Map && g['name'] == 'byedpi-fallback')) {
      groups.add({
        'name': 'byedpi-fallback',
        'type': 'fallback',
        'proxies': ['byedpi-local', settings.fallbackGroup],
        'url': 'https://www.gstatic.com/generate_204',
        'interval': 60,
        'tolerance': 50,
      });
      rawConfig['proxy-groups'] = groups;
    }
  }

  final rules = _ensureList(rawConfig, 'rules');
  final innerIdx = rules.indexWhere(
    (r) => r is String && r.startsWith('IN-TYPE,INNER,'),
  );
  final insertAt = innerIdx >= 0 ? innerIdx + 1 : 0;
  final newRules = [for (final h in cleanedHosts) 'DOMAIN-SUFFIX,$h,$target'];
  rules.insertAll(insertAt, newRules);
  rawConfig['rules'] = rules;
}

List<dynamic> _ensureList(Map<String, dynamic> config, String key) {
  final v = config[key];
  if (v is List) return List<dynamic>.from(v);
  return <dynamic>[];
}
