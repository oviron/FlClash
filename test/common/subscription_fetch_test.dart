import 'package:fl_clash/common/subscription_fetch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fetchWithHappFallback', () {
    test('forceHapp fetches as Happ once, never honest', () async {
      final calls = <bool>[];
      final r = await fetchWithHappFallback<String>(
        ({required bool happ}) async {
          calls.add(happ);
          return happ ? 'happ' : 'honest';
        },
        (v) => true,
        forceHapp: true,
      );
      expect(r, 'happ');
      expect(calls, [true]);
    });

    test('honest usable -> returns honest, never escalates to Happ', () async {
      final calls = <bool>[];
      final r = await fetchWithHappFallback<String>(
        ({required bool happ}) async {
          calls.add(happ);
          return happ ? 'happ' : 'good';
        },
        (v) => v == 'good',
        forceHapp: false,
      );
      expect(r, 'good');
      expect(calls, [false]);
    });

    test('honest unusable -> escalates to Happ (honest then happ)', () async {
      final calls = <bool>[];
      final r = await fetchWithHappFallback<String>(
        ({required bool happ}) async {
          calls.add(happ);
          return happ ? 'happ' : 'bad';
        },
        (v) => v != 'bad',
        forceHapp: false,
      );
      expect(r, 'happ');
      expect(calls, [false, true]);
    });
  });
}
