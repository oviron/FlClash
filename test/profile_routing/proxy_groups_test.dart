import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = '''
# top comment
proxies:
  - {name: A, type: ss}
  - {name: B, type: vmess}
proxy-groups:
  - name: VPN
    type: load-balance
    strategy: consistent-hashing
    proxies: [A, B]
    url: http://test
    interval: 300
  - name: Sel
    type: select
    proxies: [VPN, DIRECT]
''';

void main() {
  test('proxyGroups + proxyNames read typed fields', () {
    final doc = ProfileRulesDocument(_sample);
    expect(doc.proxyNames, ['A', 'B']);
    final groups = doc.proxyGroups;
    expect(groups.length, 2);
    expect(groups[0].name, 'VPN');
    expect(groups[0].type, 'load-balance');
    expect(groups[0].proxies, ['A', 'B']);
    expect(groups[0].url, 'http://test');
    expect(groups[0].interval, 300);
    expect(groups[0].extraKeys, contains('strategy'));
  });

  test('GroupSpec.create yields a minimal select group', () {
    final g = GroupSpec.create(name: 'New', type: 'select');
    expect(g.name, 'New');
    expect(g.type, 'select');
    expect(g.proxies, isEmpty);
    expect(g.extraKeys, isEmpty);
  });

  test('copyWith edits known fields, preserves unknown keys', () {
    final g = ProfileRulesDocument(_sample).proxyGroups[0];
    final edited = g.copyWith(proxies: ['B'], type: 'select');
    expect(edited.proxies, ['B']);
    expect(edited.type, 'select');
    // strategy is unmodeled but must survive.
    expect(edited.raw['strategy'], 'consistent-hashing');
  });

  test('withProxyGroups round-trips and keeps strategy + other config', () {
    final doc = ProfileRulesDocument(_sample);
    final groups = doc.proxyGroups;
    final out = doc.withProxyGroups([
      groups[0].copyWith(proxies: ['B']),
      groups[1],
    ]);
    expect(out, contains('# top comment'));
    expect(out, contains('name: A')); // proxies block preserved
    final back = ProfileRulesDocument(out).proxyGroups;
    expect(back[0].proxies, ['B']);
    expect(back[0].raw['strategy'], 'consistent-hashing');
    expect(back[1].name, 'Sel');
  });

  test('clearing url removes the key, not the group', () {
    final g = ProfileRulesDocument(_sample).proxyGroups[0];
    final edited = g.copyWith(url: null);
    expect(edited.url, isNull);
    expect(edited.raw.containsKey('url'), isFalse);
    expect(edited.name, 'VPN');
  });
}
