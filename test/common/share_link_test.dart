import 'dart:convert';

import 'package:fl_clash/common/share_link.dart';
import 'package:flutter_test/flutter_test.dart';

String _b64(String s) => base64.encode(utf8.encode(s));

void main() {
  group('parseShareLink vless', () {
    test('reality + vision over tcp', () {
      final p = parseShareLink(
        'vless://b831381d-6324-4d53-ad4f-8cda48b30811@1.2.3.4:443'
        '?encryption=none&security=reality&sni=example.com&fp=chrome'
        '&pbk=PUBKEY&sid=ab12&type=tcp&flow=xtls-rprx-vision#My%20Node',
      );
      expect(p, isNotNull);
      expect(p!['type'], 'vless');
      expect(p['name'], 'My Node');
      expect(p['server'], '1.2.3.4');
      expect(p['port'], 443);
      expect(p['uuid'], 'b831381d-6324-4d53-ad4f-8cda48b30811');
      expect(p['network'], 'tcp');
      expect(p['tls'], true);
      expect(p['flow'], 'xtls-rprx-vision');
      expect(p['servername'], 'example.com');
      expect(p['client-fingerprint'], 'chrome');
      expect(p['reality-opts'], {'public-key': 'PUBKEY', 'short-id': 'ab12'});
    });

    test('tls over ws maps ws-opts and omits reality', () {
      final p = parseShareLink(
        'vless://uuid@host:443?encryption=none&security=tls&sni=h.com'
        '&type=ws&path=%2Fws&host=h.com#ws',
      );
      expect(p!['network'], 'ws');
      expect(p['tls'], true);
      expect(p.containsKey('reality-opts'), false);
      expect(p['ws-opts'], {
        'path': '/ws',
        'headers': {'Host': 'h.com'},
      });
    });
  });

  test('parseShareLink vmess decodes base64 json', () {
    final json = jsonEncode({
      'v': '2',
      'ps': 'vm',
      'add': '1.1.1.1',
      'port': '443',
      'id': 'the-uuid',
      'aid': '0',
      'scy': 'auto',
      'net': 'ws',
      'type': 'none',
      'host': 'h.com',
      'path': '/p',
      'tls': 'tls',
      'sni': 'h.com',
    });
    final p = parseShareLink('vmess://${_b64(json)}');
    expect(p!['type'], 'vmess');
    expect(p['name'], 'vm');
    expect(p['server'], '1.1.1.1');
    expect(p['port'], 443);
    expect(p['uuid'], 'the-uuid');
    expect(p['alterId'], 0);
    expect(p['cipher'], 'auto');
    expect(p['network'], 'ws');
    expect(p['tls'], true);
    expect(p['servername'], 'h.com');
    expect(p['ws-opts'], {
      'path': '/p',
      'headers': {'Host': 'h.com'},
    });
  });

  test('parseShareLink ss (SIP002 base64 userinfo)', () {
    final p = parseShareLink(
      'ss://${_b64('aes-256-gcm:secretpass')}@1.2.3.4:8388#ss-node',
    );
    expect(p!['type'], 'ss');
    expect(p['name'], 'ss-node');
    expect(p['server'], '1.2.3.4');
    expect(p['port'], 8388);
    expect(p['cipher'], 'aes-256-gcm');
    expect(p['password'], 'secretpass');
  });

  group('parseShareLink ss SIP002 plugin', () {
    test('obfs plugin maps to plugin + plugin-opts', () {
      final p = parseShareLink(
        'ss://${_b64('aes-256-gcm:pw')}@1.2.3.4:8388'
        '?plugin=obfs-local%3Bobfs%3Dhttp%3Bobfs-host%3Dexample.com#n',
      );
      expect(p!['plugin'], 'obfs');
      expect(p['plugin-opts'], {'mode': 'http', 'host': 'example.com'});
    });

    test('v2ray-plugin maps mode/host/path/tls', () {
      final p = parseShareLink(
        'ss://${_b64('aes-256-gcm:pw')}@1.2.3.4:8388'
        '?plugin=v2ray-plugin%3Bmode%3Dwebsocket%3Bhost%3Dh.com%3Btls%3Bpath%3D%2Fx#n',
      );
      expect(p!['plugin'], 'v2ray-plugin');
      expect(p['plugin-opts'], {
        'mode': 'websocket',
        'host': 'h.com',
        'path': '/x',
        'tls': true,
      });
    });

    test('an unsupported plugin returns null (honest no-node), not broken', () {
      final p = parseShareLink(
        'ss://${_b64('aes-256-gcm:pw')}@1.2.3.4:8388?plugin=exotic-thing#n',
      );
      expect(p, isNull);
    });

    test('no plugin still parses and carries no plugin keys', () {
      final p = parseShareLink(
        'ss://${_b64('aes-256-gcm:pw')}@1.2.3.4:8388?foo=bar#n',
      );
      expect(p!['type'], 'ss');
      expect(p.containsKey('plugin'), false);
    });
  });

  test('parseShareLink trojan', () {
    final p = parseShareLink(
      'trojan://mypass@host.tld:443?sni=h.com&type=tcp#tj',
    );
    expect(p!['type'], 'trojan');
    expect(p['name'], 'tj');
    expect(p['server'], 'host.tld');
    expect(p['port'], 443);
    expect(p['password'], 'mypass');
    expect(p['sni'], 'h.com');
  });

  group('robustness', () {
    test('returns null for malformed / unknown', () {
      expect(parseShareLink('vless://'), isNull);
      expect(parseShareLink('not-a-scheme'), isNull);
      expect(parseShareLink('vless://uuid@host'), isNull); // no port
      expect(
        parseShareLink('hysteria2://x@h:443'),
        isNull,
      ); // unsupported in v1
    });
  });

  group('parseSubscriptionContent', () {
    test('decodes a base64 blob of multiple links', () {
      final body = _b64(
        'vless://uuid@1.2.3.4:443?security=tls&type=tcp#a\n'
        'trojan://pw@h.tld:443?type=tcp#b\n',
      );
      final res = parseSubscriptionContent(body);
      expect(res.proxies.length, 2);
      expect(res.proxies[0]['type'], 'vless');
      expect(res.proxies[1]['type'], 'trojan');
      expect(res.skipped, 0);
    });

    test('handles a plain newline list and skips garbage', () {
      const body =
          'vless://uuid@1.2.3.4:443?security=tls&type=tcp#a\n'
          '# a comment line\n'
          'trojan://pw@h.tld:443?type=tcp#b';
      expect(parseSubscriptionContent(body).proxies.length, 2);
    });

    test('counts recognized-but-unsupported links as skipped, ignores garbage',
        () {
      const body =
          'vless://uuid@1.2.3.4:443?security=tls&type=tcp#a\n'
          'hysteria2://x@h:443#hy\n'
          'tuic://y@h:443#tu\n'
          'plain-garbage-line';
      final res = parseSubscriptionContent(body);
      expect(res.proxies.length, 1);
      expect(res.skipped, 2);
    });
  });
}
