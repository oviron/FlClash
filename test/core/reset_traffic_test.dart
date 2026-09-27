import 'dart:async';

import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

class _GatedCore extends CoreHandlerInterface {
  final gate = Completer<void>();
  final invoked = <ActionMethod>[];

  @override
  final Completer<dynamic> completer = Completer()..complete();

  @override
  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    invoked.add(method);
    await gate.future;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('resetTraffic completes only once the core has handled it', () async {
    final core = _GatedCore();
    var done = false;

    final reset = core.resetTraffic().then((_) => done = true);
    await pumpEventQueue();

    expect(core.invoked, [ActionMethod.resetTraffic]);
    expect(done, isFalse);

    core.gate.complete();
    await reset;
    expect(done, isTrue);
  });
}
