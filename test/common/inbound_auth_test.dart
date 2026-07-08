import 'package:fl_clash/common/inbound_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'injects auth on a bare mixed inbound when systemProxy is off',
    () async {
      final config = <String, dynamic>{'mixed-port': 7890};
      await ensureInboundAuth(config, systemProxy: false);
      final auth = config['authentication'];
      expect(auth, isA<List<dynamic>>());
      expect((auth as List<dynamic>).single, startsWith('fl-clash:'));
    },
  );

  test('does not inject auth when systemProxy is on', () async {
    final config = <String, dynamic>{'mixed-port': 7890};
    await ensureInboundAuth(config, systemProxy: true);
    expect(config.containsKey('authentication'), isFalse);
  });

  test('leaves a user-supplied authentication untouched', () async {
    final config = <String, dynamic>{
      'mixed-port': 7890,
      'authentication': ['me:secret'],
    };
    await ensureInboundAuth(config, systemProxy: false);
    expect(config['authentication'], ['me:secret']);
  });

  test('no inbound means no auth regardless of systemProxy', () async {
    final config = <String, dynamic>{};
    await ensureInboundAuth(config, systemProxy: false);
    expect(config.containsKey('authentication'), isFalse);
  });
}
