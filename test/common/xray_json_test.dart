import 'dart:convert';

import 'package:fl_clash/common/xray_json.dart';
import 'package:flutter_test/flutter_test.dart';

/// A govpn-shaped xray-JSON: a list of {remarks, outbounds:[xray-outbound]}.
/// Bucket needles are ASCII here; real profiles pass their own (e.g. Cyrillic)
/// needles as data via `buckets`; substring matching is encoding-agnostic.
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

/// The real heterogeneous GoVPN feed (happ-tier): xhttp+VLESS-Encryption over
/// security:none, grpc+REALITY, ws+TLS, and hysteria2. Field shapes are copied
/// verbatim from a live subscription pull.
const _govpnReal = '''
[
  {"remarks":"Speed","outbounds":[
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"g1.mtscloudstream.com","port":10443,
      "users":[{"id":"UU","encryption":"mlkem768x25519plus.native.0rtt.BLOB","flow":""}]}]},
      "streamSettings":{"network":"xhttp","security":"none",
        "xhttpSettings":{"mode":"stream-up","host":"s3.storage.selcloud.ru","path":"/my-bucket",
          "extra":{"xmux":{"cMaxReuseTimes":"5-10","maxConcurrency":2,"hKeepAlivePeriod":30000,
            "hMaxRequestTimes":"50-100","hMaxReusableSecs":"60-300"}}}}},
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"92.53.64.133","port":443,
      "users":[{"id":"UU","encryption":"none","flow":""}]}]},
      "streamSettings":{"network":"grpc","security":"reality",
        "grpcSettings":{"serviceName":"grpc","authority":"","mode":false},
        "realitySettings":{"serverName":"gos.skystreamgame.com","publicKey":"PBK","shortId":"5c76","fingerprint":"chrome"}}}
  ]},
  {"remarks":"Antiblock","outbounds":[
    {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"s25198.cdn.ngenix.net","port":443,
      "users":[{"id":"UU","encryption":"none","flow":""}]}]},
      "streamSettings":{"network":"ws","security":"tls",
        "wsSettings":{"path":"/v1/data/sync/","host":"","headers":{}},
        "tlsSettings":{"serverName":"","fingerprint":"chrome","alpn":["http/1.1"]}}}
  ]},
  {"remarks":"Backup","outbounds":[
    {"tag":"proxy","protocol":"hysteria","settings":{"address":"31.76.106.66","port":443,"version":2},
      "streamSettings":{"network":"hysteria","hysteriaSettings":{"version":2,"auth":"AUTH"},
        "security":"tls","tlsSettings":{"serverName":"ultimagamest.com","fingerprint":"chrome","alpn":["h3"]}}}
  ]}
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

    test(
      'servername has no bogus Show fallback (empty when serverName absent)',
      () {
        const j = '''
[{"remarks":"m","outbounds":[
  {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"u"}]}]},
    "streamSettings":{"network":"tcp","security":"reality","realitySettings":{"publicKey":"PBK","Show":true}}}]}]
