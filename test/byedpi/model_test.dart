import 'package:fl_clash/byedpi/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ByeDpiStrategy.fromJson', () {
    test('parses id, label and args', () {
      final s = ByeDpiStrategy.fromJson({
        'id': 'tele2',
        'label': 'Tele2',
        'args': '-s1 -o1 -a1',
      });
      expect(s.id, 'tele2');
      expect(s.label, 'Tele2');
      expect(s.args, '-s1 -o1 -a1');
    });

    test('label falls back to id, args to empty', () {
      final s = ByeDpiStrategy.fromJson({'id': 'foo'});
      expect(s.label, 'foo');
      expect(s.args, isEmpty);
    });
  });

  group('effectiveByeDpiCliArgs', () {
    const argsById = {'tele2': '-s1 -o1', 'universal': '-o1 -a1 -r-5+se'};

    test('non-custom preset resolves args from the map', () {
      const s = ByeDpiSettings(preset: 'tele2', cliArgs: '--should-be-ignored');
      expect(effectiveByeDpiCliArgs(s, argsById), equals('-s1 -o1'));
    });

    test('non-custom preset absent from map falls back to default args', () {
      const s = ByeDpiSettings(preset: 'unknownId');
      expect(effectiveByeDpiCliArgs(s, argsById), equals(kByeDpiDefaultArgs));
    });

    test('custom preset uses cliArgs verbatim', () {
      const s = ByeDpiSettings(
        preset: kByeDpiCustomId,
        cliArgs: '--my-strategy 7',
      );
      expect(effectiveByeDpiCliArgs(s, argsById), equals('--my-strategy 7'));
    });

    test('custom preset with empty cliArgs returns empty', () {
      const s = ByeDpiSettings(preset: kByeDpiCustomId, cliArgs: '');
      expect(effectiveByeDpiCliArgs(s, argsById), isEmpty);
    });
  });
}
