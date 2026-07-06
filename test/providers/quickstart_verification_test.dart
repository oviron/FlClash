import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/quickstart_verification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decideVerifyStatus', () {
    test('a real IP through the tunnel is verified', () {
      final probe = Result<IpInfo?>.success(
        const IpInfo(ip: '203.0.113.7', countryCode: 'US'),
      );
      expect(decideVerifyStatus(probe), QuickStartVerifyStatus.verified);
    });

    test('a null probe (no page loaded) is a failure', () {
      final probe = Result<IpInfo?>.success(null);
      expect(decideVerifyStatus(probe), QuickStartVerifyStatus.failed);
    });

    test('a REJECT default route is a failure, not a false green', () {
      final probe = Result<IpInfo?>.success(IpInfo.rejected());
      expect(decideVerifyStatus(probe), QuickStartVerifyStatus.failed);
    });

    test('a probe error is a failure', () {
      final probe = Result<IpInfo?>.error('boom');
      expect(decideVerifyStatus(probe), QuickStartVerifyStatus.failed);
    });
  });
}
