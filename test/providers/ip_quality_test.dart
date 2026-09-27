import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

IpQualityReport _report(String ip) => (ip: ip, verdict: null, results: []);

class _Lookups {
  final calls = <(String, CancelToken?, Completer<IpQualityReport>)>[];

  Future<IpQualityReport> call(String ip, {CancelToken? cancelToken}) {
    final completer = Completer<IpQualityReport>();
    calls.add((ip, cancelToken, completer));
    return completer.future;
  }
}

void main() {
  late _Lookups lookups;
  late ProviderContainer container;
  late ProviderSubscription<IpQualityCheckState> sub;

  setUp(() {
    lookups = _Lookups();
    container = ProviderContainer(
      overrides: [ipQualityLookupProvider.overrideWithValue(lookups.call)],
    );
    sub = container.listen(ipQualityCheckProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  IpQualityCheckState state() => container.read(ipQualityCheckProvider);
  IpQualityCheck notifier() => container.read(ipQualityCheckProvider.notifier);

  test('sends nothing until run, then shows the report', () async {
    expect(state(), isA<IpQualityIdle>());
    expect(lookups.calls, isEmpty);

    final done = notifier().run('203.0.113.7');
    expect(state(), isA<IpQualityChecking>());
    lookups.calls.single.$3.complete(_report('203.0.113.7'));
    await done;

    final checked = state() as IpQualityChecked;
    expect(checked.report.ip, '203.0.113.7');
  });

  test('a rerun cancels the earlier check and ignores its result', () async {
    final first = notifier().run('203.0.113.7');
    final second = notifier().run('203.0.113.8');
    expect(lookups.calls[0].$2!.isCancelled, isTrue);
    expect(lookups.calls[1].$2!.isCancelled, isFalse);

    lookups.calls[1].$3.complete(_report('203.0.113.8'));
    await second;
    lookups.calls[0].$3.complete(_report('203.0.113.7'));
    await first;

    expect((state() as IpQualityChecked).report.ip, '203.0.113.8');
  });

  test('closing the sheet cancels the running check', () async {
    unawaited(notifier().run('203.0.113.7'));
    final token = lookups.calls.single.$2!;
    sub.close();
    await container.pump();
    expect(token.isCancelled, isTrue);
  });

  test('an unexpected failure returns to idle instead of spinning', () async {
    final done = notifier().run('203.0.113.7');
    lookups.calls.single.$3.completeError(StateError('boom'));
    await done;
    expect(state(), isA<IpQualityIdle>());
  });
}
