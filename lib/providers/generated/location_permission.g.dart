// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../location_permission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationPermission)
const locationPermissionProvider = LocationPermissionProvider._();

final class LocationPermissionProvider
    extends $NotifierProvider<LocationPermission, LocationPermissionState> {
  const LocationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionHash();

  @$internal
  @override
  LocationPermission create() => LocationPermission();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationPermissionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationPermissionState>(value),
    );
  }
}

String _$locationPermissionHash() =>
    r'd60509c8dc164c959a181659e7e2010fc7f0b89a';

abstract class _$LocationPermission extends $Notifier<LocationPermissionState> {
  LocationPermissionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<LocationPermissionState, LocationPermissionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationPermissionState, LocationPermissionState>,
              LocationPermissionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
