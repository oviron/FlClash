import 'package:fl_clash/enum/enum.dart';

/// Whether a background geo refresh should run now: always on a missing or
/// unreadable database, otherwise only when the chosen interval has elapsed
/// since [lastGeoUpdate]. `GeoUpdateInterval.off` disables the scheduled
/// refresh but a missing database is still healed.
bool shouldRefreshGeo({
  required GeoUpdateInterval interval,
  required DateTime? lastGeoUpdate,
  required DateTime now,
  required bool geoMissing,
}) {
  if (geoMissing) return true;
  final duration = interval.duration;
  if (duration == null) return false;
  if (lastGeoUpdate == null) return true;
  return lastGeoUpdate.add(duration).isBefore(now);
}
