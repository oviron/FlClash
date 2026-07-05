import 'package:fl_clash/common/xray_json.dart';
import 'package:flutter_test/flutter_test.dart';

/// A govpn-shaped xray-JSON: a list of {remarks, outbounds:[xray-outbound]}.
/// Bucket needles are ASCII here; real profiles pass their own (e.g. Cyrillic)
/// needles as data via `buckets` — substring matching is encoding-agnostic.
const _govpnLike = '''
[
  {"remarks":"Main mode","outbounds":[
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,
      "users":[{"id":"uuid-main-1","flow":"xtls-rprx-vision"}]}]},
      "streamSettings":{"network":"raw","security":"reality",
        "realitySettings":{"serverName":"sni.example","publicKey":"PBK1","shortId":"ab12","fingerprint":"chrome"}}},
    {"tag":"direct","protocol":"freedom"}
  ]},
  {"remarks":"Antiblock LTE","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"2.2.2.2","port":8443,
      "users":[{"id":"uuid-anti-1"}]}]},
      "streamSettings":{"network":"xhttp","security":"reality",
        "realitySettings":{"serverName":"s2.example","publicKey":"PBK2","shortId":12,"fingerprint":"safari"},
        "xhttpSettings":{"path":"/x","mode":"auto"}}}
  ]},
  {"remarks":"GO Hysteria","outbounds":[{"protocol":"hysteria","settings":{}}]}
]
''';

