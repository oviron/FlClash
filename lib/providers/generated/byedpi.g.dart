// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../byedpi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ByeDpiSettingsNotifier)
const byeDpiSettingsProvider = ByeDpiSettingsNotifierProvider._();

final class ByeDpiSettingsNotifierProvider
    extends $NotifierProvider<ByeDpiSettingsNotifier, ByeDpiSettings> {
  const ByeDpiSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byeDpiSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byeDpiSettingsNotifierHash();

  @$internal
  @override
  ByeDpiSettingsNotifier create() => ByeDpiSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ByeDpiSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ByeDpiSettings>(value),
    );
  }
}

String _$byeDpiSettingsNotifierHash() =>
    r'04f86d4b0cec47c67e2bcaf06fe8b28ebf97a325';

abstract class _$ByeDpiSettingsNotifier extends $Notifier<ByeDpiSettings> {
  ByeDpiSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ByeDpiSettings, ByeDpiSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ByeDpiSettings, ByeDpiSettings>,
              ByeDpiSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(bypassProfilesStream)
const bypassProfilesStreamProvider = BypassProfilesStreamProvider._();

final class BypassProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BypassProfile>>,
          List<BypassProfile>,
          Stream<List<BypassProfile>>
        >
    with
        $FutureModifier<List<BypassProfile>>,
        $StreamProvider<List<BypassProfile>> {
  const BypassProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bypassProfilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bypassProfilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<BypassProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BypassProfile>> create(Ref ref) {
    return bypassProfilesStream(ref);
  }
}

String _$bypassProfilesStreamHash() =>
    r'a791c28df0391fdee41863aa8f9784737628d919';

@ProviderFor(bypassProfilesOnce)
const bypassProfilesOnceProvider = BypassProfilesOnceProvider._();

final class BypassProfilesOnceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BypassProfile>>,
          List<BypassProfile>,
          FutureOr<List<BypassProfile>>
        >
    with
        $FutureModifier<List<BypassProfile>>,
        $FutureProvider<List<BypassProfile>> {
  const BypassProfilesOnceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bypassProfilesOnceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bypassProfilesOnceHash();

  @$internal
  @override
  $FutureProviderElement<List<BypassProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BypassProfile>> create(Ref ref) {
    return bypassProfilesOnce(ref);
  }
}

String _$bypassProfilesOnceHash() =>
    r'6312d230bc8250d69dac11630f5ed024c585eaf1';

@ProviderFor(BypassProfilesRepo)
const bypassProfilesRepoProvider = BypassProfilesRepoProvider._();

final class BypassProfilesRepoProvider
    extends $NotifierProvider<BypassProfilesRepo, List<BypassProfile>> {
  const BypassProfilesRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bypassProfilesRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bypassProfilesRepoHash();

  @$internal
  @override
  BypassProfilesRepo create() => BypassProfilesRepo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BypassProfile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BypassProfile>>(value),
    );
  }
}

String _$bypassProfilesRepoHash() =>
    r'56d4f7ffad4fbb6d71cbde5a2489ee7f1efea675';

abstract class _$BypassProfilesRepo extends $Notifier<List<BypassProfile>> {
  List<BypassProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<BypassProfile>, List<BypassProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BypassProfile>, List<BypassProfile>>,
              List<BypassProfile>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
