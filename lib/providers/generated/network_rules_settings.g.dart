// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../network_rules_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NetworkRulesSettings)
const networkRulesSettingsProvider = NetworkRulesSettingsProvider._();

final class NetworkRulesSettingsProvider
    extends $NotifierProvider<NetworkRulesSettings, NetworkRulesProps> {
  const NetworkRulesSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkRulesSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkRulesSettingsHash();

  @$internal
  @override
  NetworkRulesSettings create() => NetworkRulesSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkRulesProps value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkRulesProps>(value),
    );
  }
}

String _$networkRulesSettingsHash() =>
    r'bf557dab4e8b29d425536d642946cbc4bb25d9de';

abstract class _$NetworkRulesSettings extends $Notifier<NetworkRulesProps> {
  NetworkRulesProps build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NetworkRulesProps, NetworkRulesProps>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkRulesProps, NetworkRulesProps>,
              NetworkRulesProps,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
