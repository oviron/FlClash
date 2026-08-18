import 'package:fl_clash/common/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareVersions', () {
    test('orders by major, minor, patch, then build', () {
      expect(utils.compareVersions('1.0.0', '2.0.0'), lessThan(0));
      expect(utils.compareVersions('0.16.0', '0.15.9'), greaterThan(0));
      expect(utils.compareVersions('1.2.3', '1.2.3'), 0);
      expect(utils.compareVersions('1.2', '1.2.0'), 0);
      expect(
        utils.compareVersions('1.0.0+2026081701', '1.0.0+2026081700'),
        greaterThan(0),
      );
    });
  });

  group('sortByChar', () {
    test('is case-insensitive and stable on equals', () {
      expect(utils.sortByChar('apple', 'Banana'), lessThan(0));
      expect(utils.sortByChar('a', 'a'), 0);
    });
  });

  group('getFileNameForDisposition', () {
    test('prefers RFC 5987 filename*, falls back to filename', () {
      expect(
        utils.getFileNameForDisposition(
          "attachment; filename*=UTF-8''na%C3%AFve.yaml",
        ),
        'naïve.yaml',
      );
      expect(
        utils.getFileNameForDisposition('attachment; filename="config.yaml"'),
        'config.yaml',
      );
      expect(utils.getFileNameForDisposition('attachment'), isNull);
      expect(utils.getFileNameForDisposition(null), isNull);
    });
  });

  group('parseReleaseBody', () {
    test('collects bullet lines', () {
      expect(utils.parseReleaseBody('- one\ntext\n- two'), ['one', 'two']);
      expect(utils.parseReleaseBody(null), isEmpty);
    });
  });

  group('getOverwriteLabel', () {
    test('appends and increments the copy counter', () {
      expect(utils.getOverwriteLabel('name'), 'name(1)');
      expect(utils.getOverwriteLabel('name(1)'), 'name(2)');
      expect(utils.getOverwriteLabel('name(9)'), 'name(10)');
    });
  });

  group('fastHash', () {
    test('is deterministic and spreads distinct inputs', () {
      expect(utils.fastHash('abc'), utils.fastHash('abc'));
      expect(utils.fastHash('abc'), isNot(utils.fastHash('abd')));
    });
  });
}
