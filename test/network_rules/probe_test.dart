import 'package:fl_clash/network_rules/probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanitizeSsid', () {
    test('null stays null', () {
      expect(sanitizeSsid(null), isNull);
    });

    test('the <unknown ssid> stub becomes null', () {
      expect(sanitizeSsid('<unknown ssid>'), isNull);
    });

    test('surrounding double quotes are stripped', () {
      expect(sanitizeSsid('"Home"'), 'Home');
    });

    test('whitespace is trimmed', () {
      expect(sanitizeSsid('  Home  '), 'Home');
    });

    test('quoted then trimmed', () {
      expect(sanitizeSsid('" Home "'), 'Home');
    });

    // Cross-engine parity anchor: the Kotlin NetworkSnapshotReader.sanitizeSsid
    // must produce the identical result (strip a quote pair, then trim).
    test('quoted and inner-padded normalizes to the bare name (parity)', () {
      expect(sanitizeSsid('"  Home  "'), 'Home');
    });

    test('empty or whitespace-only becomes null', () {
      expect(sanitizeSsid(''), isNull);
      expect(sanitizeSsid('   '), isNull);
      expect(sanitizeSsid('""'), isNull);
    });

    test('a plain name is preserved', () {
      expect(sanitizeSsid('Cafe WiFi'), 'Cafe WiFi');
    });
  });
}
