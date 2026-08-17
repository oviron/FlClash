import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingListener with ServiceListener {
  final runStates = <DateTime?>[];
  var runStateCalls = 0;

  @override
  void onRunStateChanged(DateTime? startTime) {
    runStates.add(startTime);
    runStateCalls++;
  }
}

Future<void> _push(Object? arguments) {
  return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        '$packageName/service',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('runState', arguments),
        ),
        (_) {},
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Service instance;
  late _RecordingListener listener;

  setUp(() {
    instance = Service();
    listener = _RecordingListener();
    instance.addListener(listener);
  });

  tearDown(() => instance.removeListener(listener));

  test('a non-zero run time is decoded as the tunnel start time', () async {
    await _push(1700000000000);

    expect(
      listener.runStates.single,
      DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );
  });

  test('zero means stopped, not epoch', () async {
    await _push(0);

    expect(listener.runStates.single, isNull);
  });

  test('a missing payload is read as stopped rather than throwing', () async {
    await _push(null);

    expect(listener.runStates.single, isNull);
  });

  test('every push reaches the listener, including repeats', () async {
    await _push(1700000000000);
    await _push(0);
    await _push(1700000005000);

    expect(listener.runStateCalls, 3);
    expect(listener.runStates.map((e) => e != null), [true, false, true]);
  });

  test(
    'an unrelated inbound method does not fire the run-state listener',
    () async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            '$packageName/service',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('crash', 'boom'),
            ),
            (_) {},
          );

      expect(listener.runStateCalls, 0);
    },
  );
}
