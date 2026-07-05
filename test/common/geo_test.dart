import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/geo.dart';
import 'package:flutter_test/flutter_test.dart';

// A minimal GeoSite entry: GeoSite { string country_code = 1 } wrapped in the
// GeoSiteList { repeated GeoSite entry = 1 } stream. No domain payload.
List<int> _entry(String code) {
  final c = utf8.encode(code);
  final inner = [0x0a, c.length, ...c];
  return [0x0a, inner.length, ...inner];
}

void main() {
  group('parseGeositeCategories', () {
    test('extracts, lowercases and sorts category codes', () {
      final bytes = Uint8List.fromList([
        ..._entry('CATEGORY-RU'),
        ..._entry('GOOGLE'),
        ..._entry('CATEGORY-ADS-ALL'),
      ]);
      expect(parseGeositeCategories(bytes), [
        'category-ads-all',
        'category-ru',
        'google',
      ]);
    });

    test('skips the domain payload trailing a country_code', () {
      final code = utf8.encode('APPLE');
      final domain = utf8.encode('apple.com');
      // Domain field (field 2, length-delimited) after the code inside GeoSite.
      final domainMsg = [0x12, domain.length, ...domain];
      final inner = [0x0a, code.length, ...code, ...domainMsg];
      final entry = [0x0a, inner.length, ...inner];
      final bytes = Uint8List.fromList([...entry, ..._entry('VK')]);
      expect(parseGeositeCategories(bytes), ['apple', 'vk']);
    });

    test('returns empty on empty input', () {
      expect(parseGeositeCategories(Uint8List(0)), isEmpty);
    });

    test('does not throw on a blob truncated mid-varint', () {
      // Trailing 0x80 sets the continuation bit with no next byte: a naive
      // varint read walks off the end. Parser must return what it decoded.
      final bytes = Uint8List.fromList([..._entry('RU'), 0x80]);
      expect(parseGeositeCategories(bytes), ['ru']);
    });
  });
}
