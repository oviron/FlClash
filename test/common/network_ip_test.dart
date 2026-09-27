import 'package:fl_clash/common/network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldLookUpCountryCode', () {
    test('rejects empty address', () {
      expect(shouldLookUpCountryCode(''), isFalse);
    });

    test('rejects a bare domain name', () {
      expect(shouldLookUpCountryCode('example.com'), isFalse);
    });

    test('rejects loopback and unspecified', () {
      expect(shouldLookUpCountryCode('127.0.0.1'), isFalse);
      expect(shouldLookUpCountryCode('0.0.0.0'), isFalse);
      expect(shouldLookUpCountryCode('::1'), isFalse);
      expect(shouldLookUpCountryCode('::'), isFalse);
    });

    test('rejects private IPv4 ranges', () {
      expect(shouldLookUpCountryCode('10.0.0.5'), isFalse);
      expect(shouldLookUpCountryCode('172.16.5.1'), isFalse);
      expect(shouldLookUpCountryCode('172.31.255.255'), isFalse);
      expect(shouldLookUpCountryCode('192.168.1.1'), isFalse);
      expect(shouldLookUpCountryCode('100.64.0.1'), isFalse);
    });

    test('rejects link-local and multicast', () {
      expect(shouldLookUpCountryCode('169.254.1.1'), isFalse);
      expect(shouldLookUpCountryCode('224.0.0.1'), isFalse);
    });

    test('rejects IPv6 unique-local addresses', () {
      expect(shouldLookUpCountryCode('fc00::1'), isFalse);
      expect(shouldLookUpCountryCode('fd12:3456::1'), isFalse);
      expect(shouldLookUpCountryCode('fe80::1'), isFalse);
    });

    test('accepts a public IPv4 address', () {
      expect(shouldLookUpCountryCode('8.8.8.8'), isTrue);
    });

    test('accepts a public IPv6 address', () {
      expect(shouldLookUpCountryCode('2001:4860:4860::8888'), isTrue);
    });

    test('rejects an unparsable address without throwing', () {
      expect(shouldLookUpCountryCode('not-an-ip'), isFalse);
      expect(shouldLookUpCountryCode('999.999.999.999'), isFalse);
    });
  });
}