''';
        final p = parseXrayJson(j).single;
        expect(p['servername'], '');
        expect(p['reality-opts']['public-key'], 'PBK');
      },
    );
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

  group('parseXrayJson heterogeneous happ-tier transports', () {
    List<Map<String, dynamic>> real() => parseXrayJson(_govpnReal);
    Map<String, dynamic> byServer(String s) =>
        real().firstWhere((p) => p['server'] == s);

    test('xhttp + security:none + VLESS-Encryption (ML-KEM)', () {
      final p = byServer('g1.mtscloudstream.com');
      expect(p['type'], 'vless');
      expect(p['network'], 'xhttp');
      expect(p['tls'], false); // security: none -> no TLS
      expect(p['encryption'], 'mlkem768x25519plus.native.0rtt.BLOB');
      expect(p.containsKey('alpn'), false); // no TLS -> no alpn
      expect(p.containsKey('reality-opts'), false);
      final opts = p['xhttp-opts'] as Map;
      expect(opts['path'], '/my-bucket');
      expect(opts['mode'], 'stream-up');
      expect(
        opts['host'],
        's3.storage.selcloud.ru',
      ); // fronting Host, was dropped
      // xray>=25 nests mux under extra.xmux (vs the legacy reuseSettings key).
      expect(opts['reuse-settings'], {
        'max-concurrency': '2',
        'max-connections': 0,
        'c-max-reuse-times': '5-10',
        'h-max-request-times': '50-100',
        'h-max-reusable-secs': '60-300',
        'h-keep-alive-period': 30000,
      });
    });

    test('grpc + REALITY carries grpc-service-name', () {
      final p = byServer('92.53.64.133');
      expect(p['network'], 'grpc');
      expect(p['tls'], true);
      expect(p['grpc-opts'], {'grpc-service-name': 'grpc'});
      expect(p['servername'], 'gos.skystreamgame.com');
      expect(p['reality-opts'], {'public-key': 'PBK', 'short-id': '5c76'});
      expect(p['client-fingerprint'], 'chrome'); // upstream default
      expect(p.containsKey('encryption'), false); // "none" is not emitted
    });

    test('ws + TLS carries ws-opts path + alpn', () {
      final p = byServer('s25198.cdn.ngenix.net');
      expect(p['network'], 'ws');
      expect(p['tls'], true);
      expect((p['ws-opts'] as Map)['path'], '/v1/data/sync/');
      // empty host -> no Host header emitted
      expect((p['ws-opts'] as Map).containsKey('headers'), false);
      expect(p['alpn'], ['http/1.1']);
      expect(p.containsKey('reality-opts'), false);
    });

    test('hysteria2 becomes a first-class hysteria2 proxy', () {
      final p = byServer('31.76.106.66');
      expect(p['type'], 'hysteria2');
      expect(p['port'], 443);
      expect(p['password'], 'AUTH');
      expect(p['sni'], 'ultimagamest.com');
      expect(p['alpn'], ['h3']);
      // hysteria2 is QUIC: no vless-only fields
      expect(p.containsKey('uuid'), false);
      expect(p.containsKey('network'), false);
      expect(p.containsKey('client-fingerprint'), false);
    });

    test('all four heterogeneous nodes survive conversion', () {
      expect(real().length, 4);
    });
  });

  group('parseXrayJsonGroups (Happ per-remark-profile grouping)', () {
    test('one group per remark-profile, nodes named by remark', () {
      final groups = parseXrayJsonGroups(_govpnReal);
      expect(groups.map((g) => g.remark), ['Speed', 'Antiblock', 'Backup']);
      expect(groups[0].proxies.length, 2); // xhttp + grpc
      expect(groups[1].proxies.length, 1); // ws
      expect(groups[2].proxies.length, 1); // hysteria2
      expect(groups[0].proxies[0]['name'], 'Speed 01');
      expect(groups[0].proxies[1]['name'], 'Speed 02');
      expect(groups[1].proxies[0]['name'], 'Antiblock 01');
      expect(groups[2].proxies.single['type'], 'hysteria2');
    });

    test('profiles with no convertible nodes are dropped', () {
      const j = '''
