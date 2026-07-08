import 'dart:convert';

import 'package:fl_clash/ingest/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

const _xrayArray = '''
[
  {"remarks":"Main","outbounds":[
    {"tag":"p","protocol":"vless","settings":{"vnext":[{"address":"a.com","port":443,"users":[{"id":"u1"}]}]},"streamSettings":{"network":"tcp","security":"tls","tlsSettings":{"serverName":"s"}}}
  ]}
]
''';

// v2rayN single xray config: outbounds at top level, not wrapped per-remark.
const _xrayObject = '''
{"outbounds":[
  {"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"b.com","port":8443,"users":[{"id":"u2"}]}]},"streamSettings":{"network":"ws","security":"tls","tlsSettings":{"serverName":"s2"},"wsSettings":{"path":"/w"}}},
  {"tag":"direct","protocol":"freedom"}
]}
''';

const _sip008 =
    '{"servers":[{"remarks":"S","server":"1.2.3.4","server_port":8388,"method":"aes-256-gcm","password":"pw"}]}';

const _singbox =
    '{"outbounds":[{"type":"trojan","tag":"t","server":"c.com","server_port":443,"password":"tp","tls":{"enabled":true,"server_name":"c.sni"}}]}';

void main() {
  group('normalize try-parse', () {
    test('single share link -> one proxy, no groups', () {
      final n = normalize('trojan://pw@h.com:443#Node');
      expect(n.proxies.length, 1);
      expect(n.proxies.single['type'], 'trojan');
      expect(n.groups, isNull);
    });

    test('newline list of share links -> many proxies', () {
      final n = normalize(
        'trojan://a@h1:443#A\nvless://u@h2:443?security=tls#B',
      );
      expect(n.proxies.length, 2);
    });

    test('base64 blob of share links decodes and parses', () {
      final blob = base64.encode(
        utf8.encode('trojan://a@h1:443#A\ntrojan://b@h2:443#B'),
      );
      final n = normalize(blob);
      expect(n.proxies.length, 2);
    });

    test('xray-JSON array -> grouped', () {
      final n = normalize(_xrayArray);
      expect(n.groups, isNotNull);
      expect(n.groups!.single.remark, 'Main');
      expect(n.proxies.length, 1);
    });

    test('xray-JSON object (v2rayN) -> flat proxies, no groups', () {
      final n = normalize(_xrayObject);
      expect(n.groups, isNull);
      expect(n.proxies.length, 1); // direct dropped
      expect(n.proxies.single['server'], 'b.com');
      expect(n.proxies.single['network'], 'ws');
    });

    test('SIP008 -> ss proxies', () {
      final n = normalize(_sip008);
      expect(n.groups, isNull);
      expect(n.proxies.single['type'], 'ss');
      expect(n.proxies.single['server'], '1.2.3.4');
    });

    test('sing-box -> proxies', () {
      final n = normalize(_singbox);
      expect(n.proxies.single['type'], 'trojan');
      expect(n.proxies.single['sni'], 'c.sni');
    });

    test('clash YAML / http URL / garbage -> empty (caller boundary)', () {
      expect(normalize('proxies:\n  - name: x').proxies, isEmpty);
      expect(normalize('https://example.com/sub.yaml').proxies, isEmpty);
      expect(normalize('just some text').proxies, isEmpty);
      expect(normalize('').proxies, isEmpty);
    });
  });

  group('boundary predicates', () {
    test('isSubscriptionUrl: single-line http(s) only, not share links', () {
      expect(isSubscriptionUrl('https://h/sub'), isTrue);
      expect(isSubscriptionUrl('http://h/sub'), isTrue);
      expect(isSubscriptionUrl('vless://u@h:443'), isFalse);
      expect(isSubscriptionUrl('https://h/a\nhttps://h/b'), isFalse);
      expect(isSubscriptionUrl('not a url'), isFalse);
    });

    test('isClashDocument: a proxies:/proxy-groups: YAML block', () {
      expect(isClashDocument('proxies:\n  - name: x'), isTrue);
      expect(isClashDocument('proxy-groups:\n  - name: g'), isTrue);
      expect(isClashDocument('vless://u@h:443'), isFalse);
      expect(isClashDocument('{"proxies":[]}'), isFalse);
    });

    test('isIngestable: url, clash, or any normalizable content', () {
      expect(isIngestable('https://h/sub'), isTrue);
      expect(isIngestable('proxies:\n  - name: x'), isTrue);
      expect(isIngestable('trojan://p@h:443#n'), isTrue);
      expect(isIngestable('hello world'), isFalse);
    });
  });
}
