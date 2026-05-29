// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../byedpi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(byeDpiStrategies)
const byeDpiStrategiesProvider = ByeDpiStrategiesProvider._();

final class ByeDpiStrategiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ByeDpiStrategy>>,
          List<ByeDpiStrategy>,
          FutureOr<List<ByeDpiStrategy>>
        >
    with
        $FutureModifier<List<ByeDpiStrategy>>,
        $FutureProvider<List<ByeDpiStrategy>> {
  const ByeDpiStrategiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byeDpiStrategiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byeDpiStrategiesHash();

  @$internal
  @override
  $FutureProviderElement<List<ByeDpiStrategy>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ByeDpiStrategy>> create(Ref ref) {
    return byeDpiStrategies(ref);
  }
}

String _$byeDpiStrategiesHash() => r'dfb4b2f1e1abfb47ff56a4554e38565cf931fe07';

@ProviderFor(ByeDpiCoreRevision)
const byeDpiCoreRevisionProvider = ByeDpiCoreRevisionProvider._();

final class ByeDpiCoreRevisionProvider
    extends $NotifierProvider<ByeDpiCoreRevision, int> {
  const ByeDpiCoreRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byeDpiCoreRevisionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byeDpiCoreRevisionHash();

  @$internal
  @override
  ByeDpiCoreRevision create() => ByeDpiCoreRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$byeDpiCoreRevisionHash() =>
    r'90d8a1a36bc78f9fec824b1d40c466f537905e50';

abstract class _$ByeDpiCoreRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ByeDpiEngineRevision)
const byeDpiEngineRevisionProvider = ByeDpiEngineRevisionProvider._();

final class ByeDpiEngineRevisionProvider
    extends $NotifierProvider<ByeDpiEngineRevision, int> {
  const ByeDpiEngineRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byeDpiEngineRevisionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byeDpiEngineRevisionHash();

  @$internal
  @override
  ByeDpiEngineRevision create() => ByeDpiEngineRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$byeDpiEngineRevisionHash() =>
    r'3beec5a55cecaf5d2e705ef9413aacb248d57f54';

abstract class _$ByeDpiEngineRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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
    r'd7b2d827754a9c37ff6994c777d40d2c24bc79cf';

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
