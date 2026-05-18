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
      'udp': true,
    });
    rawConfig['proxies'] = proxies;
  }

  // byedpi needs the real hostname in SOCKS5 ATYP=DOMAIN. Without sniffer +
  // force-dns-mapping, mihomo passes the fake-IP as ATYP=IPv4 and byedpi can't
  // do anything with it. This is the most common silent-fail of the integration.
  _ensureByeDpiSniffer(rawConfig);

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
  // Curated DOMAIN-SUFFIX only; broad GEOSITE/GEOIP over-captures unrelated
  // Google/Cloudflare services on the same AS.
  final newRules = <String>[
    for (final h in cleanedHosts) 'DOMAIN-SUFFIX,$h,$target',
  ];
  rules.insertAll(insertAt, newRules);
  rawConfig['rules'] = rules;
}

void _ensureByeDpiSniffer(Map<String, dynamic> rawConfig) {
  final raw = rawConfig['sniffer'];
  final sniffer = raw is Map<String, dynamic>
      ? raw
      : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});
  sniffer['enable'] = true;
  sniffer['force-dns-mapping'] = true;
  sniffer['parse-pure-ip'] ??= true;
  final sniffRaw = sniffer['sniff'];
  final sniff = sniffRaw is Map<String, dynamic>
      ? sniffRaw
      : (sniffRaw is Map
            ? Map<String, dynamic>.from(sniffRaw)
            : <String, dynamic>{});
  sniff['TLS'] ??= {
    'ports': [443],
  };
  sniff['HTTP'] ??= {
    'ports': [80],
  };
  sniffer['sniff'] = sniff;
  rawConfig['sniffer'] = sniffer;
}

List<dynamic> _ensureList(Map<String, dynamic> config, String key) {
  final v = config[key];
  if (v is List) return List<dynamic>.from(v);
  return <dynamic>[];
}
