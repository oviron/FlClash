import 'package:fl_clash/common/num.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fixed', () {
    test('trims trailing zeros and the dangling dot', () {
      expect(1.50.fixed(), '1.5');
      expect(2.00.fixed(), '2');
      expect(1.234.fixed(), '1.23');
      expect(0.fixed(), '0');
      expect(1.999.fixed(decimals: 1), '2');
    });
  });

  group('traffic', () {
    test('scales through the units', () {
      expect(512.traffic.value, '512');
      expect(512.traffic.unit, 'B');
      expect(1024.traffic.unit, 'KB');
      expect((1024 * 1024).traffic.unit, 'MB');
      expect((1536 * 1024).traffic.value, '1.5');
    });

    test('shortTraffic rounds to whole units with a leading space', () {
      final t = (1536 * 1024).shortTraffic;
      expect(t.value, '2');
      expect(t.unit, ' MB');
    });
  });
}
