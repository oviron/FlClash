import 'package:fl_clash/ingest/synthesize.dart';
import 'package:fl_clash/ingest/xray.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _group(Map<String, dynamic> config, String name) =>
    (config['proxy-groups'] as List).cast<Map<String, dynamic>>().firstWhere(
      (g) => g['name'] == name,
    );

void main() {
  group('synthesize', () {
    test('flat -> one PROXY url-test over every node', () {
      final config = synthesize((
        proxies: [
          {'name': 'A', 'type': 'ss'},
          {'name': 'B', 'type': 'ss'},
        ],
        groups: null,
        skipped: 0,
      ));
      expect((config['proxies'] as List).length, 2);
      final proxy = _group(config, 'PROXY');
      expect(proxy['type'], 'url-test');
      expect(proxy['proxies'], ['A', 'B']);
      expect(proxy['url'], 'http://cp.cloudflare.com/generate_204');
    });

    test('grouped -> PROXY select over one url-test group per remark', () {
      final config = synthesize((
        proxies: const [],
        groups: <XrayGroup>[
          (
            remark: 'G1',
            proxies: [
              {'name': 'a', 'type': 'ss'},
            ],
          ),
          (
            remark: 'G2',
            proxies: [
              {'name': 'b', 'type': 'ss'},
            ],
          ),
        ],
        skipped: 0,
      ));
      expect((config['proxies'] as List).length, 2);
      final proxy = _group(config, 'PROXY');
      expect(proxy['type'], 'select');
      expect(proxy['proxies'], ['G1', 'G2']);
      expect(_group(config, 'G1')['proxies'], ['a']);
      expect(_group(config, 'G2')['proxies'], ['b']);
    });

    test('flat dedups colliding node names', () {
      final config = synthesize((
        proxies: [
          {'name': 'X', 'type': 'ss'},
          {'name': 'X', 'type': 'ss'},
        ],
        groups: null,
        skipped: 0,
      ));
      final names = (config['proxies'] as List)
          .map((p) => (p as Map)['name'])
          .toList();
      expect(names, ['X', 'X-2']);
    });

    test('a node named PROXY is renamed off the exit-group name', () {
      final config = synthesize((
        proxies: [
          {'name': 'PROXY', 'type': 'ss'},
        ],
        groups: null,
        skipped: 0,
      ));
      final names = (config['proxies'] as List)
          .map((p) => (p as Map)['name'])
          .toList();
      expect(names, ['PROXY-2']);
      expect(_group(config, 'PROXY')['type'], 'url-test');
    });

    test('empty -> ArgumentError, never a config with no exit', () {
      expect(
        () => synthesize((proxies: const [], groups: null, skipped: 0)),
        throwsArgumentError,
      );
    });

    test('urlTestGroup carries the shared health-check literal', () {
      expect(urlTestGroup('N', ['a', 'b']), {
        'name': 'N',
        'type': 'url-test',
        'proxies': ['a', 'b'],
        'url': 'http://cp.cloudflare.com/generate_204',
        'interval': 300,
        'tolerance': 50,
      });
    });
  });
}
