import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Map<String, dynamic>> _build(
  Map<String, dynamic> rawConfig, {
  bool appendSystemDns = false,
}) {
  return makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig,
      realPatchConfig: defaultClashConfig,
      overrideDns: false,
      appendSystemDns: appendSystemDns,
      addedRules: const [],
      defaultUA: 'ua',
    ),
  );
}

void main() {
  group('a mistyped field from a subscription or script', () {
    test('tun that is not a map is replaced', () async {
      final config = await _build({'tun': true});

      expect(config['tun'], isA<Map<dynamic, dynamic>>());
      expect(config['tun']['stack'], defaultClashConfig.tun.stack.name);
    });

    test('profile and hosts that are not maps are replaced', () async {
      final config = await _build({
        'profile': 'yes',
        'hosts': ['a.example'],
      });

      expect(config['profile'], {'store-selected': false});
      expect(config['hosts'], isA<Map<dynamic, dynamic>>());
    });

    test('sniffer shapes that are not maps are left alone', () async {
      for (final sniffer in [
        true,
        {'sniff': 'HTTP'},
        {
          'sniff': ['HTTP'],
        },
      ]) {
        final config = await _build({'sniffer': sniffer});
        expect(config['sniffer'], sniffer);
      }
    });

    test('sniff ports are still normalized next to a bad entry', () async {
      final config = await _build({
        'sniffer': {
          'sniff': {
            'HTTP': 'bad',
            'TLS': {
              'ports': [443, '8443'],
            },
          },
        },
      });

      expect(config['sniffer']['sniff'], {
        'HTTP': 'bad',
        'TLS': {
          'ports': ['443', '8443'],
        },
      });
    });

    test('providers that are not maps are skipped', () async {
      final config = await _build({
        'proxy-providers': ['a'],
        'rule-providers': {
          'bad': 'oops',
          'numeric-url': {'type': 'http', 'url': 42},
        },
      });

      expect(config['proxy-providers'], ['a']);
      expect(config['rule-providers'], {
        'bad': 'oops',
        'numeric-url': {'type': 'http', 'url': 42, 'proxy': 'DIRECT'},
      });
    });

    test('dns that is not a map falls back to the app DNS', () async {
      final config = await _build({'dns': true});

      expect(config['dns'], isA<Map<dynamic, dynamic>>());
      expect(config['dns']['proxy-server-nameserver'], contains('system://'));
    });

    test('nameserver lists keep only their string entries', () async {
      final config = await _build({
        'dns': {
          'enable': true,
          'proxy-server-nameserver': '8.8.8.8',
          'nameserver': [1, 'tls://1.1.1.1'],
        },
      }, appendSystemDns: true);

      expect(config['dns']['proxy-server-nameserver'], ['system://']);
      expect(config['dns']['nameserver'], ['tls://1.1.1.1', 'system://']);
    });

    test('rules keep only their string entries', () async {
      final scalar = await _build({'rules': 'MATCH,DIRECT'});
      expect(scalar['rules'], ['IN-TYPE,INNER,DIRECT']);

      final mixed = await _build({
        'rules': [
          'MATCH,DIRECT',
          42,
          {'x': 1},
        ],
      });
      expect(mixed['rules'], ['IN-TYPE,INNER,DIRECT', 'MATCH,DIRECT']);
    });
  });
}
