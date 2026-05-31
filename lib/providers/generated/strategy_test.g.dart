// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../strategy_test.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StrategyTestController)
const strategyTestControllerProvider = StrategyTestControllerProvider._();

final class StrategyTestControllerProvider
    extends $NotifierProvider<StrategyTestController, StrategyTestState> {
  const StrategyTestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strategyTestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strategyTestControllerHash();

  @$internal
  @override
  StrategyTestController create() => StrategyTestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StrategyTestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StrategyTestState>(value),
    );
  }
}

String _$strategyTestControllerHash() =>
    r'ab6ee1f7fff39c8b4d9c39a48980464bafba38cd';

abstract class _$StrategyTestController extends $Notifier<StrategyTestState> {
  StrategyTestState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StrategyTestState, StrategyTestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StrategyTestState, StrategyTestState>,
              StrategyTestState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
