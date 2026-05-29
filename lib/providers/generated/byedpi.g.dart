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
    r'c883a592acd5a3aad0dbdf82c5f196c85a319aa0';

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
