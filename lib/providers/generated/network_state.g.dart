// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../network_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentNetworkSnapshot)
const currentNetworkSnapshotProvider = CurrentNetworkSnapshotProvider._();

final class CurrentNetworkSnapshotProvider
    extends $NotifierProvider<CurrentNetworkSnapshot, NetworkSnapshot> {
  const CurrentNetworkSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentNetworkSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentNetworkSnapshotHash();

  @$internal
  @override
  CurrentNetworkSnapshot create() => CurrentNetworkSnapshot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkSnapshot>(value),
    );
  }
}

String _$currentNetworkSnapshotHash() =>
    r'26e75141b93219f5ddb21a1ca018e919550db08d';

abstract class _$CurrentNetworkSnapshot extends $Notifier<NetworkSnapshot> {
  NetworkSnapshot build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NetworkSnapshot, NetworkSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkSnapshot, NetworkSnapshot>,
              NetworkSnapshot,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
