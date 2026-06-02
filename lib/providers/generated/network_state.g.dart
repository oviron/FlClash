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

/// Latest decision + reason pushed by the resident service, for the editor's
/// "current network -> decision" status line.

@ProviderFor(LastNetworkRuleStatus)
const lastNetworkRuleStatusProvider = LastNetworkRuleStatusProvider._();

/// Latest decision + reason pushed by the resident service, for the editor's
/// "current network -> decision" status line.
final class LastNetworkRuleStatusProvider
    extends $NotifierProvider<LastNetworkRuleStatus, NetworkRuleStatus?> {
  /// Latest decision + reason pushed by the resident service, for the editor's
  /// "current network -> decision" status line.
  const LastNetworkRuleStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastNetworkRuleStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastNetworkRuleStatusHash();

  @$internal
  @override
  LastNetworkRuleStatus create() => LastNetworkRuleStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkRuleStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkRuleStatus?>(value),
    );
  }
}

String _$lastNetworkRuleStatusHash() =>
    r'8abc2ae6497d999c1911a9f7fd8ef1a731c153dd';

/// Latest decision + reason pushed by the resident service, for the editor's
/// "current network -> decision" status line.

abstract class _$LastNetworkRuleStatus extends $Notifier<NetworkRuleStatus?> {
  NetworkRuleStatus? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NetworkRuleStatus?, NetworkRuleStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkRuleStatus?, NetworkRuleStatus?>,
              NetworkRuleStatus?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
