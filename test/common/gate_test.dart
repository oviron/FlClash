import 'package:fl_clash/common/future.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work queued before the gate opens waits for it', () async {
    final gate = Gate();
    final log = <String>[];

    final queued = gate.after(() async => log.add('start'));
    await pumpEventQueue();
    expect(gate.isOpen, isFalse);
    expect(log, isEmpty);

    gate.open();
    await queued;
    expect(gate.isOpen, isTrue);
    expect(log, ['start']);
  });

  test('queued work runs in the order it was queued', () async {
    final gate = Gate();
    final log = <String>[];

    final stop = gate.after(() async => log.add('stop'));
    final start = gate.after(() async => log.add('start'));
    gate.open();
    await Future.wait([stop, start]);

    expect(log, ['stop', 'start']);
  });

  test('opening twice is harmless', () async {
    final gate = Gate()..open();
    gate.open();

    expect(await gate.after(() async => 'ran'), 'ran');
  });
}
