import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

// A config carrying a real server layer: inline nodes, a subscription, and the
// group shapes: manual select, auto url-test, a clean provider-backed use group
// (now human-editable), and a genuinely exotic load-balance group (stays raw).
const _withServers = '''
mode: rule
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443, cipher: aes-256-gcm, password: pw}
  - {name: node-b, type: vless, server: b.example, port: 443, uuid: u1, tls: true}
proxy-providers:
  sub-one:
    type: http
    url: https://sub.example/list
    path: ./providers/sub-one.yaml
proxy-groups:
  - {name: VPN, type: select, proxies: [Auto, node-a, node-b]}
  - name: Auto
    type: url-test
    proxies: [node-a, node-b]
    url: http://www.gstatic.com/generate_204
    interval: 90
  - {name: FromSub, type: select, use: [sub-one]}
  - {name: Balance, type: load-balance, use: [sub-one], strategy: round-robin}
rules:
  - MATCH,VPN
''';

void main() {
  group('RoutingModel reads the server layer', () {
    final model = RoutingModel.fromYaml(_withServers);

    test('adopts inline nodes and subscriptions as servers', () {
      expect(model.servers.map((s) => s.name).toSet(), {
        'node-a',
        'node-b',
        'sub-one',
      });
      final a = model.servers.firstWhere((s) => s.name == 'node-a');
      expect(a, isA<NodeSource>());
      expect((a as NodeSource).proxy['cipher'], 'aes-256-gcm');
      final sub = model.servers.firstWhere((s) => s.name == 'sub-one');
      expect(sub, isA<SubscriptionSource>());
      expect((sub as SubscriptionSource).url, 'https://sub.example/list');
    });

    test(
      'recognizes group behaviors, incl. clean provider-backed use groups',
      () {
        final vpn = model.groups.whereType<SmartGroup>().firstWhere(
          (g) => g.name == 'VPN',
        );
        expect(vpn.behavior, GroupBehavior.manual);
        final auto = model.groups.whereType<SmartGroup>().firstWhere(
          (g) => g.name == 'Auto',
        );
        expect(auto.behavior, GroupBehavior.autoFastest);
        expect(auto.members, ['node-a', 'node-b']);
        // A clean `use:`-backed group is now human-editable (source = subscription).
        final fromSub = model.groups.whereType<SmartGroup>().firstWhere(
          (g) => g.name == 'FromSub',
        );
        expect(fromSub.use, ['sub-one']);
        // Only a genuinely exotic group (load-balance + strategy) stays raw.
        expect(model.groups.whereType<RawGroup>().single.name, 'Balance');
      },
    );

    test('the exit is the top-level VPN group', () {
      expect(model.exitGroup, 'VPN');
    });
  });

  group('RoutingModel writes the server layer', () {
    test(
      'round-trips servers and groups, preserving the raw provider group',
      () {
        final model = RoutingModel.fromYaml(_withServers);
        final out = model.toYaml(_withServers);
        final back = RoutingModel.fromYaml(out);

        expect(
          back.servers.map((s) => s.name).toSet(),
          model.servers.map((s) => s.name).toSet(),
        );
        expect(back.groups.whereType<SmartGroup>().map((g) => g.name).toSet(), {
          'VPN',
          'Auto',
          'FromSub',
        });
        // The exotic load-balance group stays raw across the round-trip.
        expect(back.groups.whereType<RawGroup>().single.name, 'Balance');
        // node-a keeps its protocol fields.
        final a = back.servers.firstWhere((s) => s.name == 'node-a');
        expect((a as NodeSource).proxy['cipher'], 'aes-256-gcm');
        // The provider-backed groups and their `use:` survive verbatim.
        expect(out, contains('use:'));
        expect(
          ProfileRulesDocument(out).proxyProviders.keys,
          contains('sub-one'),
        );
      },
    );

    test('adding a node and an auto group materializes correctly', () {
      const envelope = '''
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
proxy-groups:
  - {name: PROXY, type: url-test, proxies: [node-a]}
rules:
  - MATCH,PROXY
''';
      final model = RoutingModel.fromYaml(envelope);
      final withNode = model.copyWith(
        servers: [
          ...model.servers,
          const ServerSource.node(
            name: 'node-b',
            proxy: {
              'name': 'node-b',
              'type': 'ss',
              'server': 'b.example',
              'port': 443,
            },
          ),
        ],
        groups: [
          ...model.groups,
          const SmartGroup(
            name: 'Fastest',
            behavior: GroupBehavior.autoFastest,
            members: ['node-a', 'node-b'],
          ),
        ],
      );

      final out = withNode.toYaml(envelope);
      final doc = ProfileRulesDocument(out);
      expect(
        doc.proxies.map((p) => p['name']).toSet(),
        containsAll(['node-a', 'node-b']),
      );
      final fastest = doc.proxyGroups.firstWhere((g) => g.name == 'Fastest');
      expect(fastest.type, 'url-test');
      expect(fastest.proxies, ['node-a', 'node-b']);
    });

    test('failover and manual behaviors map to fallback and select', () {
      const envelope = 'proxies: []\nproxy-groups: []\nrules: [MATCH,DIRECT]\n';
      final model = RoutingModel.fromYaml(envelope).copyWith(
        groups: const [
          SmartGroup(
            name: 'Backup',
            behavior: GroupBehavior.failover,
            members: ['a', 'b'],
          ),
          SmartGroup(
            name: 'Choose',
            behavior: GroupBehavior.manual,
            members: ['a', 'b'],
          ),
        ],
      );
      final doc = ProfileRulesDocument(model.toYaml(envelope));
      expect(
        doc.proxyGroups.firstWhere((g) => g.name == 'Backup').type,
        'fallback',
      );
      expect(
        doc.proxyGroups.firstWhere((g) => g.name == 'Choose').type,
        'select',
      );
    });
  });
}
