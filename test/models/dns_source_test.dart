import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveDnsSource', () {
    test('override on means the app block wins', () {
      expect(
        resolveDnsSource(
          overrideDns: true,
          profileConfig: {
            'dns': {'enable': true},
          },
        ),
        DnsSource.appOverride,
      );
    });

    test('override off with no profile DNS still applies the app block', () {
      expect(
        resolveDnsSource(overrideDns: false, profileConfig: {'mode': 'rule'}),
        DnsSource.appFallback,
      );
    });

    test('override off with dns.enable false still applies the app block', () {
      expect(
        resolveDnsSource(
          overrideDns: false,
          profileConfig: {
            'dns': {'enable': false},
          },
        ),
        DnsSource.appFallback,
      );
    });

    test(
      'override off with profile DNS enabled leaves the profile in charge',
      () {
        expect(
          resolveDnsSource(
            overrideDns: false,
            profileConfig: {
              'dns': {'enable': true},
            },
          ),
          DnsSource.profile,
        );
      },
    );

    test('an unreadable profile resolves to unknown', () {
      expect(resolveDnsSource(overrideDns: false, profileConfig: null), isNull);
    });
  });
}
