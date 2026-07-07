import 'package:fl_clash/enum/enum.dart';

// Runs on a missing/unreadable DB always; otherwise only after the interval
// elapsed. `off` disables the scheduled refresh but a missing DB is still healed.
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
