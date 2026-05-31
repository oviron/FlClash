import 'package:fl_clash/byedpi/strategy_test_cache.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'cache loads valid entries sorted by percent and skips malformed',
    () async {
      final cache = StrategyTestCache(
        read: () async => {
          'bad': {'percent': 100, 'sites': 'not-list'},
          'a': {
            'label': 'A',
            'percent': 20,
            'sites': [
              {'site': 'a.test', 'ok': 0, 'total': 1},
            ],
          },
          'b': {
            'label': 'B',
            'percent': 80,
            'sites': [
              {'site': 'b.test', 'ok': 1, 'total': 1},
            ],
          },
        },
        write: (_) async {},
      );

      final results = await cache.load();

      expect([for (final result in results) result.id], ['b', 'a']);
    },
  );

  test('cache merges and drops entries', () async {
    var raw = <String, dynamic>{};
    final cache = StrategyTestCache(
      read: () async => raw,
      write: (next) async => raw = next,
    );

    await cache.merge([
      const StrategyTestResult(
        id: 'a',
        label: 'A',
        percent: 100,
        success: 1,
        totalRequests: 1,
        sites: [SiteOutcome('a.test', 1, 1)],
      ),
    ]);
    expect(raw.keys, contains('a'));

    await cache.drop({'a'});
    expect(raw, isEmpty);
  });
}
