import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseStrategyList', () {
    test('parses a valid list', () {
      final list = parseStrategyList(
        '[{"id":"a","label":"A","args":"-s1"},{"id":"b","label":"B","args":"-o1"}]',
      );
      expect(list.length, 2);
      expect(list.first.id, 'a');
      expect(list.first.args, '-s1');
    });

    test('label falls back to id, args to empty', () {
      final list = parseStrategyList('[{"id":"x"}]');
      expect(list.single.label, 'x');
      expect(list.single.args, isEmpty);
    });

    test('throws on malformed JSON', () {
      expect(
        () => parseStrategyList('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on empty array', () {
      expect(() => parseStrategyList('[]'), throwsA(isA<FormatException>()));
    });

    test('throws on duplicate ids', () {
      expect(
        () => parseStrategyList(
          '[{"id":"a","args":"-s1"},{"id":"a","args":"-o1"}]',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on empty id', () {
      expect(
        () => parseStrategyList('[{"id":"","args":"-s1"}]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
