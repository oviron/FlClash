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
    r'0ffce3dfc85d88ae2aefc9a1c1cfb2f4b01b1c0c';

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
