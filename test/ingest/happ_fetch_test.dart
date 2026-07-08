import 'package:fl_clash/ingest/happ/happ_fetch.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

// An xray-JSON array of [n] vless nodes, tagged so two equal-count bodies differ.
String _xray(int n, {String tag = ''}) {
  String node(int i) =>
      '{"remarks":"$tag-r$i","outbounds":[{"protocol":"vless","settings":'
      '{"vnext":[{"address":"h$i","port":443,"users":[{"id":"u$i"}]}]},'
      '"streamSettings":{"network":"tcp","security":"tls",'
      '"tlsSettings":{"serverName":"s"}}}]}';
  return '[${[for (var i = 0; i < n; i++) node(i)].join(',')}]';
}

Future<Map<String, String>> _fakeHapp({Map<String, String>? base}) async => {
  ...?base,
  'User-Agent': 'Happ/3.6.0',
};

bool _isHapp(Map<String, String>? h) => h?['User-Agent'] == 'Happ/3.6.0';

void main() {
  group('HappFetchStrategy dual-fetch', () {
    test('prefers the richer (more proxies) result', () async {
      final s = HappFetchStrategy(
        rawFetch: (url, {headers}) async => (
          body: _xray(_isHapp(headers) ? 5 : 2),
          headers: const <String, String>{},
        ),
        happIdentity: _fakeHapp,
      );
      final res = await s.fetch('https://h/api/sub');
      expect(normalize(res.body).proxies.length, 5);
    });

    test('tie -> honest (no Happ identity leak)', () async {
      final honestBody = _xray(3, tag: 'honest');
      final happBody = _xray(3, tag: 'happ');
      final s = HappFetchStrategy(
        rawFetch: (url, {headers}) async => (
          body: _isHapp(headers) ? happBody : honestBody,
          headers: const <String, String>{},
        ),
        happIdentity: _fakeHapp,
      );
      final res = await s.fetch('https://h/api/sub');
      expect(res.body, honestBody);
    });

    test('one side errors -> the other is used', () async {
      final s = HappFetchStrategy(
        rawFetch: (url, {headers}) async {
          if (_isHapp(headers)) throw Exception('gated fetch failed');
          return (body: _xray(2), headers: const <String, String>{});
        },
        happIdentity: _fakeHapp,
      );
      final res = await s.fetch('https://h/api/sub');
      expect(normalize(res.body).proxies.length, 2);
    });

    test('both sides error -> throws', () async {
      final s = HappFetchStrategy(
        rawFetch: (url, {headers}) async => throw Exception('down'),
        happIdentity: _fakeHapp,
      );
      expect(() => s.fetch('https://h/api/sub'), throwsA(isA<Object>()));
    });

    test('a fuller clash honest body beats a smaller Happ xray body', () async {
      // Panel UA-negotiates: clash to the honest UA, a thinner xray to Happ. The
      // full native clash config must win, not the 2-node xray subset.
      const clashHonest =
          'proxies:\n'
          '  - {name: c1, type: ss, server: h1, port: 1, cipher: aes-128-gcm, password: p}\n'
          '  - {name: c2, type: ss, server: h2, port: 1, cipher: aes-128-gcm, password: p}\n'
          '  - {name: c3, type: ss, server: h3, port: 1, cipher: aes-128-gcm, password: p}\n';
      final s = HappFetchStrategy(
        rawFetch: (url, {headers}) async => (
          body: _isHapp(headers) ? _xray(2) : clashHonest,
          headers: const <String, String>{},
        ),
        happIdentity: _fakeHapp,
      );
      final res = await s.fetch('https://h/sub');
      expect(res.body, clashHonest);
    });
  });
}
