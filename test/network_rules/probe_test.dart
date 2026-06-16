import 'package:fl_clash/network_rules/probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkProbe.sanitizeSsid', () {
    test('null stays null', () {
      expect(NetworkProbe.sanitizeSsid(null), isNull);
    });

    test('the <unknown ssid> stub becomes null', () {
      expect(NetworkProbe.sanitizeSsid('<unknown ssid>'), isNull);
    });

    test('surrounding double quotes are stripped', () {
      expect(NetworkProbe.sanitizeSsid('"Home"'), 'Home');
    });

    test('whitespace is trimmed', () {
      expect(NetworkProbe.sanitizeSsid('  Home  '), 'Home');
    });

    test('quoted then trimmed', () {
      expect(NetworkProbe.sanitizeSsid('" Home "'), 'Home');
    });

    test('empty or whitespace-only becomes null', () {
      expect(NetworkProbe.sanitizeSsid(''), isNull);
      expect(NetworkProbe.sanitizeSsid('   '), isNull);
      expect(NetworkProbe.sanitizeSsid('""'), isNull);
    });

    test('a plain name is preserved', () {
      expect(NetworkProbe.sanitizeSsid('Cafe WiFi'), 'Cafe WiFi');
    });
  });
}
