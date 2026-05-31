// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../byedpi_routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(byeDpiRoutingHostList)
const byeDpiRoutingHostListProvider = ByeDpiRoutingHostListProvider._();

final class ByeDpiRoutingHostListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  const ByeDpiRoutingHostListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byeDpiRoutingHostListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byeDpiRoutingHostListHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return byeDpiRoutingHostList(ref);
  }
}

String _$byeDpiRoutingHostListHash() =>
    r'a7f5735b1fe2b46bd2bd88543c5c6f92b1c4e631';
