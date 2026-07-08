import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dns.proxyServerNameserverPolicy (#20 GUI-editable)', () {
    test('defaults to an empty map, never null', () {
      expect(const Dns().proxyServerNameserverPolicy, <String, String>{});
    });

    test('fromJson reads the proxy-server-nameserver-policy key', () {
      final dns = Dns.fromJson(const {
        'proxy-server-nameserver-policy': {
          '+.example.com': 'https://9.9.9.9/dns-query',
        },
      });
      expect(dns.proxyServerNameserverPolicy, {
        '+.example.com': 'https://9.9.9.9/dns-query',
      });
    });

    test('toJson emits the proxy-server-nameserver-policy key', () {
      const dns = Dns(proxyServerNameserverPolicy: {'+.foo': 'bar'});
      expect(dns.toJson()['proxy-server-nameserver-policy'], {'+.foo': 'bar'});
    });
  });
}
