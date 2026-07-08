import 'dart:convert';

import 'package:fl_clash/ingest/sip008.dart';
import 'package:flutter_test/flutter_test.dart';

const _sip008 = '''
{"version":1,"servers":[
  {"id":"1","remarks":"US","server":"1.2.3.4","server_port":8388,"password":"pw","method":"aes-256-gcm"},
  {"id":"2","server":"5.6.7.8","server_port":8389,"password":"pw2","method":"chacha20-ietf-poly1305","plugin":"obfs-local","plugin_opts":"obfs=http;obfs-host=bing.com"}
]}
''';

void main() {
  group('parseSip008', () {
    test('maps servers[] to ss proxies with method/password', () {
      final out = parseSip008(jsonDecode(_sip008))!;
      expect(out.length, 2);
      expect(out[0], {
        'name': 'US',
        'type': 'ss',
        'server': '1.2.3.4',
        'port': 8388,
        'cipher': 'aes-256-gcm',
        'password': 'pw',
        'udp': true,
      });
    });

    test('reconstructs the SIP003 plugin from plugin + plugin_opts', () {
      final out = parseSip008(jsonDecode(_sip008))!;
      final obfs = out[1];
      expect(obfs['name'], '5.6.7.8'); // no remarks -> server host
      expect(obfs['plugin'], 'obfs');
      expect(obfs['plugin-opts'], {'mode': 'http', 'host': 'bing.com'});
    });

    test('not a SIP008 document -> null (try-parse falls through)', () {
      expect(parseSip008(jsonDecode('{"outbounds":[]}')), isNull);
      expect(parseSip008(jsonDecode('[1,2,3]')), isNull);
    });

    test('a server missing method/port is skipped, not emitted broken', () {
      final out = parseSip008(
        jsonDecode('{"servers":[{"server":"h","server_port":0,"method":"x"}]}'),
      )!;
      expect(out, isEmpty);
    });
  });
}
