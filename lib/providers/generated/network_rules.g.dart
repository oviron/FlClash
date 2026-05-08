// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../network_rules.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live stream of all rules sorted by priority. UI / engine listen here.

@ProviderFor(networkRulesStream)
const networkRulesStreamProvider = NetworkRulesStreamProvider._();

/// Live stream of all rules sorted by priority. UI / engine listen here.

final class NetworkRulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NetworkRule>>,
          List<NetworkRule>,
          Stream<List<NetworkRule>>
        >
    with
        $FutureModifier<List<NetworkRule>>,
        $StreamProvider<List<NetworkRule>> {
  /// Live stream of all rules sorted by priority. UI / engine listen here.
  const NetworkRulesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkRulesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkRulesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<NetworkRule>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NetworkRule>> create(Ref ref) {
    return networkRulesStream(ref);
  }
}

String _$networkRulesStreamHash() =>
    r'9e585a656fe433479d28a5ec584a7be079372fc4';

/// Repository facade with CRUD + reorder. keepAlive because the engine
/// needs to keep watching even when no UI page is mounted.

@ProviderFor(NetworkRulesRepo)
const networkRulesRepoProvider = NetworkRulesRepoProvider._();

/// Repository facade with CRUD + reorder. keepAlive because the engine
/// needs to keep watching even when no UI page is mounted.
final class NetworkRulesRepoProvider
    extends $NotifierProvider<NetworkRulesRepo, List<NetworkRule>> {
  /// Repository facade with CRUD + reorder. keepAlive because the engine
  /// needs to keep watching even when no UI page is mounted.
  const NetworkRulesRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkRulesRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkRulesRepoHash();

  @$internal
  @override
  NetworkRulesRepo create() => NetworkRulesRepo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<NetworkRule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<NetworkRule>>(value),
    );
  }
}

String _$networkRulesRepoHash() => r'4248d3c166ddb2131b4655c5678b508082653320';

/// Repository facade with CRUD + reorder. keepAlive because the engine
/// needs to keep watching even when no UI page is mounted.

abstract class _$NetworkRulesRepo extends $Notifier<List<NetworkRule>> {
  List<NetworkRule> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<NetworkRule>, List<NetworkRule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<NetworkRule>, List<NetworkRule>>,
              List<NetworkRule>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
