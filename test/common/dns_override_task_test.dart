import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _subscription() => {
  'dns': {
    'enable': true,
    'ipv6': true,
    'enhanced-mode': 'redir-host',
    'nameserver': ['https://sub.example/dns-query'],
    'fallback': ['tls://fallback.example'],
  },
};

Future<Map<String, dynamic>> _build({
  required bool overrideDns,
  required Set<String> keys,
  Dns dns = defaultDns,
  Map<String, dynamic>? rawConfig,
}) {
  return makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig ?? _subscription(),
      realPatchConfig: defaultClashConfig.copyWith(
        dns: dns,
        dnsOverrideKeys: keys,
      ),
      overrideDns: overrideDns,
      appendSystemDns: false,
      addedRules: const [],
      defaultUA: 'ua',
    ),
  );
}

void main() {
  test('a partial override replaces only its keys', () async {
    final config = await _build(
      overrideDns: true,
      keys: {'nameserver'},
      dns: defaultDns.copyWith(nameserver: ['https://app.example/dns-query']),
    );

    final dns = config['dns'];
    expect(dns['nameserver'], ['https://app.example/dns-query']);
    expect(dns['ipv6'], isTrue);
    expect(dns['enhanced-mode'], 'redir-host');
    expect(dns['fallback'], ['tls://fallback.example']);
  });

  test('overriding every key gives the app DNS block alone', () async {
    final config = await _build(overrideDns: true, keys: allDnsKeys);

    final dns = Map<String, dynamic>.from(config['dns']);
    final expected = defaultDns.toJson();
    expect(dns.keys.toSet(), expected.keys.toSet());
    expect(dns['ipv6'], isFalse);
    expect(dns['enhanced-mode'], 'fake-ip');
    expect(dns['nameserver'], defaultDns.nameserver);
  });

  test('an overridden policy is split into multiple servers', () async {
    final config = await _build(
      overrideDns: true,
      keys: {'nameserver-policy'},
      dns: defaultDns.copyWith(
        nameserverPolicy: {'+.example': '1.1.1.1, 8.8.8.8'},
      ),
    );

    expect(config['dns']['nameserver-policy'], {
      '+.example': ['1.1.1.1', '8.8.8.8'],
    });
    expect(config['dns']['nameserver'], ['https://sub.example/dns-query']);
  });

  test('an override without keys leaves the profile DNS alone', () async {
    final config = await _build(overrideDns: true, keys: {});

    expect(config['dns']['ipv6'], isTrue);
    expect(config['dns']['nameserver'], ['https://sub.example/dns-query']);
  });

  test('the switch off ignores the keys', () async {
    final config = await _build(
      overrideDns: false,
      keys: allDnsKeys,
      dns: defaultDns.copyWith(ipv6: false),
    );

    expect(config['dns']['ipv6'], isTrue);
  });

  test('a profile without DNS still gets the whole app block', () async {
    final config = await _build(
      overrideDns: true,
      keys: {'ipv6'},
      rawConfig: {'mode': 'rule'},
    );

    expect(config['dns']['enable'], isTrue);
    expect(config['dns']['nameserver'], [
      ...defaultDns.nameserver,
      'system://',
    ]);
  });
}
