import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/strategy_test_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remove saves list without removed strategy', () async {
    var saved = <ByeDpiStrategy>[];
    final store = StrategyTestStore(
      load: () async => const [
        ByeDpiStrategy(id: 'a', label: 'A', args: ''),
        ByeDpiStrategy(id: 'b', label: 'B', args: ''),
      ],
      save: (strategies) async => saved = strategies,
      reset: () async {},
    );

    final kept = await store.remove('a');

    expect([for (final strategy in kept) strategy.id], ['b']);
    expect([for (final strategy in saved) strategy.id], ['b']);
  });

  test('pruneBelow removes tested low performers and keeps untested', () async {
    var saved = <ByeDpiStrategy>[];
    final store = StrategyTestStore(
      load: () async => const [
        ByeDpiStrategy(id: 'good', label: 'Good', args: ''),
        ByeDpiStrategy(id: 'bad', label: 'Bad', args: ''),
        ByeDpiStrategy(id: 'untested', label: 'Untested', args: ''),
      ],
      save: (strategies) async => saved = strategies,
      reset: () async {},
    );

    final result = await store.pruneBelow(
      testedPercentById: {'good': 90, 'bad': 20},
      percent: 40,
    );

    expect(result.removedIds, {'bad'});
    expect(
      [for (final strategy in result.kept) strategy.id],
      ['good', 'untested'],
    );
    expect(saved, result.kept);
  });
}
