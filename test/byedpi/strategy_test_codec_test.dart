import 'dart:convert';

import 'package:fl_clash/byedpi/strategy_test_codec.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('strategy test cache codec', () {
    test('roundtrips result and failed hosts', () {
      const result = StrategyTestResult(
        id: 'tele2',
        label: 'Tele2',
        percent: 50,
        success: 1,
        totalRequests: 2,
        testedAt: 123,
        sites: [
          SiteOutcome('ok.example', 1, 1),
          SiteOutcome('bad.example', 0, 1),
        ],
      );

      final cached = strategyTestResultToCache(result);
      final decoded = strategyTestResultFromCache('tele2', cached);

      expect(decoded.id, 'tele2');
      expect(decoded.label, 'Tele2');
      expect(decoded.percent, 50);
      expect(decoded.success, 1);
      expect(decoded.totalRequests, 2);
      expect(decoded.testedAt, 123);
      expect(decoded.failedHosts, ['bad.example']);
    });

    test('recomputes totals from cached sites', () {
      final decoded = strategyTestResultFromCache('x', {
        'percent': 75,
        'sites': [
          {'site': 'a.test', 'ok': 2, 'total': 2},
          {'site': 'b.test', 'ok': 1, 'total': 2},
        ],
      });

      expect(decoded.success, 3);
      expect(decoded.totalRequests, 4);
    });
  });

  group('native progress codec', () {
    test('parses progress payload', () {
      final progress = parseStrategyTestProgress(
        jsonEncode({
          'id': 'tele2',
          'sites': [
            {'site': 'a.test', 'ok': 1, 'total': 1},
          ],
          'percent': 100,
          'success': 1,
          'totalRequests': 1,
          'index': 2,
          'done': true,
        }),
        labelFor: (id) => 'label:$id',
        testedAt: 456,
      );

      expect(progress.error, isNull);
      expect(progress.done, isTrue);
      expect(progress.completed, 3);
      expect(progress.result?.label, 'label:tele2');
      expect(progress.result?.testedAt, 456);
    });

    test('parses error payload without result', () {
      final progress = parseStrategyTestProgress(
        '{"error":"native failed"}',
        labelFor: (id) => id,
      );

      expect(progress.error, 'native failed');
      expect(progress.result, isNull);
      expect(progress.done, isTrue);
    });

    test('throws on malformed progress payload', () {
      expect(
        () => parseStrategyTestProgress(
          '{"id":"x","sites":[],"percent":0}',
          labelFor: (id) => id,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
