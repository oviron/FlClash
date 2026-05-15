import 'package:fl_clash/byedpi/engine.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ytProfile = BypassProfile(
    id: 1,
    name: 'YouTube',
    domains: ['youtube.com', 'googlevideo.com'],
    apps: [
      'com.google.android.youtube',
      'app.morphe.android.youtube',
      'app.morphe.android.apps.youtube.music',
      'com.deniscerri.ytdl',
    ],
  );

  Map<String, dynamic> baseConfig() => {
    'proxies': <dynamic>[],
    'proxy-groups': <dynamic>[],
    'rules': <dynamic>['MATCH,DIRECT'],
  };

  test('disabled settings returns input unchanged', () {
    final cfg = baseConfig();
    final result = injectByeDpiConfig(
      rawConfig: cfg,
      settings: const ByeDpiSettings(enabled: false),
      profiles: [ytProfile],
    );
    expect(result['proxies'], isEmpty);
    expect((result['rules'] as List).length, 1);
  });

  test('enabled but no profiles returns input unchanged', () {
    final cfg = baseConfig();
    final result = injectByeDpiConfig(
      rawConfig: cfg,
      settings: const ByeDpiSettings(enabled: true),
      profiles: const [],
    );
    expect(result['proxies'], isEmpty);
  });

  test('one YouTube profile injects proxy, group, sub-rule, and 4 PROCESS-NAME rules', () {
    final cfg = baseConfig();
    final result = injectByeDpiConfig(
      rawConfig: cfg,
      settings: const ByeDpiSettings(enabled: true, port: 1080, fallbackGroup: 'VPN'),
      profiles: [ytProfile],
    );

    final proxies = result['proxies'] as List;
    expect(proxies.any((p) => p is Map && p['name'] == 'byedpi-local'), isTrue);

    final groups = result['proxy-groups'] as List;
    expect(groups.any((g) => g is Map && g['name'] == 'youtube-route'), isTrue);

    final subRules = result['sub-rules'] as Map;
    expect(subRules.containsKey('youtube-rules'), isTrue);
    final ytRules = subRules['youtube-rules'] as List;
    expect(ytRules.any((r) => r.toString().contains('DOMAIN-SUFFIX,youtube.com,')), isTrue);

    final rules = result['rules'] as List;
    final processRules = rules.where((r) => r.toString().startsWith('SUB-RULE,')).toList();
    expect(processRules.length, 4);
    expect(processRules.any((r) => r.toString().contains('com.google.android.youtube')), isTrue);
  });

  test('applying twice is idempotent', () {
    final cfg = baseConfig();
    const settings = ByeDpiSettings(enabled: true, port: 1080, fallbackGroup: 'VPN');

    injectByeDpiConfig(rawConfig: cfg, settings: settings, profiles: [ytProfile]);
    final after1Proxies = (cfg['proxies'] as List).length;
    final after1Rules = (cfg['rules'] as List).length;

    injectByeDpiConfig(rawConfig: cfg, settings: settings, profiles: [ytProfile]);
    expect((cfg['proxies'] as List).length, after1Proxies);
    expect((cfg['rules'] as List).length, after1Rules);
  });
}