void main() {
  group('parseXrayJson buckets + naming', () {
    test('deterministic prefix-bucket-NN names, vless only', () {
      final ps = parseXrayJson(
        _govpnLike,
        prefix: 'govpn',
        buckets: {
          'antiblock': ['Antiblock'],
          'backup': ['Backup'],
        },
        fingerprint: 'random',
      );
      // Main (1 vless; direct dropped), Antiblock (1 vless), Hysteria dropped.
      expect(ps.map((p) => p['name']), ['govpn-main-01', 'govpn-antiblock-01']);
    });

    test('reality + vision over raw -> tcp with flow kept', () {
      final ps = parseXrayJson(
        _govpnLike,
        prefix: 'govpn',
        buckets: {
          'antiblock': ['Antiblock'],
        },
        fingerprint: 'random',
      );
      final main = ps.firstWhere((p) => p['name'] == 'govpn-main-01');
      expect(main['type'], 'vless');
      expect(main['server'], '1.1.1.1');
      expect(main['port'], 443);
      expect(main['uuid'], 'uuid-main-1');
      expect(main['network'], 'tcp'); // raw -> tcp
      expect(main['udp'], true);
      expect(main['tls'], true);
      expect(main['packet-encoding'], 'xudp');
      expect(main['flow'], 'xtls-rprx-vision'); // kept on tcp
      expect(main['servername'], 'sni.example');
      expect(main['reality-opts'], {'public-key': 'PBK1', 'short-id': 'ab12'});
    });

    test(
      'xhttp -> alpn h2 + xhttp-opts, flow dropped, numeric short-id stringified',
      () {
        final ps = parseXrayJson(
          _govpnLike,
          prefix: 'govpn',
          buckets: {
            'antiblock': ['Antiblock'],
          },
          fingerprint: 'random',
        );
        final anti = ps.firstWhere((p) => p['name'] == 'govpn-antiblock-01');
        expect(anti['network'], 'xhttp');
        expect(anti['alpn'], ['h2']);
        expect(anti['xhttp-opts'], {'path': '/x', 'mode': 'auto'});
        expect(anti.containsKey('flow'), false); // not tcp -> no flow
        expect(anti['reality-opts']['short-id'], '12'); // numeric -> String
      },
    );
  });

  group('parseXrayJson fingerprint policy', () {
    test('random forces client-fingerprint random (ignores upstream)', () {
      final ps = parseXrayJson(
        _govpnLike,
        prefix: 'g',
        buckets: {
          'antiblock': ['Antiblock'],
        },
        fingerprint: 'random',
      );
      for (final p in ps) {
        expect(p['client-fingerprint'], 'random');
      }
    });

    test('upstream passes the node fingerprint through', () {
      final ps = parseXrayJson(
        _govpnLike,
        prefix: 'g',
        buckets: {
          'antiblock': ['Antiblock'],
        },
        fingerprint: 'upstream',
      );
      final main = ps.firstWhere((p) => p['name'] == 'g-main-01');
      final anti = ps.firstWhere((p) => p['name'] == 'g-antiblock-01');
      expect(main['client-fingerprint'], 'chrome');
      expect(anti['client-fingerprint'], 'safari');
    });
  });

  group('parseXrayJson skip semantics', () {
    test('skip needle drops a whole profile (e.g. balancer aggregates)', () {
      const withAggregate = '''
[
  {"remarks":"Auto-select all","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"9.9.9.9","port":443,"users":[{"id":"dup"}]}]},
      "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"P","shortId":"aa"}}}]},
  {"remarks":"Main","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"real"}]}]},
      "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"P","shortId":"aa"}}}]}
]
''';
      final ps = parseXrayJson(
        withAggregate,
        prefix: 'buzz',
        buckets: {
          'skip': ['Auto-select'],
        },
      );
      expect(ps.map((p) => p['uuid']), ['real']);
      expect(ps.single['name'], 'buzz-main-01');
    });

    test('drops non-vless, direct/block/loopback, and empty vnext', () {
      const mixed = '''
[
  {"remarks":"m","outbounds":[
    {"protocol":"shadowsocks","settings":{}},
    {"tag":"block","protocol":"blackhole"},
    {"tag":"loopback","protocol":"loopback"},
    {"protocol":"vless","settings":{"vnext":[]}}
  ]}
]
''';
      expect(parseXrayJson(mixed, prefix: 'x', buckets: {}), isEmpty);
    });
  });

  group('parseXrayJson without prefix (from-URL / UI)', () {
    test('names come from remarks, deduped downstream-friendly', () {
      final ps = parseXrayJson(_govpnLike);
      expect(ps.length, 2); // both vless, hysteria dropped
      expect(ps.every((p) => (p['name'] as String).isNotEmpty), true);
      expect(ps.map((p) => p['type']).toSet(), {'vless'});
    });
  });

  group('parseXrayJson robustness', () {
    test('non-JSON / non-list / empty -> empty list, never throws', () {
      expect(parseXrayJson('not json'), isEmpty);
      expect(
        parseXrayJson('{"proxies":[]}'),
        isEmpty,
      ); // clash object, not a list
      expect(parseXrayJson('[]'), isEmpty);
      expect(parseXrayJson(''), isEmpty);
    });
  });

  group('parseXrayJson reality fidelity', () {
    test('a reality node missing publicKey is dropped, not emitted empty', () {
      const j = '''
[{"remarks":"m","outbounds":[
  {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"u"}]}]},
    "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"shortId":"ab"}}}]}]
''';
      expect(parseXrayJson(j), isEmpty);
    });

    test('servername has no bogus Show fallback (empty when serverName absent)',
        () {
      const j = '''
[{"remarks":"m","outbounds":[
  {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"u"}]}]},
    "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"PBK","Show":true}}}]}]
''';
      final p = parseXrayJson(j).single;
      expect(p['servername'], '');
      expect(p['reality-opts']['public-key'], 'PBK');
    });
  });

  group('parseXrayJson dropUnmatched (allowlist panels)', () {
    const j = '''
[
  {"remarks":"Unknown flavor","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"9.9.9.9","port":443,"users":[{"id":"x"}]}]},
      "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"P","shortId":"aa"}}}]},
  {"remarks":"Antiblock","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"2.2.2.2","port":443,"users":[{"id":"y"}]}]},
      "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"P","shortId":"aa"}}}]}
]
''';

    test('default (denylist) folds an unmatched remark into main', () {
      final ps = parseXrayJson(
        j,
        prefix: 'g',
        buckets: {
          'antiblock': ['Antiblock'],
        },
      );
      expect(ps.map((p) => p['name']), ['g-main-01', 'g-antiblock-01']);
    });

    test('dropUnmatched drops a remark matching no bucket', () {
      final ps = parseXrayJson(
        j,
        prefix: 'g',
        buckets: {
          'antiblock': ['Antiblock'],
        },
        dropUnmatched: true,
      );
      expect(ps.map((p) => p['name']), ['g-antiblock-01']);
    });
  });

  test('xhttp reuseSettings + padding conversion', () {
    const j = '''
[{"remarks":"m","outbounds":[
  {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"u"}]}]},
    "streamSettings":{"network":"xhttp","security":"reality",
      "realitySettings":{"publicKey":"P","shortId":"ab"},
      "xhttpSettings":{"path":"/x","mode":"auto","xPaddingBytes":"100-1000","scMaxEachPostBytes":1000000,
        "reuseSettings":{"maxConcurrency":"10-20","maxConnections":5,"cMaxReuseTimes":0,
          "hMaxRequestTimes":"600-900","hMaxReusableSecs":"1800-3600","hKeepAlivePeriod":0}}}}]}]
''';
    final opts = parseXrayJson(j).single['xhttp-opts'] as Map;
    expect(opts['path'], '/x');
    expect(opts['x-padding-bytes'], '100-1000');
    expect(opts['sc-max-each-post-bytes'], 1000000);
    expect(opts['reuse-settings'], {
      'max-concurrency': '10-20',
      'max-connections': 5,
      'c-max-reuse-times': 0,
      'h-max-request-times': '600-900',
      'h-max-reusable-secs': '1800-3600',
      'h-keep-alive-period': 0,
    });
  });
}