[{"remarks":"empty","outbounds":[{"protocol":"shadowsocks","settings":{}}]}]
''';
      expect(parseXrayJsonGroups(j), isEmpty);
    });

    test('non-JSON / non-list -> empty, never throws', () {
      expect(parseXrayJsonGroups('not json'), isEmpty);
      expect(parseXrayJsonGroups('{}'), isEmpty);
    });
  });

  group('slugXrayGroups (embedded provider naming)', () {
    test('renames nodes to a filter-safe index slug per remark', () {
      final s = slugXrayGroups(_govpnReal, 'govpn');
      expect(s.proxies.map((p) => p['name']).toList(), [
        'govpn-r01-01',
        'govpn-r01-02',
        'govpn-r02-01',
        'govpn-r03-01',
      ]);
      expect(s.remarks.map((r) => (r.label, r.slug, r.count)).toList(), [
        ('Speed', 'govpn-r01', 2),
        ('Antiblock', 'govpn-r02', 1),
        ('Backup', 'govpn-r03', 1),
      ]);
    });

    test('preserves node transport fields (only the name changes)', () {
      final s = slugXrayGroups(_govpnReal, 'govpn');
      expect(s.proxies[3]['type'], 'hysteria2'); // Backup node
    });

    test('non-JSON / non-list -> empty proxies and remarks', () {
      final s = slugXrayGroups('not json', 'govpn');
      expect(s.proxies, isEmpty);
      expect(s.remarks, isEmpty);
    });
  });

  group('injectRemarkGroups (embedded per-remark groups)', () {
    const remarks = [
      (label: 'Speed', slug: 'govpn-r01', count: 2),
      (label: 'Antiblock', slug: 'govpn-r02', count: 1),
      (label: 'Backup', slug: 'govpn-r03', count: 1),
    ];

    Map<String, dynamic> baseConfig() => {
      'proxy-groups': <dynamic>[
        {
          'name': 'Go',
          'type': 'url-test',
          'use': ['govpn'],
          'url': 'http://cp/generate_204',
          'interval': 90,
          'tolerance': 50,
          'lazy': true,
        },
        {
          'name': 'VPN',
          'type': 'select',
          'proxies': ['Go', 'DIRECT'],
        },
      ],
    };

    test('rewires the clean parent to a select over per-remark groups', () {
      final config = baseConfig();
      injectRemarkGroups(config, 'govpn', remarks);
      final groups = (config['proxy-groups'] as List)
          .cast<Map<String, dynamic>>();
      final go = groups.firstWhere((g) => g['name'] == 'Go');
      expect(go['type'], 'select');
      expect(go['proxies'], ['Speed', 'Antiblock', 'Backup']);
      expect(go.containsKey('use'), isFalse);
      expect(go.containsKey('filter'), isFalse);
      expect(go.containsKey('interval'), isFalse);
    });

    test('appends one hidden url-test group per remark, slug filter + '
        'inherited health check', () {
      final config = baseConfig();
      injectRemarkGroups(config, 'govpn', remarks);
      final groups = (config['proxy-groups'] as List)
          .cast<Map<String, dynamic>>();
      final speed = groups.firstWhere((g) => g['name'] == 'Speed');
      expect(speed['type'], 'url-test');
      expect(speed['use'], ['govpn']);
      expect(speed['filter'], '^govpn-r01-');
      expect(speed['interval'], 90);
      expect(speed['tolerance'], 50);
      expect(speed['lazy'], true);
      expect(speed['hidden'], isTrue); // drill-down under the parent select
      expect(
        groups.map((g) => g['name']),
        containsAll(['Antiblock', 'Backup']),
      );
    });

    test('no clean parent (author filter) -> config unchanged', () {
      final config = {
        'proxy-groups': <dynamic>[
          {
            'name': 'Go',
            'type': 'url-test',
            'use': ['govpn'],
            'filter': 'x',
          },
        ],
      };
      final before = jsonEncode(config);
      injectRemarkGroups(config, 'govpn', remarks);
      expect(jsonEncode(config), before);
    });

    test('dedups a display name that collides with an existing group', () {
      final config = {
        'proxy-groups': <dynamic>[
          {
            'name': 'Speed',
            'type': 'select',
            'proxies': ['DIRECT'],
          },
          {
            'name': 'Go',
            'type': 'url-test',
            'use': ['govpn'],
            'interval': 90,
          },
        ],
      };
      injectRemarkGroups(config, 'govpn', remarks);
      final groups = (config['proxy-groups'] as List)
          .cast<Map<String, dynamic>>();
      final names = groups.map((g) => g['name']).toList();
      expect(names, containsAll(['Speed', 'Speed (2)', 'Antiblock', 'Backup']));
      final go = groups.firstWhere((g) => g['name'] == 'Go');
      expect(go['proxies'], contains('Speed (2)'));
    });
  });
}
