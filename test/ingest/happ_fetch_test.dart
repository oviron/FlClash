import 'package:fl_clash/ingest/happ/happ_fetch.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

// An xray-JSON array of [n] vless nodes, tagged so two equal-count bodies differ.
String _xray(int n, {String tag = ''}) {
  final profiles = [
    for (var i = 0; i < n; i++)
      '{"remarks":"$tag-r$i","outbounds":[{"protocol":"vless","settings":'
          '{"vnext":[{"address":"h$i","port":443,"users":[{"id":"u$i"}]}]},'
          '"streamSettings":{"network":"tcp","security":"tls",'
          '"tlsSettings":{"serverName":"s"}}}]}',
  ];
  return '[${profiles.join(',')}]';
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
  });
}
