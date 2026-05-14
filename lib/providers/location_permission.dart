// Foreground-only: no ACCESS_BACKGROUND_LOCATION because the engine only
// reacts while the session is active. `restricted` folds into
// permanentlyDenied (policy-blocked, re-asking can't lift it).

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
