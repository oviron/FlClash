import 'package:fl_clash/byedpi/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ByeDpiPreset.args', () {
    test('every non-custom preset has non-empty args', () {
      for (final p in ByeDpiPreset.values) {
        if (p == ByeDpiPreset.custom) continue;
        expect(
          p.args,
          isNotEmpty,
          reason: 'preset ${p.name} should ship a default args string',
        );
      }
    });

    test('custom preset has empty args (placeholder)', () {
      expect(ByeDpiPreset.custom.args, isEmpty);
    });

    test('args strings contain no surrounding whitespace', () {
      for (final p in ByeDpiPreset.values) {
        expect(p.args.trim(), equals(p.args), reason: p.name);
      }
    });
  });

  group('effectiveByeDpiCliArgs', () {
    test('non-custom preset wins over cliArgs field', () {
      const s = ByeDpiSettings(
        preset: ByeDpiPreset.tele2,
        cliArgs: '--should-be-ignored',
      );
      expect(effectiveByeDpiCliArgs(s), equals(ByeDpiPreset.tele2.args));
    });

    test('custom preset uses cliArgs verbatim', () {
      const s = ByeDpiSettings(
        preset: ByeDpiPreset.custom,
        cliArgs: '--my-strategy 7',
      );
      expect(effectiveByeDpiCliArgs(s), equals('--my-strategy 7'));
    });

    test('custom preset with empty cliArgs returns empty', () {
      const s = ByeDpiSettings(preset: ByeDpiPreset.custom, cliArgs: '');
      expect(effectiveByeDpiCliArgs(s), isEmpty);
    });
  });
}
