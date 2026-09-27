import 'package:fl_clash/common/country_code_cache.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryCodeCache', () {
    test(
      'caches a resolved lookup and never calls fetch again for it',
      () async {
        var calls = 0;
        final cache = CountryCodeCache(
          fetch: (ip) async {
            calls++;
            return const IpInfo(ip: '8.8.8.8', countryCode: 'US');
          },
        );

        final first = await cache.resolve('8.8.8.8');
        final second = await cache.resolve('8.8.8.8');

        expect(first?.countryCode, 'US');
        expect(second?.countryCode, 'US');
        expect(calls, 1);
        expect(cache.containsKey('8.8.8.8'), isTrue);
        expect(cache.peek('8.8.8.8')?.countryCode, 'US');
      },
    );

    test('dedupes concurrent lookups for the same ip into one fetch', () async {
      var calls = 0;
      final cache = CountryCodeCache(
        fetch: (ip) async {
          calls++;
          await Future<void>.delayed(Duration.zero);
          return const IpInfo(ip: '1.1.1.1', countryCode: 'AU');
        },
      );

      final results = await Future.wait([
        cache.resolve('1.1.1.1'),
        cache.resolve('1.1.1.1'),
        cache.resolve('1.1.1.1'),
      ]);

      expect(calls, 1);
      expect(results.every((r) => r?.countryCode == 'AU'), isTrue);
    });

    test('caches a null result (rejected/error) without retrying', () async {
      var calls = 0;
      final cache = CountryCodeCache(
        fetch: (ip) async {
          calls++;
          return null;
        },
      );

      final first = await cache.resolve('2.2.2.2');
      final second = await cache.resolve('2.2.2.2');

      expect(first, isNull);
      expect(second, isNull);
      expect(calls, 1);
      expect(cache.containsKey('2.2.2.2'), isTrue);
    });

    test('a throwing fetch is cached as null instead of crashing', () async {
      final cache = CountryCodeCache(
        fetch: (ip) async => throw Exception('boom'),
      );

      final result = await cache.resolve('3.3.3.3');

      expect(result, isNull);
      expect(cache.containsKey('3.3.3.3'), isTrue);
    });

    test('evicts the oldest entry once maxEntries is reached', () async {
      final cache = CountryCodeCache(
        maxEntries: 2,
        fetch: (ip) async => IpInfo(ip: ip, countryCode: 'US'),
      );

      await cache.resolve('1.1.1.1');
      await cache.resolve('2.2.2.2');
      await cache.resolve('3.3.3.3');

      expect(cache.containsKey('1.1.1.1'), isFalse);
      expect(cache.containsKey('2.2.2.2'), isTrue);
      expect(cache.containsKey('3.3.3.3'), isTrue);
    });
  });
}
