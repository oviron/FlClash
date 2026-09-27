import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SetupState stateWith({
    required bool overrideDns,
    required Dns dns,
    Set<String> dnsOverrideKeys = const {},
  }) {
    return SetupState(
      profileId: 7,
      profileLastUpdateDate: 1,
      overwriteType: OverwriteType.standard,
      addedRules: const [],
      script: null,
      overrideDns: overrideDns,
      dns: dns,
      dnsOverrideKeys: dnsOverrideKeys,
    );
  }

  test('a DNS edit needs a rebuild even when override is off', () {
    // The builder applies the app-level DNS block whenever the profile itself
    // does not enable DNS, regardless of the override switch, so gating the
    // rebuild on override alone silently drops the edit.
    final last = stateWith(overrideDns: false, dns: defaultDns);
    final next = stateWith(
      overrideDns: false,
      dns: defaultDns.copyWith(enhancedMode: DnsMode.redirHost),
    );

    expect(next.needSetup(last), isTrue);
  });

  test('picking another override key needs a rebuild', () {
    final last = stateWith(overrideDns: true, dns: defaultDns);
    final next = stateWith(
      overrideDns: true,
      dns: defaultDns,
      dnsOverrideKeys: {'ipv6'},
    );

    expect(next.needSetup(last), isTrue);
  });
}
