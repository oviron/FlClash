import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isUrl / isShareLink', () {
    test('http(s)/ftp are urls', () {
      expect('https://example.com'.isUrl, isTrue);
      expect('http://example.com'.isUrl, isTrue);
      expect('ftp://example.com'.isUrl, isTrue);
      expect('vless://uuid@host:443'.isUrl, isFalse);
      expect('example.com'.isUrl, isFalse);
    });

    test('share links are the proxy schemes, case-insensitive, trimmed', () {
      expect('vless://uuid@host:443'.isShareLink, isTrue);
      expect('  VMESS://payload  '.isShareLink, isTrue);
      expect('https://example.com'.isShareLink, isFalse);
      expect('novalidscheme'.isShareLink, isFalse);
      expect('://nothing'.isShareLink, isFalse);
    });
  });

  group('safeSubstring', () {
    test('clamps every bound', () {
      expect('hello'.safeSubstring(1, 3), 'el');
      expect('hello'.safeSubstring(3, 1), '');
      expect('hello'.safeSubstring(-2), 'hello');
      expect('hello'.safeSubstring(99), '');
      expect(''.safeSubstring(1, 2), '');
    });
  });

  group('getBase64', () {
    test('decodes a data-uri payload and rejects garbage', () {
      final payload = base64.encode(utf8.encode('hi'));
      expect(utf8.decode('data:image/png;base64,$payload'.getBase64!), 'hi');
      expect('no marker here'.getBase64, isNull);
      expect('base64,%%%invalid%%%'.getBase64, isNull);
    });
  });

  group('takeFirstValid', () {
    test('first non-blank wins, else the default', () {
      expect('a'.takeFirstValid(['b']), 'a');
      expect('  '.takeFirstValid([null, ' b ']), 'b');
      String? none;
      expect(none.takeFirstValid([null, '  ']), '');
      expect(none.takeFirstValid([], defaultValue: 'd'), 'd');
    });
  });

  group('splitByMultipleSeparators', () {
    test('splits on commas, spaces and semicolons or passes through', () {
      expect('a, b;c  d'.splitByMultipleSeparators, ['a', 'b', 'c', 'd']);
      expect('single'.splitByMultipleSeparators, 'single');
    });
  });
}
