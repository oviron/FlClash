import 'dart:async';

import 'package:fl_clash/common/future.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tasks run one at a time in the order they were queued', () async {
    final queue = SerialQueue();
    final log = <String>[];
    final gate = Completer<void>();

    final first = queue.run(() async {
      log.add('stop:begin');
      await gate.future;
      log.add('stop:end');
    });
    final second = queue.run(() async {
      log.add('start');
    });

    await Future<void>.delayed(Duration.zero);
    expect(log, ['stop:begin']);
    gate.complete();
    await Future.wait([first, second]);

    expect(log, ['stop:begin', 'stop:end', 'start']);
  });

  test(
    'a failed task reaches its caller and does not block the next',
    () async {
      final queue = SerialQueue();

      final failed = queue.run<void>(() async => throw StateError('boom'));
      final next = queue.run(() async => 'ran');

      await expectLater(failed, throwsStateError);
      expect(await next, 'ran');
    },
  );

  test('a task queued from inside a running task runs inline', () async {
    final queue = SerialQueue();
    final log = <String>[];

    await queue.run(() async {
      log.add('outer:begin');
      await queue.run(() async => log.add('inner'));
      log.add('outer:end');
    });

    expect(log, ['outer:begin', 'inner', 'outer:end']);
  });

  test('a task a finished task left behind waits its turn', () async {
    final queue = SerialQueue();
    final log = <String>[];
    final gate = Completer<void>();
    final timerFired = Completer<void>();
    Future<void>? late;

    await queue.run(() async {
      Timer(const Duration(milliseconds: 10), () {
        late = queue.run(() async => log.add('late'));
        timerFired.complete();
      });
    });
    final blocking = queue.run(() async {
      log.add('newer:begin');
      await gate.future;
      log.add('newer:end');
    });

    await timerFired.future;
    expect(log, ['newer:begin']);
    gate.complete();
    await Future.wait([blocking, late!]);

    expect(log, ['newer:begin', 'newer:end', 'late']);
  });
}
