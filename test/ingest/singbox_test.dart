import 'dart:convert';

import 'package:fl_clash/ingest/singbox.dart';
import 'package:flutter_test/flutter_test.dart';

const _singbox = '''
{"outbounds":[
  {"type":"shadowsocks","tag":"ss1","server":"1.2.3.4","server_port":8388,"method":"aes-256-gcm","password":"pw"},
  {"type":"vless","tag":"v1","server":"a.com","server_port":443,"uuid":"uuid-1","flow":"xtls-rprx-vision","tls":{"enabled":true,"server_name":"sni.com","reality":{"enabled":true,"public_key":"PBK","short_id":"ab"},"utls":{"enabled":true,"fingerprint":"chrome"}}},
  {"type":"trojan","tag":"t1","server":"b.com","server_port":8443,"password":"tp","tls":{"enabled":true,"server_name":"b.sni"}},
  {"type":"vmess","tag":"vm1","server":"c.com","server_port":10086,"uuid":"uuid-2","alter_id":0,"security":"auto","transport":{"type":"ws","path":"/p","headers":{"Host":"h.com"}}},
  {"type":"hysteria2","tag":"h1","server":"d.com","server_port":9443,"password":"hp","tls":{"enabled":true,"server_name":"d.sni"}},
  {"type":"selector","tag":"select","outbounds":["ss1","v1"]},
  {"type":"direct","tag":"direct"}
]}
''';

void main() {
  group('parseSingbox', () {
    test('converts the five mainstream outbound types, skips the rest', () {
      final out = parseSingbox(jsonDecode(_singbox))!;
      expect(out.map((p) => p['type']).toList(), [
        'ss',
        'vless',
        'trojan',
        'vmess',
        'hysteria2',
      ]);
    });

    test('vless reality + utls fingerprint + vision flow', () {
      final v = parseSingbox(jsonDecode(_singbox))![1];
      expect(v['server'], 'a.com');
      expect(v['port'], 443);
      expect(v['uuid'], 'uuid-1');
      expect(v['tls'], true);
      expect(v['flow'], 'xtls-rprx-vision');
      expect(v['servername'], 'sni.com');
      expect(v['reality-opts'], {'public-key': 'PBK', 'short-id': 'ab'});
      expect(v['client-fingerprint'], 'chrome');
    });

    test('vmess ws transport carries path + Host header', () {
      final vm = parseSingbox(jsonDecode(_singbox))![3];
      expect(vm['network'], 'ws');
      expect(vm['alterId'], 0);
      expect((vm['ws-opts'] as Map)['path'], '/p');
      expect(((vm['ws-opts'] as Map)['headers'] as Map)['Host'], 'h.com');
    });

    test('trojan + hysteria2 carry sni from tls.server_name', () {
      final out = parseSingbox(jsonDecode(_singbox))!;
      expect(out[2]['sni'], 'b.sni');
      expect(out[4]['sni'], 'd.sni');
    });

    test('not a sing-box document -> null (try-parse falls through)', () {
      expect(parseSingbox(jsonDecode('{"servers":[]}')), isNull);
      expect(parseSingbox(jsonDecode('[1,2,3]')), isNull);
    });
  });
}
