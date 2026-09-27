import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _saved(ClashConfig config) =>
    jsonDecode(jsonEncode(config)) as Map<String, Object?>;

void main() {
  group('dnsOverrideKeys', () {
    test('a fresh config overrides no DNS key', () {
      expect(defaultClashConfig.dnsOverrideKeys, isEmpty);
    });

    test('a config saved before the key set existed overrides every key', () {
      final saved = _saved(defaultClashConfig)..remove('dns-override-keys');

      final config = ClashConfig.fromJson(saved);

      expect(config.dnsOverrideKeys, allDnsKeys);
    });

    test('a saved key set survives a round trip', () {
      final saved = _saved(
        defaultClashConfig.copyWith(dnsOverrideKeys: {'ipv6', 'nameserver'}),
      );

      expect(ClashConfig.fromJson(saved).dnsOverrideKeys, {
        'ipv6',
        'nameserver',
      });
    });

    test('editing DNS adds only the keys whose value changed', () {
      final config = defaultClashConfig
          .copyWith(dnsOverrideKeys: {'listen'})
          .withDns(
            defaultDns.copyWith(ipv6: true, enhancedMode: DnsMode.redirHost),
          );

      expect(config.dnsOverrideKeys, {'listen', 'ipv6', 'enhanced-mode'});
      expect(config.dns.ipv6, isTrue);
    });

    test('setting a key back to its default keeps it overridden', () {
      final config = defaultClashConfig
          .withDns(defaultDns.copyWith(ipv6: true))
          .withDns(defaultDns);

      expect(config.dnsOverrideKeys, {'ipv6'});
    });
  });
}
