import 'package:fl_clash/common/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a path_provider failure reaches the caller instead of hanging', () {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => throw PlatformException(code: 'unavailable'),
        );

    expect(
      AppPath().databasePath.timeout(const Duration(seconds: 5)),
      throwsA(isA<PlatformException>()),
    );
  });
}
