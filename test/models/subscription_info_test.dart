import 'package:fl_clash/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionInfo.formHString', () {
    test('parses a well-formed header', () {
      final info = SubscriptionInfo.formHString(
        'upload=100; download=200; total=1000; expire=1785790799',
      );
      expect(info.upload, 100);
      expect(info.download, 200);
      expect(info.total, 1000);
      expect(info.expire, 1785790799);
    });

    test('a trailing semicolon does not throw (real panels send it)', () {
      final info = SubscriptionInfo.formHString(
        'upload=1; download=2; total=3; expire=4;',
      );
      expect(info.total, 3);
      expect(info.expire, 4);
    });

    test('tokens without "=" are skipped, not crashed on', () {
      final info = SubscriptionInfo.formHString('garbage; total=5; ; noeq');
      expect(info.total, 5);
      expect(info.upload, 0);
    });

    test('null / empty -> zeroed info', () {
      expect(SubscriptionInfo.formHString(null).total, 0);
      expect(SubscriptionInfo.formHString('').total, 0);
    });

    test('used / remaining / expiry helpers', () {
      const info = SubscriptionInfo(upload: 30, download: 70, total: 1000);
      expect(info.used, 100);
      expect(info.remaining, 900);
    });

    test('remaining never goes negative when over quota', () {
      const info = SubscriptionInfo(upload: 800, download: 800, total: 1000);
      expect(info.remaining, 0);
    });
  });
}
