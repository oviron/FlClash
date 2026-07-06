import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/effects/geo_refresh_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 6, 12);

  group('GeoUpdateInterval.duration', () {
    test('off has no duration', () {
      expect(GeoUpdateInterval.off.duration, isNull);
    });
    test('presets map to their periods', () {
      expect(GeoUpdateInterval.daily.duration, const Duration(days: 1));
      expect(GeoUpdateInterval.every3Days.duration, const Duration(days: 3));
      expect(GeoUpdateInterval.weekly.duration, const Duration(days: 7));
    });
  });

  group('shouldRefreshGeo', () {
    test('missing database always refreshes, even when off', () {
      expect(
        shouldRefreshGeo(
          interval: GeoUpdateInterval.off,
          lastGeoUpdate: now,
          now: now,
          geoMissing: true,
        ),
        isTrue,
      );
    });

    test('off with a present database never refreshes', () {
      expect(
        shouldRefreshGeo(
          interval: GeoUpdateInterval.off,
          lastGeoUpdate: null,
          now: now,
          geoMissing: false,
        ),
        isFalse,
      );
    });

    test('first run (never updated) refreshes on any interval', () {
      expect(
        shouldRefreshGeo(
          interval: GeoUpdateInterval.weekly,
          lastGeoUpdate: null,
          now: now,
          geoMissing: false,
        ),
        isTrue,
      );
    });

    test('within the interval does not refresh', () {
      expect(
        shouldRefreshGeo(
          interval: GeoUpdateInterval.weekly,
          lastGeoUpdate: now.subtract(const Duration(days: 2)),
          now: now,
          geoMissing: false,
        ),
        isFalse,
      );
    });

    test('past the interval refreshes', () {
      expect(
        shouldRefreshGeo(
          interval: GeoUpdateInterval.daily,
          lastGeoUpdate: now.subtract(const Duration(days: 2)),
          now: now,
          geoMissing: false,
        ),
        isTrue,
      );
    });
  });
}
