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

  group('honest-drop parity with xray_json', () {
    test('vless drops vision flow on a non-tcp network', () {
      final p = parseShareLink(
        'vless://uuid@1.2.3.4:443?security=tls&type=ws&path=%2Fws'
        '&flow=xtls-rprx-vision#n',
      );
      expect(p, isNotNull);
      expect(p!['network'], 'ws');
      expect(p.containsKey('flow'), isFalse);
    });

    test('vless reality with no pbk is dropped', () {
      final p = parseShareLink(
        'vless://uuid@1.2.3.4:443?security=reality&type=tcp&sni=e.com#n',
      );
      expect(p, isNull);
    });

    test('trojan drops vision flow on a non-tcp network', () {
      final p = parseShareLink(
        'trojan://pass@1.2.3.4:443?type=grpc&serviceName=gs'
        '&flow=xtls-rprx-vision#n',
      );
      expect(p, isNotNull);
      expect(p!['network'], 'grpc');
      expect(p.containsKey('flow'), isFalse);
    });
  });

  group('parseShareLink ss legacy base64 form', () {
    test(
      'a fully-base64 blob (no plaintext @) parses cipher/password/host',
      () {
        final p = parseShareLink(
          'ss://${_b64('aes-256-gcm:pass123@1.2.3.4:8388')}#legacy',
        );
        expect(p, isNotNull);
        expect(p!['cipher'], 'aes-256-gcm');
        expect(p['password'], 'pass123');
        expect(p['server'], '1.2.3.4');
        expect(p['port'], 8388);
      },
    );

    test('a base64 blob that decodes without an @ is dropped', () {
      expect(parseShareLink('ss://${_b64('no-at-sign-here')}#x'), isNull);
    });

    test('a legacy blob whose method:pass has no colon is dropped', () {
      expect(parseShareLink('ss://${_b64('methodpass@host:443')}#x'), isNull);
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
      expect(parseShareLink('tuic://x@h:443'), isNull); // no tuic parser yet
      expect(parseShareLink('hysteria2://h:443'), isNull); // no auth userinfo
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

    test(
      'counts recognized-but-unsupported links as skipped, ignores garbage',
      () {
        const body =
            'vless://uuid@1.2.3.4:443?security=tls&type=tcp#a\n'
            'hysteria2://x@h:443#hy\n'
            'tuic://y@h:443#tu\n'
            'plain-garbage-line';
        final res = parseSubscriptionContent(body);
        expect(res.proxies.length, 2); // vless + hysteria2 now parse
        expect(res.skipped, 1); // only tuic recognized-but-unsupported
      },
    );
  });

  group('parseShareLink vless happ-tier transports', () {
    test('xhttp transport carries host + mode, no TLS', () {
      final p = parseShareLink(
        'vless://uuid@host:10443?encryption=none&security=none'
        '&type=xhttp&path=%2Fmy-bucket&host=s3.example&mode=stream-up#x',
      );
      expect(p!['network'], 'xhttp');
      expect(p['tls'], false);
      expect(p['xhttp-opts'], {
        'path': '/my-bucket',
        'mode': 'stream-up',
        'host': 's3.example',
      });
    });

    test('VLESS encryption (ML-KEM) passed through, none ignored', () {
      final p = parseShareLink(
        'vless://uuid@host:443?encryption=mlkem768x25519plus.native.0rtt.BLOB'
        '&security=none&type=xhttp#e',
      );
      expect(p!['encryption'], 'mlkem768x25519plus.native.0rtt.BLOB');
      final none = parseShareLink(
        'vless://uuid@host:443?encryption=none&type=tcp#n',
      );
      expect(none!.containsKey('encryption'), false);
    });

    test('grpc serviceName + alpn', () {
      final p = parseShareLink(
        'vless://uuid@host:443?security=reality&pbk=K&sid=ab&type=grpc'
        '&serviceName=grpc&alpn=h2#g',
      );
      expect(p!['grpc-opts'], {'grpc-service-name': 'grpc'});
      expect(p['alpn'], ['h2']);
    });
  });

  test('parseShareLink hysteria2', () {
    final p = parseShareLink(
      'hysteria2://secret@host.tld:443?sni=h.com&alpn=h3&obfs=salamander'
      '&obfs-password=xyz#hy',
    );
    expect(p!['type'], 'hysteria2');
    expect(p['name'], 'hy');
    expect(p['server'], 'host.tld');
    expect(p['port'], 443);
    expect(p['password'], 'secret');
    expect(p['sni'], 'h.com');
    expect(p['alpn'], ['h3']);
    expect(p['obfs'], 'salamander');
    expect(p['obfs-password'], 'xyz');
  });

  test('parseShareLink vmess grpc serviceName', () {
    final json = jsonEncode({
      'ps': 'vg',
      'add': '1.1.1.1',
      'port': '443',
      'id': 'u',
      'net': 'grpc',
      'path': 'mygrpc',
      'tls': 'tls',
    });
    final p = parseShareLink('vmess://${_b64(json)}');
    expect(p!['network'], 'grpc');
    expect(p['grpc-opts'], {'grpc-service-name': 'mygrpc'});
  });

  test('parseShareLink trojan flow + alpn', () {
    final p = parseShareLink(
      'trojan://pw@host:443?sni=h.com&flow=xtls-rprx-vision&alpn=h2,http%2F1.1#t',
    );
    expect(p!['flow'], 'xtls-rprx-vision');
    expect(p['alpn'], ['h2', 'http/1.1']);
  });
}
