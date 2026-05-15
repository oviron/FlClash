import 'package:fl_clash/byedpi/engine.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hosts = ['youtube.com', 'googlevideo.com', 'ytimg.com'];

  Map<String, dynamic> baseConfig() => {
    'proxies': <dynamic>[],
    'proxy-groups': <dynamic>[],
    'rules': <dynamic>[
      'IN-TYPE,INNER,DIRECT',
      'MATCH,DIRECT',
    ],
  };

  test('master OFF: config unchanged', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(enabled: false),
      hosts: hosts,
    );
    expect(cfg['proxies'] as List, isEmpty);
    expect((cfg['rules'] as List).length, 2);
  });

  test('master ON manual: only byedpi-local proxy injected, no rules added', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.manual,
      ),
      hosts: hosts,
    );
    final proxies = cfg['proxies'] as List;
    expect(proxies.any((p) => p is Map && p['name'] == 'byedpi-local'), isTrue);
    final rules = cfg['rules'] as List;
    expect(rules.whereType<String>().any((r) => r.startsWith('DOMAIN-SUFFIX')), isFalse);
    expect(cfg.containsKey('proxy-groups') &&
        (cfg['proxy-groups'] as List).any((g) => g is Map && g['name'] == 'byedpi-fallback'),
        isFalse);
  });

  test('master ON auto fallback OFF: proxy + DOMAIN-SUFFIX rules pointing to byedpi-local', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.auto,
        fallbackEnabled: false,
      ),
      hosts: hosts,
    );
    final proxies = cfg['proxies'] as List;
    expect(proxies.any((p) => p is Map && p['name'] == 'byedpi-local'), isTrue);

    final rules = cfg['rules'] as List;
    final domainRules = rules.whereType<String>()
        .where((r) => r.startsWith('DOMAIN-SUFFIX'))
        .toList();
    expect(domainRules.length, hosts.length);
    for (final h in hosts) {
      expect(domainRules.any((r) => r.contains(h) && r.endsWith(',byedpi-local')), isTrue);
    }
    final groups = cfg['proxy-groups'] as List;
    expect(groups.any((g) => g is Map && g['name'] == 'byedpi-fallback'), isFalse);
  });

  test('master ON auto fallback ON: proxy + fallback group + DOMAIN-SUFFIX rules pointing to byedpi-fallback', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.auto,
        fallbackEnabled: true,
        fallbackGroup: 'VPN',
      ),
      hosts: hosts,
    );
    final proxies = cfg['proxies'] as List;
    expect(proxies.any((p) => p is Map && p['name'] == 'byedpi-local'), isTrue);

    final groups = cfg['proxy-groups'] as List;
    final fallbackGroup = groups.firstWhere(
      (g) => g is Map && g['name'] == 'byedpi-fallback',
      orElse: () => null,
    ) as Map?;
    expect(fallbackGroup, isNotNull);
    expect(fallbackGroup!['type'], 'fallback');
    expect(fallbackGroup['proxies'] as List, containsAll(['byedpi-local', 'VPN']));

    final rules = cfg['rules'] as List;
    final domainRules = rules.whereType<String>()
        .where((r) => r.startsWith('DOMAIN-SUFFIX'))
        .toList();
    expect(domainRules.length, hosts.length);
    for (final h in hosts) {
      expect(domainRules.any((r) => r.contains(h) && r.endsWith(',byedpi-fallback')), isTrue);
    }
  });

  test('rules inserted after IN-TYPE,INNER,DIRECT', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.auto,
        fallbackEnabled: false,
      ),
      hosts: ['example.com'],
    );
    final rules = cfg['rules'] as List;
    final innerIdx = rules.indexWhere(
      (r) => r is String && r.startsWith('IN-TYPE,INNER,'),
    );
    final exampleIdx = rules.indexWhere(
      (r) => r is String && r.contains('example.com'),
    );
    expect(innerIdx, greaterThanOrEqualTo(0));
    expect(exampleIdx, innerIdx + 1);
  });

  test('hosts with # comments and blank lines are filtered out', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.auto,
        fallbackEnabled: false,
      ),
      hosts: ['# comment', '', '  ', 'valid.com', '#another'],
    );
    final rules = cfg['rules'] as List;
    final domainRules = rules.whereType<String>()
        .where((r) => r.startsWith('DOMAIN-SUFFIX'))
        .toList();
    expect(domainRules.length, 1);
    expect(domainRules.first, contains('valid.com'));
  });

  test('idempotent: re-applying does not duplicate proxy or group', () {
    final cfg = baseConfig();
    const settings = ByeDpiSettings(
      enabled: true,
      mode: ByeDpiMode.auto,
      fallbackEnabled: true,
      fallbackGroup: 'VPN',
    );

    injectByeDpi(rawConfig: cfg, settings: settings, hosts: hosts);
    final proxiesAfter1 = (cfg['proxies'] as List).length;
    final groupsAfter1 = (cfg['proxy-groups'] as List).length;

    injectByeDpi(rawConfig: cfg, settings: settings, hosts: hosts);
    expect((cfg['proxies'] as List).length, proxiesAfter1);
    expect((cfg['proxy-groups'] as List).length, groupsAfter1);
  });

  test('empty hosts list with auto mode: rules not added but proxy is', () {
    final cfg = baseConfig();
    injectByeDpi(
      rawConfig: cfg,
      settings: const ByeDpiSettings(
        enabled: true,
        mode: ByeDpiMode.auto,
        fallbackEnabled: false,
      ),
      hosts: [],
    );
    final proxies = cfg['proxies'] as List;
    expect(proxies.any((p) => p is Map && p['name'] == 'byedpi-local'), isTrue);
    final rules = cfg['rules'] as List;
    expect(rules.whereType<String>().any((r) => r.startsWith('DOMAIN-SUFFIX')), isFalse);
  });
}
