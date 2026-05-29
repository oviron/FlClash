// SSID is location-sensitive: WifiInfo.getSSID() returns "<unknown ssid>"
// without ACCESS_FINE_LOCATION at runtime + the device location toggle on.
// NEARBY_WIFI_DEVICES does not unlock it; locationAlways covers background.

import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/location_permission.g.dart';

enum LocationPermissionState {
  granted,
  denied,
  notDetermined,
  permanentlyDenied,

  /// Permission is held but the device-level location toggle is off, so the
  /// SSID still reads back as `<unknown ssid>`. Distinct because the fix is
  /// "turn on location services", not "grant permission".
  serviceDisabled,
}

const _foreground = Permission.locationWhenInUse;
const _background = Permission.locationAlways;

LocationPermissionState _mapDenied(PermissionStatus status) {
  switch (status) {
    case PermissionStatus.permanentlyDenied:
    case PermissionStatus.restricted:
      return LocationPermissionState.permanentlyDenied;
    default:
      return LocationPermissionState.denied;
  }
}

@Riverpod(keepAlive: true)
class LocationPermission extends _$LocationPermission {
  @override
  LocationPermissionState build() {
    // Reconcile with the OS as soon as the provider is created so the stored
    // value never lags behind a grant made earlier or in system Settings.
    Future.microtask(refresh);
    return LocationPermissionState.notDetermined;
  }

  /// Re-read the OS status. Call after returning from system Settings or on
  /// app resume; build() already calls it once on creation.
  Future<void> refresh() async {
    final status = await _foreground.status;
    if (!(status.isGranted || status.isLimited || status.isProvisional)) {
      state = _mapDenied(status);
      return;
    }
    final service = await _foreground.serviceStatus;
    state = service == ServiceStatus.disabled
        ? LocationPermissionState.serviceDisabled
        : LocationPermissionState.granted;
  }

  /// Trigger the system foreground-permission dialog, then re-evaluate
  /// (which also folds in the location-service toggle).
  Future<LocationPermissionState> request() async {
    await _foreground.request();
    await refresh();
    return state;
  }

  Future<bool> isBackgroundGranted() async {
    return (await _background.status).isGranted;
  }

  /// API <= 29 may grant background in the same dialog; API 30+ forces the
  /// user through system Settings ("Allow all the time").
  Future<bool> requestBackground() async {
    final status = await _background.request();
    return status.isGranted;
  }

  bool get isGranted => state == LocationPermissionState.granted;
}
