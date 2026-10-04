import 'package:fl_clash/common/network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLocalNetworkHost', () {
    test('private, link-local, ULA and multicast literals are local', () async {
      for (final host in [
        '10.0.2.2',
        '172.16.0.1',
        '172.31.255.254',
        '192.168.1.65',
        '169.254.10.1',
        '224.0.0.251',
        'fe80::1',
        'fd00::5',
        'ff02::fb',
      ]) {
        expect(await isLocalNetworkHost(host), isTrue, reason: host);
      }
    });

    test('public, loopback, CGNAT and fake-ip literals are not', () async {
      for (final host in [
        '1.1.1.1',
        '172.32.0.1',
        '127.0.0.1',
        '::1',
        '100.64.0.1',
        '198.18.0.4',
        '2606:4700::1111',
      ]) {
        expect(await isLocalNetworkHost(host), isFalse, reason: host);
      }
    });

    test('hostnames resolve through the injected lookup', () async {
      Future<List<String>> lookup(String host) async =>
          host == 'nas.lan' ? ['192.168.1.10'] : ['93.184.215.14'];
      expect(await isLocalNetworkHost('nas.lan', lookup: lookup), isTrue);
      expect(await isLocalNetworkHost('example.com', lookup: lookup), isFalse);
    });

    test('a failed lookup is not local', () async {
      Future<List<String>> lookup(String host) async =>
          throw Exception('no dns');
      expect(await isLocalNetworkHost('nas.lan', lookup: lookup), isFalse);
    });
  });
}
