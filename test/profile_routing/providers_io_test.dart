import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _yaml = '''
# top comment
mixed-port: 7890
proxy-providers:
  govpn:
    type: http
    url: "https://example.com/sub"
    interval: 86400
    size-limit: 0
    health-check:
      enable: true
      url: http://cp.cloudflare.com
      interval: 300
rule-providers:
  ads:
    type: http
    behavior: domain
    format: mrs
    url: "https://example.com/ads.mrs"
    interval: 43200
rules:
  - MATCH,DIRECT
''';

void main() {
  group('ProviderSpec', () {
    test('typed accessors plus lossless unknown keys', () {
      final node =
          loadYaml('''
type: http
url: u
interval: 100
behavior: domain
format: mrs
size-limit: 5
''')
              as YamlMap;
      final s = ProviderSpec.fromYaml(node);
      expect(s.type, 'http');
      expect(s.url, 'u');
      expect(s.interval, 100);
      expect(s.behavior, 'domain');
      expect(s.format, 'mrs');
      expect(s.extraKeys, contains('size-limit'));
      expect(s.raw['size-limit'], 5);
    });

    test('copyWith sets and clears', () {
      final s = ProviderSpec.create(
        type: 'http',
      ).copyWith(url: 'u', interval: 10);
      expect(s.url, 'u');
      expect(s.interval, 10);
      final cleared = s.copyWith(url: null);
      expect(cleared.url, isNull);
      expect(cleared.raw.containsKey('url'), isFalse);
    });
  });

  group('ProfileRulesDocument providers', () {
    final doc = ProfileRulesDocument(_yaml);

    test('reads proxy-providers and rule-providers', () {
      expect(doc.proxyProviders.keys, ['govpn']);
      expect(doc.proxyProviders['govpn']!.type, 'http');
      expect(doc.proxyProviders['govpn']!.healthCheck?['enable'], true);
      expect(doc.ruleProviders['ads']!.behavior, 'domain');
      expect(doc.ruleProviders['ads']!.format, 'mrs');
    });

    test(
      'withProxyProviders round-trips, preserving siblings and unknowns',
      () {
        final updated = doc.proxyProviders['govpn']!.copyWith(interval: 1000);
        final out = doc.withProxyProviders({'govpn': updated});
        final re = ProfileRulesDocument(out);
        expect(re.proxyProviders['govpn']!.interval, 1000);
        expect(re.proxyProviders['govpn']!.raw['size-limit'], 0);
        expect(out, contains('mixed-port: 7890'));
        expect(re.rules.length, 1);
        expect(re.ruleProviders.keys, ['ads']);
      },
    );

    test('withRuleProviders with an empty map removes the key', () {
      final out = doc.withRuleProviders({});
      expect(ProfileRulesDocument(out).ruleProviders, isEmpty);
      expect(out, isNot(contains('rule-providers:')));
    });
  });
}
