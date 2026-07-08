import 'package:fl_clash/ingest/happ/happ_resolver.dart';
import 'package:fl_clash/ingest/pipeline.dart';
import 'package:fl_clash/ingest/registry.dart';
import 'package:flutter_test/flutter_test.dart';

// 5 remark-profiles, 11 vless nodes total: mirrors the real cloVPN /api/sub.
String _panelXray() {
  final counts = [3, 2, 2, 2, 2];
  final profiles = <String>[];
  for (var g = 0; g < counts.length; g++) {
    final nodes = [
      for (var i = 0; i < counts[g]; i++)
        '{"protocol":"vless","settings":{"vnext":[{"address":"h$g$i","port":443,'
            '"users":[{"id":"u$g$i"}]}]},"streamSettings":{"network":"tcp",'
            '"security":"tls","tlsSettings":{"serverName":"s"}}}',
    ];
    profiles.add('{"remarks":"Group$g","outbounds":[${nodes.join(',')}]}');
  }
  return '[${profiles.join(',')}]';
}

// Serves an HTML launcher at /happ and the real xray subscription at /api/sub.
class _FakePanel implements FetchStrategy {
  @override
  Future<FetchResult> fetch(String url, {Map<String, String>? headers}) async {
    if (url.contains('/api/sub')) {
      return (
        body: _panelXray(),
        headers: const {'subscription-userinfo': 'upload=1; total=100'},
      );
    }
    return (
      body: '<html>open in Happ</html>',
      headers: const <String, String>{},
    );
  }
}

class _NeverFetch implements FetchStrategy {
  @override
  Future<FetchResult> fetch(String url, {Map<String, String>? headers}) async {
    fail('fetch must not run for inline content');
  }
}

void main() {
  setUp(resetIngestRegistry);

  test(
    'Happ module on: /happ?token resolves to /api/sub -> 5 groups / 11 nodes',
    () async {
      registerResolver(HappResolver());
      registerFetchStrategy(_FakePanel());

      final res = await ingest('https://links.clovpn.org/happ?token=x');
      expect(res.normalized.groups!.length, 5);
      expect(res.normalized.proxies.length, 11);
      expect(res.meta.userinfo, contains('total=100'));
    },
  );

  test(
    'Happ module off: /happ is fetched raw -> HTML -> empty (fails cleanly)',
    () async {
      registerFetchStrategy(_FakePanel()); // core only, no resolver

      final res = await ingest('https://links.clovpn.org/happ?token=x');
      expect(res.normalized.proxies, isEmpty);
      expect(res.normalized.groups, isNull);
    },
  );

  test('inline share link normalizes without any fetch', () async {
    registerFetchStrategy(_NeverFetch());

    final res = await ingest('vless://u@h:443?security=tls#n');
    expect(res.normalized.proxies.length, 1);
  });
}
