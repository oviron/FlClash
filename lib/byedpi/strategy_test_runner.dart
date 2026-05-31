import 'dart:convert';

import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/strategy_test_codec.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';

typedef NativeStrategyTestProgress = void Function(String json);
typedef NativeProgressBinder = void Function(NativeStrategyTestProgress? cb);
typedef NativeStrategyTestStarter = Future<bool> Function(String params);
typedef NativeStrategyTestStopper = Future<void> Function();

class StrategyTestRunRequest {
  final List<ByeDpiStrategy> strategies;
  final List<String> sites;
  final int requests;
  final int timeout;
  final int concurrency;

  const StrategyTestRunRequest({
    required this.strategies,
    required this.sites,
    required this.requests,
    required this.timeout,
    required this.concurrency,
  });

  bool get isEmpty => strategies.isEmpty || sites.isEmpty;

  Map<String, String> get labels => {
    for (final strategy in strategies) strategy.id: strategy.label,
  };

  String toNativeParams() {
    return jsonEncode({
      'strategies': [
        for (final strategy in strategies)
          {'id': strategy.id, 'args': strategy.args},
      ],
      'sites': sites,
      'requests': requests,
      'timeout': timeout,
      'concurrency': concurrency,
    });
  }
}

List<String> parseStrategyTestSites(String hostListText) {
  return hostListText
      .split('\n')
      .map((host) => host.trim())
      .where((host) => host.isNotEmpty && !host.startsWith('#'))
      .toList(growable: false);
}

class StrategyTestNativeRunner {
  final NativeProgressBinder bindProgress;
  final NativeStrategyTestStarter startNative;
  final NativeStrategyTestStopper stopNative;

  const StrategyTestNativeRunner({
    required this.bindProgress,
    required this.startNative,
    required this.stopNative,
  });

  Future<bool> start({
    required StrategyTestRunRequest request,
    required void Function(StrategyTestProgress progress) onProgress,
  }) async {
    bindProgress((json) {
      try {
        final progress = parseStrategyTestProgress(
          json,
          labelFor: (id) => request.labels[id] ?? id,
        );
        onProgress(progress);
      } catch (_) {
        return;
      }
    });
    final ok = await startNative(request.toNativeParams());
    if (!ok) bindProgress(null);
    return ok;
  }

  Future<void> stop() async {
    await stopNative();
    bindProgress(null);
  }

  void detach() {
    bindProgress(null);
  }
}
