// Network Rules v1: foreground-only location permission state.
//
// Android 10+ requires ACCESS_FINE_LOCATION to read the current Wi-Fi SSID.
// We do NOT request ACCESS_BACKGROUND_LOCATION: the rules engine reacts to
// connectivity changes only while the app session is active, so foreground
// is enough. The provider exposes a four-state machine the UI can branch on:
//
//   * granted            => SSID reads work, name-rules are usable
//   * denied             => user said no but can still be re-prompted
//   * notDetermined      => not yet asked, request() will pop the system dialog
//   * permanentlyDenied  => user picked "Don't ask again" or device policy
//                           blocks it; only Settings can flip it
//
// Mapping rationale:
//   * `provisional` (iOS-only) and `limited` are sufficient for our SSID read,
//     so we treat them as `granted` rather than nudging the user.
//   * `restricted` (corporate / parental policy) cannot be lifted by re-asking,
//     so it folds into `permanentlyDenied`.

import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/location_permission.g.dart';

enum LocationPermissionState {
  granted,
  denied,
  notDetermined,
  permanentlyDenied,
}

LocationPermissionState _mapStatus(PermissionStatus status) {
  switch (status) {
    case PermissionStatus.granted:
    case PermissionStatus.provisional:
    case PermissionStatus.limited:
      return LocationPermissionState.granted;
    case PermissionStatus.denied:
      return LocationPermissionState.denied;
    case PermissionStatus.permanentlyDenied:
    case PermissionStatus.restricted:
      return LocationPermissionState.permanentlyDenied;
  }
}

@Riverpod(keepAlive: true)
class LocationPermission extends _$LocationPermission {
  @override
  LocationPermissionState build() {
    // Synchronous initial value so widgets do not have to handle AsyncValue
    // on first frame. The actual status comes from refresh() which the UI
    // is expected to call once after mount.
    return LocationPermissionState.notDetermined;
  }

  /// Re-read the current OS-level status and update [state]. Call this after
  /// returning from system Settings (the user may have toggled the toggle
  /// without going through our flow) or once on app startup if the UI cares.
  Future<void> refresh() async {
    final status = await Permission.locationWhenInUse.status;
    state = _mapStatus(status);
  }

  /// Trigger the system permission dialog and return the new state.
  Future<LocationPermissionState> request() async {
    final status = await Permission.locationWhenInUse.request();
    final mapped = _mapStatus(status);
    state = mapped;
    return mapped;
  }

  bool get isGranted => state == LocationPermissionState.granted;
}
