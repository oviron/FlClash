import 'package:fl_clash/common/iterable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IterableExt', () {
    test('separated interleaves the separator', () {
      expect([1, 2, 3].separated(0).toList(), [1, 0, 2, 0, 3]);
      expect(<int>[].separated(0), isEmpty);
      expect([1].separated(0).toList(), [1]);
    });

    test('chunks splits with a short tail', () {
      expect([1, 2, 3, 4, 5].chunks(2).toList(), [
        [1, 2],
        [3, 4],
        [5],
      ]);
      expect(<int>[].chunks(3), isEmpty);
    });

    test('fill pads to length and truncates past it', () {
      expect([1].fill(3, filler: (i) => i * 10).toList(), [1, 10, 20]);
      expect([1, 2, 3, 4].fill(2, filler: (i) => 0).toList(), [1, 2]);
    });

    test('takeLast keeps the tail', () {
      expect([1, 2, 3, 4].takeLast(count: 2).toList(), [3, 4]);
      expect([1, 2].takeLast(count: 5).toList(), [1, 2]);
      expect([1, 2].takeLast(count: 0), isEmpty);
    });
  });

  group('ListExt', () {
    test('truncate drops the oldest entries, 0 means unlimited', () {
      final l = [1, 2, 3, 4, 5];
      l.truncate(2);
      expect(l, [4, 5]);
      final unlimited = [1, 2, 3];
      unlimited.truncate(0);
      expect(unlimited, [1, 2, 3]);
    });

    test('batch splits by max concurrency', () {
      expect([1, 2, 3, 4, 5].batch(2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
      expect(<int>[].batch(3), isEmpty);
    });

    test('safeSublist clamps out-of-range bounds', () {
      expect([1, 2, 3].safeSublist(1), [2, 3]);
      expect([1, 2, 3].safeSublist(0), [1, 2, 3]);
      expect([1, 2, 3].safeSublist(5), isEmpty);
      expect([1, 2, 3].safeSublist(1, 99), [2, 3]);
    });

    test('safeGet returns the default outside the range', () {
      expect([1, 2].safeGet(1), 2);
      expect([1, 2].safeGet(2, defaultValue: -1), -1);
      expect([1, 2].safeGet(-1, defaultValue: -1), -1);
    });

    test('addOrRemove toggles membership', () {
      final l = [1];
      l.addOrRemove(2);
      expect(l, [1, 2]);
      l.addOrRemove(2);
      expect(l, [1]);
    });
  });

  group('DoubleListExt.findInterval', () {
    final grid = [0.0, 10.0, 20.0, 30.0];

    test('finds the enclosing interval', () {
      expect(grid.findInterval(0), 0);
      expect(grid.findInterval(9.9), 0);
      expect(grid.findInterval(10), 1);
      expect(grid.findInterval(25), 2);
    });

    test('clamps to the edges', () {
      expect(grid.findInterval(-1), -1);
      expect(grid.findInterval(30), 3);
      expect(grid.findInterval(999), 3);
      expect(<double>[].findInterval(5), -1);
    });
  });

  group('MapExt', () {
    test('updateCacheValue computes once', () {
      final m = <String, int>{};
      var calls = 0;
      int compute() {
        calls++;
        return 42;
      }

      expect(m.updateCacheValue('k', compute), 42);
      expect(m.updateCacheValue('k', compute), 42);
      expect(calls, 1);
    });

    test('copyWitUpdate adds, replaces and removes without mutating', () {
      final m = {'a': 1};
      expect(m.copyWitUpdate('b', 2), {'a': 1, 'b': 2});
      expect(m.copyWitUpdate('a', null), <String, int>{});
      expect(m, {'a': 1});
    });
  });
}
