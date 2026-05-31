import 'dart:convert';

import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';
import 'package:fl_clash/byedpi/strategy_test_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseStrategyTestSites trims comments and blank lines', () {
    expect(
      parseStrategyTestSites('''
youtube.com

# comment
 googlevideo.com
'''),
      ['youtube.com', 'googlevideo.com'],
    );
  });

  test('StrategyTestRunRequest encodes native params', () {
    const request = StrategyTestRunRequest(
      strategies: [ByeDpiStrategy(id: 'a', label: 'A', args: '-a')],
      sites: ['youtube.com'],
      requests: 2,
      timeout: 3,
      concurrency: 4,
    );

    final encoded = jsonDecode(request.toNativeParams()) as Map;

    expect(encoded['requests'], 2);
    expect(encoded['timeout'], 3);
    expect(encoded['concurrency'], 4);
    expect(encoded['sites'], ['youtube.com']);
    expect(encoded['strategies'], [
      {'id': 'a', 'args': '-a'},
    ]);
  });

  test(
    'native runner binds typed progress and detaches on failed start',
    () async {
      NativeStrategyTestProgress? bound;
      var startCalled = false;
      final runner = StrategyTestNativeRunner(
        bindProgress: (cb) => bound = cb,
        startNative: (_) async {
          startCalled = true;
          return false;
        },
        stopNative: () async {},
      );

      final ok = await runner.start(
        request: const StrategyTestRunRequest(
          strategies: [ByeDpiStrategy(id: 'a', label: 'A', args: '-a')],
          sites: ['youtube.com'],
          requests: 1,
          timeout: 1,
          concurrency: 1,
        ),
        onProgress: (_) {},
      );

      expect(ok, isFalse);
      expect(startCalled, isTrue);
      expect(bound, isNull);
    },
  );

  test('native runner detaches when start throws', () async {
    NativeStrategyTestProgress? bound;
    final runner = StrategyTestNativeRunner(
      bindProgress: (cb) => bound = cb,
      startNative: (_) => throw StateError('boom'),
      stopNative: () async {},
    );

    await expectLater(
      runner.start(
        request: const StrategyTestRunRequest(
          strategies: [ByeDpiStrategy(id: 'a', label: 'A', args: '-a')],
          sites: ['youtube.com'],
          requests: 1,
          timeout: 1,
          concurrency: 1,
        ),
        onProgress: (_) {},
      ),
      throwsA(isA<StateError>()),
    );
    expect(bound, isNull);
  });

  test('native runner converts progress payloads to typed progress', () async {
    NativeStrategyTestProgress? bound;
    StrategyTestProgress? progress;
    final runner = StrategyTestNativeRunner(
      bindProgress: (cb) => bound = cb,
      startNative: (_) async => true,
      stopNative: () async {},
    );

    await runner.start(
      request: const StrategyTestRunRequest(
        strategies: [ByeDpiStrategy(id: 'a', label: 'A', args: '-a')],
        sites: ['youtube.com'],
        requests: 1,
        timeout: 1,
        concurrency: 1,
      ),
      onProgress: (value) => progress = value,
    );
    bound?.call(
      jsonEncode({
        'id': 'a',
        'sites': [
          {'site': 'youtube.com', 'ok': 1, 'total': 1},
        ],
        'percent': 100,
        'success': 1,
        'totalRequests': 1,
        'index': 0,
        'done': true,
      }),
    );

    expect(progress?.result?.label, 'A');
    expect(progress?.done, isTrue);
  });

  test('native runner ignores malformed progress payloads', () async {
    NativeStrategyTestProgress? bound;
    StrategyTestProgress? progress;
    final runner = StrategyTestNativeRunner(
      bindProgress: (cb) => bound = cb,
      startNative: (_) async => true,
      stopNative: () async {},
    );

    await runner.start(
      request: const StrategyTestRunRequest(
        strategies: [ByeDpiStrategy(id: 'a', label: 'A', args: '-a')],
        sites: ['youtube.com'],
        requests: 1,
        timeout: 1,
        concurrency: 1,
      ),
      onProgress: (value) => progress = value,
    );

    expect(() => bound?.call('{'), returnsNormally);
    expect(progress, isNull);
  });
}
