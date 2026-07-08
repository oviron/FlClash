import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogLevelExt.allows (in-app log filter)', () {
    test('a filter passes logs at or above its own severity', () {
      expect(LogLevel.info.allows(LogLevel.info), isTrue);
      expect(LogLevel.info.allows(LogLevel.warning), isTrue);
      expect(LogLevel.info.allows(LogLevel.error), isTrue);
      expect(LogLevel.info.allows(LogLevel.debug), isFalse);
    });

    test('a stricter filter drops lower-severity logs', () {
      expect(LogLevel.warning.allows(LogLevel.info), isFalse);
      expect(LogLevel.error.allows(LogLevel.warning), isFalse);
    });

    test('the debug filter passes everything from debug up', () {
      expect(LogLevel.debug.allows(LogLevel.debug), isTrue);
      expect(LogLevel.debug.allows(LogLevel.error), isTrue);
    });

    test('a silent filter suppresses every log', () {
      expect(LogLevel.silent.allows(LogLevel.error), isFalse);
      expect(LogLevel.silent.allows(LogLevel.debug), isFalse);
    });

    test('a silent-level log is never shown, whatever the filter', () {
      expect(LogLevel.debug.allows(LogLevel.silent), isFalse);
      expect(LogLevel.error.allows(LogLevel.silent), isFalse);
    });
  });
}
