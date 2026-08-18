import 'package:fl_clash/common/indexing.dart';
import 'package:flutter_test/flutter_test.dart';

// Fractional order keys back profile reordering in the database; a broken key
// silently scrambles the profile list, so the invariants are pinned here.
void main() {
  group('generateKeyBetween', () {
    test('first ever key is integerZero', () {
      expect(indexing.generateKeyBetween(null, null), 'a0');
    });

    test('appending after a key sorts strictly higher', () {
      final next = indexing.generateKeyBetween('a0', null)!;
      expect(next.compareTo('a0'), greaterThan(0));
    });

    test('prepending before a key sorts strictly lower', () {
      final prev = indexing.generateKeyBetween(null, 'a0')!;
      expect(prev.compareTo('a0'), lessThan(0));
    });

    test('a key between two keys sorts strictly between them', () {
      const a = 'a0';
      final b = indexing.generateKeyBetween(a, null)!;
      final mid = indexing.generateKeyBetween(a, b)!;
      expect(mid.compareTo(a), greaterThan(0));
      expect(mid.compareTo(b), lessThan(0));
    });

    test('repeated in-between insertion never collides', () {
      const low = 'a0';
      final high = indexing.generateKeyBetween(low, null)!;
      final seen = <String>{low, high};
      var upper = high;
      for (var i = 0; i < 50; i++) {
        final mid = indexing.generateKeyBetween(low, upper)!;
        expect(seen.add(mid), isTrue, reason: 'duplicate key $mid');
        expect(mid.compareTo(low), greaterThan(0));
        expect(mid.compareTo(upper), lessThan(0));
        upper = mid;
      }
    });

    test(
      'repeated append stays monotonic across the integer-length rollover',
      () {
        String? prev;
        final keys = <String>[];
        for (var i = 0; i < 1000; i++) {
          prev = indexing.generateKeyBetween(prev, null)!;
          keys.add(prev);
        }
        final sorted = [...keys]..sort();
        expect(keys, sorted);
      },
    );

    test('equal or inverted bounds throw', () {
      expect(() => indexing.generateKeyBetween('a1', 'a1'), throwsException);
      expect(() => indexing.generateKeyBetween('a2', 'a1'), throwsException);
    });
  });

  group('generateNKeysBetween', () {
    test('n keys in open space are sorted and unique', () {
      final keys = indexing.generateNKeysBetween(null, null, 5);
      expect(keys.length, 5);
      final list = keys.cast<String>();
      final sorted = [...list]..sort();
      expect(list, sorted);
      expect(list.toSet().length, 5);
    });

    test('n keys between bounds stay inside the bounds', () {
      final keys = indexing.generateNKeysBetween('a0', 'a1', 7).cast<String>();
      for (final k in keys) {
        expect(k.compareTo('a0'), greaterThan(0));
        expect(k.compareTo('a1'), lessThan(0));
      }
      final sorted = [...keys]..sort();
      expect(keys, sorted);
    });

    test('zero or negative n yields nothing', () {
      expect(indexing.generateNKeysBetween(null, null, 0), isEmpty);
      expect(indexing.generateNKeysBetween(null, null, -3), isEmpty);
    });
  });
}
