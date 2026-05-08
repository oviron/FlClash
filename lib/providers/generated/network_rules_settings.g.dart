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
    r'52d55edc030e6f84c3a4fd5f3b9fc650864968fd';

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
