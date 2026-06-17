import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/views/profiles/proxy_groups.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = '''
proxy-groups:
  - name: VPN
    type: load-balance
    strategy: consistent-hashing
    exclude-type: ss
    proxies: [A, B]
    url: http://test
    interval: 300
  - name: Filtered
    type: url-test
    filter: (?i)hk|sg
    icon: https://x/icon.png
    proxies: []
    url: http://test
    interval: 300
''';

GroupSpec _spec(int index) =>
    const ProfileRulesDocument(_sample).proxyGroups[index];

void main() {
  group('buildGroupSpec lossless', () {
    test('editing one extra-key value preserves the other unknown keys', () {
      final g = _spec(0);
      final out = buildGroupSpec(
        base: g,
        name: g.name,
        type: g.type,
        members: g.proxies,
        filterMode: false,
        filter: '',
        // user edits `strategy`, leaves `exclude-type` untouched
        extras: {'strategy': 'round-robin', 'exclude-type': 'ss'},
        url: g.url ?? '',
        interval: g.interval?.toString() ?? '',
        lazy: g.lazy,
      );
      expect(out.raw['strategy'], 'round-robin');
      expect(out.raw['exclude-type'], 'ss');
      // managed fields survive too
      expect(out.proxies, ['A', 'B']);
      expect(out.url, 'http://test');
    });

    test('a filter-based group keeps its filter after an unrelated edit', () {
      final g = _spec(1);
      expect(g.raw.containsKey('filter'), isTrue);
      final out = buildGroupSpec(
        base: g,
        name: g.name,
        type: g.type,
        members: g.proxies,
        // filter mode stays on, value unchanged; only members were unrelated
        filterMode: true,
        filter: g.raw['filter'].toString(),
        extras: {'icon': g.raw['icon'].toString()},
        url: g.url ?? '',
        interval: g.interval?.toString() ?? '',
        lazy: g.lazy,
      );
      expect(out.raw['filter'], '(?i)hk|sg');
      expect(out.raw['icon'], 'https://x/icon.png');
    });

    test('clearing filter mode removes only the filter key', () {
      final g = _spec(1);
      final out = buildGroupSpec(
        base: g,
        name: g.name,
        type: g.type,
        members: g.proxies,
        filterMode: false,
        filter: g.raw['filter'].toString(),
        extras: {'icon': g.raw['icon'].toString()},
        url: g.url ?? '',
        interval: g.interval?.toString() ?? '',
        lazy: g.lazy,
      );
      expect(out.raw.containsKey('filter'), isFalse);
      expect(out.raw['icon'], 'https://x/icon.png');
    });

    test('write round-trip preserves filter and other unknown keys', () {
      const doc = ProfileRulesDocument(_sample);
      final filtered = doc.proxyGroups[1];
      final edited = buildGroupSpec(
        base: filtered,
        name: filtered.name,
        type: filtered.type,
        members: filtered.proxies,
        filterMode: true,
        filter: filtered.raw['filter'].toString(),
        extras: {'icon': filtered.raw['icon'].toString()},
        url: filtered.url ?? '',
        interval: filtered.interval?.toString() ?? '',
        lazy: filtered.lazy,
      );
      final out = doc.withProxyGroups([doc.proxyGroups[0], edited]);
      final back = ProfileRulesDocument(out).proxyGroups[1];
      expect(back.raw['filter'], '(?i)hk|sg');
      expect(back.raw['icon'], 'https://x/icon.png');
    });
  });
}
