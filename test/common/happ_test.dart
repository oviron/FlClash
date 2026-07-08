import 'package:fl_clash/ingest/happ/happ_identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('generateHwid emits a well-formed RFC 4122 v4 UUID', () {
    for (var i = 0; i < 50; i++) {
      final id = generateHwid();
      expect(_uuidV4.hasMatch(id), true, reason: 'not a v4 UUID: $id');
    }
    expect(generateHwid() == generateHwid(), false, reason: 'must be random');
  });

  test(
    'ensureHwid persists and reuses the same id (never burns a slot)',
    () async {
      final a = await ensureHwid();
      final b = await ensureHwid();
      expect(a, b);
      expect(_uuidV4.hasMatch(a), true);
    },
  );

  test(
    'happHeaders fills the Happ UA + self hwid but never clobbers base',
    () async {
      final merged = await happHeaders(base: {'User-Agent': 'Custom/1.0'});
      expect(merged['User-Agent'], 'Custom/1.0');
      expect(merged[happHwidHeader], isNotEmpty);

      final bare = await happHeaders();
      expect(bare['User-Agent'], 'Happ/3.6.0');
      expect(_uuidV4.hasMatch(bare[happHwidHeader]!), true);
    },
  );
}
