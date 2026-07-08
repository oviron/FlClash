import 'dart:convert';

import 'package:fl_clash/ingest/xray.dart';
import 'package:flutter_test/flutter_test.dart';

// One xray-JSON array walked by all three iterators. The flat and grouped
// iterators must emit identical proxy bodies (single-walk parity); only the
// naming differs. `direct` outbounds drop out of every mode.
const _sample = '''
[
  {"remarks":"Main","outbounds":[
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"a.example.com","port":443,"users":[{"id":"11111111-1111-1111-1111-111111111111","encryption":"none"}]}]},"streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"PBK","serverName":"sni.example.com","shortId":"ab"}}},
    {"tag":"direct","protocol":"freedom"}
  ]},
  {"remarks":"Anti-block","outbounds":[
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"b.example.com","port":8443,"users":[{"id":"22222222-2222-2222-2222-222222222222"}]}]},"streamSettings":{"network":"ws","security":"tls","tlsSettings":{"serverName":"b.sni","alpn":["h2"]},"wsSettings":{"path":"/ws","host":"b.host"}}}
  ]}
]
''';

Map<String, dynamic> _body(Map<String, dynamic> p) => {...p}..remove('name');

void main() {
  group('unified xray walk', () {
    test('flat and grouped emit identical proxy bodies', () {
      final flat = parseXrayJson(_sample);
      final grouped = parseXrayJsonGroups(_sample);
      final groupedFlat = [for (final g in grouped) ...g.proxies];

      expect(flat.length, 2);
      expect(groupedFlat.length, 2);
      // Same input, one walk: bodies (everything but the name) must match.
      expect(flat.map(_body).toList(), groupedFlat.map(_body).toList());
    });

    test('grouped keeps one group per remark with label-NN names', () {
      final grouped = parseXrayJsonGroups(_sample);
      expect(grouped.map((g) => g.remark).toList(), ['Main', 'Anti-block']);
      expect(grouped[0].proxies.single['name'], 'Main 01');
      expect(grouped[1].proxies.single['name'], 'Anti-block 01');
    });

    test('flat without prefix names by remark; direct is dropped', () {
      final flat = parseXrayJson(_sample);
      expect(flat.map((p) => p['name']).toList(), ['Main', 'Anti-block']);
    });

    test('proxy bodies carry the independently-known vless fields', () {
      final flat = parseXrayJson(_sample);
      final main = flat[0];
      expect(main['type'], 'vless');
      expect(main['server'], 'a.example.com');
      expect(main['port'], 443);
      expect(main['uuid'], '11111111-1111-1111-1111-111111111111');
      expect(main['tls'], true);
      expect((main['reality-opts'] as Map)['public-key'], 'PBK');

      final anti = flat[1];
      expect(anti['server'], 'b.example.com');
      expect(anti['port'], 8443);
      expect(anti['network'], 'ws');
      expect((anti['ws-opts'] as Map)['path'], '/ws');
    });

    test('slug naming yields key-rNN-MM across groups', () {
      final slugged = slugXrayGroups(_sample, 'k');
      expect(slugged.proxies.map((p) => p['name']).toList(), [
        'k-r01-01',
        'k-r02-01',
      ]);
      expect(slugged.remarks.map((r) => r.label).toList(), [
        'Main',
        'Anti-block',
      ]);
      expect(slugged.remarks.map((r) => r.slug).toList(), ['k-r01', 'k-r02']);
    });

    test('non-JSON / non-list / empty never throws', () {
      expect(parseXrayJson('not json'), isEmpty);
      expect(parseXrayJson(jsonEncode({'a': 1})), isEmpty);
      expect(parseXrayJsonGroups(''), isEmpty);
    });
  });
}
