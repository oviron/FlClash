// Wi-Fi SSID permission. On Android 13+ this is NEARBY_WIFI_DEVICES (not
// auto-revoked by App Hibernation, works in background). Below that, falls
// back to ACCESS_FINE_LOCATION (the only API path before Android 13).
// `restricted` folds into permanentlyDenied (policy-blocked, re-asking
// can't lift it).

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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

Future<Permission> _activePermission() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt >= 33) {
      return Permission.nearbyWifiDevices;
    }
  }
  return Permission.locationWhenInUse;
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
    final perm = await _activePermission();
    final status = await perm.status;
    state = _mapStatus(status);
  }

  /// Trigger the system permission dialog and return the new state.
  Future<LocationPermissionState> request() async {
    final perm = await _activePermission();
    final status = await perm.request();
    final mapped = _mapStatus(status);
    state = mapped;
    return mapped;
  }

  bool get isGranted => state == LocationPermissionState.granted;
}
