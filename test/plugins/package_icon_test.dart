import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final requested = <String>[];

  setUp(() {
    requested.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('$packageName/app'), (
          call,
        ) async {
          final name = (call.arguments as Map)['packageName'] as String;
          requested.add(name);
          if (name == 'broken') {
            throw PlatformException(code: 'no_icon');
          }
          return '/icons/$name.png';
        });
  });

  test('an icon is fetched from the platform once per package', () async {
    final first = App().getPackageIcon('org.example.a');
    final second = App().getPackageIcon('org.example.a');

    expect(identical(first, second), isTrue);
    expect((await first as FileImage).file.path, '/icons/org.example.a.png');
    await App().getPackageIcon('org.example.a');
    await App().getPackageIcon('org.example.b');

    expect(requested, ['org.example.a', 'org.example.b']);
  });

  test('a failed lookup yields no icon and is not retried', () async {
    expect(await App().getPackageIcon('broken'), isNull);
    expect(await App().getPackageIcon('broken'), isNull);

    expect(requested, ['broken']);
  });
}
