// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../recent_ssids.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentSsids)
const recentSsidsProvider = RecentSsidsProvider._();

final class RecentSsidsProvider
    extends $NotifierProvider<RecentSsids, List<String>> {
  const RecentSsidsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSsidsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSsidsHash();

  @$internal
  @override
  RecentSsids create() => RecentSsids();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$recentSsidsHash() => r'e4ad960bea777a5d2a37d4570a901012c2de5657';

abstract class _$RecentSsids extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
