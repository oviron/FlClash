import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

// A sanitized copy of the FULL power-user profile shape: multi-node exit,
// subscriptions, a select exit over fallback tiers + url-test pools + the
// provider filter-split mesh, and the whole routing doctrine. Proves the
// "load my current profile -> it is 100% reflected in the UI and round-trips"
// path: the provider `use:`/`filter:` groups are now modeled as human-editable
// groups (the user's primary topology); only DNS/sniffer/hardening stay
// verbatim. No private endpoints/keys.
const _fullProfile = '''
mode: rule
ipv6: false
dns:
  enable: true
  enhanced-mode: fake-ip
sniffer:
  enable: true
tun:
  enable: true
  include-package:
    - org.telegram.messenger
    - com.android.chrome
proxies:
  - {name: qde-a, type: vless, server: a.example, port: 443, uuid: u1, tls: true}
  - {name: qde-b, type: ss, server: b.example, port: 8388, cipher: aes-256-gcm, password: pw}
  - {name: qde-c, type: hysteria2, server: c.example, port: 443, password: pw2}
proxy-providers:
  govpn:
    type: http
    url: https://sub.example/govpn
    path: ./providers/govpn.yaml
  blancvpn:
    type: http
    url: https://sub.example/blancvpn
    path: ./providers/blancvpn.yaml
proxy-groups:
  - {name: VPN, type: select, proxies: [Auto, qde, GoVPN-Main, qde-a]}
  - name: Auto
    type: fallback
    proxies: [qde, GoVPN-Main]
    url: http://www.gstatic.com/generate_204
    interval: 90
  - name: qde
    type: url-test
    hidden: true
    proxies: [qde-a, qde-b, qde-c]
    url: http://www.gstatic.com/generate_204
    interval: 90
  - name: GoVPN-Main
    type: url-test
    hidden: true
    use: [govpn]
    filter: "govpn-main-"
  - {name: BlancVPN, type: select, use: [blancvpn]}
rule-providers:
  ads:
    type: http
    behavior: domain
    format: mrs
    url: https://example/ads.mrs
    path: ./ruleset/ads.mrs
  category-bank-ru:
    type: http
    behavior: domain
    format: mrs
    url: https://example/category-bank-ru.mrs
    path: ./ruleset/category-bank-ru.mrs
sub-rules:
  vpn-app-route:
    - MATCH,VPN
  browser-route:
    - RULE-SET,category-bank-ru,DIRECT
    - GEOIP,RU,DIRECT,no-resolve
    - MATCH,VPN
rules:
  - GEOIP,private,DIRECT,no-resolve
  - RULE-SET,ads,REJECT
  - SUB-RULE,(PROCESS-NAME,org.telegram.messenger),vpn-app-route
  - SUB-RULE,(PROCESS-NAME,com.android.chrome),browser-route
  - MATCH,REJECT
''';

void main() {
  final model = RoutingModel.fromYaml(_fullProfile);

  group('the full profile is reflected in the model', () {
    test('every node and subscription is a server', () {
      final nodes = model.servers.where((s) => s.kind == ServerKind.node);
      final subs = model.servers.where(
        (s) => s.kind == ServerKind.subscription,
      );
      expect(nodes.map((s) => s.name).toSet(), {'qde-a', 'qde-b', 'qde-c'});
      expect(subs.map((s) => s.name).toSet(), {'govpn', 'blancvpn'});
    });

    test(
      'all groups are human-editable, incl. the provider filter-split mesh',
      () {
        final smart = {
          for (final g in model.groups.whereType<SmartGroup>()) g.name: g,
        };
        expect(smart['VPN']!.behavior, GroupBehavior.manual);
        expect(smart['Auto']!.behavior, GroupBehavior.failover);
        expect(smart['qde']!.behavior, GroupBehavior.autoFastest);
        // Provider `use:`/`filter:` groups are the user's PRIMARY topology, so
        // they are modeled (source = subscription + regex), not dumped to raw.
        expect(smart['GoVPN-Main']!.use, ['govpn']);
        expect(smart['GoVPN-Main']!.filter, 'govpn-main-');
        expect(smart['BlancVPN']!.use, ['blancvpn']);
        expect(model.groups.whereType<RawGroup>(), isEmpty);
      },
    );

    test('the whole routing doctrine is recognized', () {
      expect(model.exitGroup, 'VPN');
      expect(model.lists.map((l) => l.id).toSet(), {'ads', 'category-bank-ru'});
      expect(model.scenarios.map((s) => s.name), contains('browser-route'));
      expect(model.defaultRoute, toBlock);
      final byPkg = {
        for (final a in model.apps)
          a.packageName: switch (a.dest) {
            ToScenario(:final name) => name,
            _ => null,
          },
      };
      expect(byPkg['org.telegram.messenger'], 'vpn-app-route');
      expect(byPkg['com.android.chrome'], 'browser-route');
    });
  });

  group('the full profile round-trips through the bridge', () {
    final out = model.toYaml(_fullProfile);
    final back = RoutingModel.fromYaml(out);

    test('servers, groups and routing survive re-materialization', () {
      expect(
        back.servers.map((s) => s.name).toSet(),
        model.servers.map((s) => s.name).toSet(),
      );
      expect(back.groups.whereType<SmartGroup>().length, 5);
      expect(back.groups.whereType<RawGroup>().length, 0);
      expect(back.exitGroup, 'VPN');
      expect(back.lists.map((l) => l.id).toSet(), {'ads', 'category-bank-ru'});
    });

    test('the power-user mesh and hardening are preserved verbatim', () {
      // The provider filter-split survives byte-for-byte.
      expect(out, contains('filter:'));
      expect(out, contains('govpn-main-'));
      expect(out, contains('use:'));
      // DNS/sniffer hardening untouched.
      expect(out, contains('enhanced-mode: fake-ip'));
      expect(out, contains('sniffer:'));
      // Anti-loop DIRECT and fail-closed terminal intact.
      final rules = ProfileRulesDocument(out).rules.map((r) => r.serialize());
      expect(rules, contains('GEOIP,private,DIRECT,no-resolve'));
      expect(rules.last, 'MATCH,REJECT');
    });

    test('materialize is idempotent', () {
      final twice = RoutingModel.fromYaml(out).toYaml(out);
      expect(
        ProfileRulesDocument(twice).proxyGroups.map((g) => g.name),
        ProfileRulesDocument(out).proxyGroups.map((g) => g.name),
      );
      expect(
        ProfileRulesDocument(twice).rules.map((r) => r.serialize()),
        ProfileRulesDocument(out).rules.map((r) => r.serialize()),
      );
    });
  });

  // Simulates a real editor session: a sequence of edits across every step,
  // proving the new capabilities compose without corrupting each other.
  group('a full editor session composes cleanly', () {
    test(
      'groups, rules, lists, tunnel mode and a rename round-trip together',
      () {
        var m = RoutingModel.fromYaml(_fullProfile);
        // 1. Tighten a provider group's regex filter (Groups step).
        m = m.copyWith(
          groups: [
            for (final g in m.groups)
              if (g is SmartGroup && g.name == 'GoVPN-Main')
                g.copyWith(filter: 'govpn-premium-')
              else
                g,
          ],
        );
        // 2. Prepend a combined AND rule to the global chain (Rules step).
        m = m.copyWith(
          globalRules: [
            const LogicRule(
              op: RuleAction.AND,
              clauses: [
                LogicalClause(
                  action: RuleAction.DOMAIN_SUFFIX,
                  params: 'track.example',
                ),
                LogicalClause(action: RuleAction.NETWORK, params: 'udp'),
              ],
              dest: toBlock,
            ),
            ...m.globalRules,
          ],
        );
        // 3. Change a list's match type (Lists step).
        m = m.copyWith(
          lists: [
            for (final l in m.lists)
              if (l.id == 'ads') l.copyWith(behavior: 'classical') else l,
          ],
        );
        // 4. Flip to blacklist tunnel mode with a bypass app (App routing step).
        m = m.copyWith(
          tunnelMode: TunnelMode.blacklist,
          apps: [
            ...m.apps,
            const AppAssignment(packageName: 'com.bypass.me', dest: toBypass),
          ],
        );
        // 5. Rename the exit group; the exit selection follows (Groups step).
        m = m.renameGroup('VPN', 'Exit');

        final out = m.toYaml(_fullProfile);
        final back = RoutingModel.fromYaml(out);
        expect(
          back.groups
              .whereType<SmartGroup>()
              .firstWhere((g) => g.name == 'GoVPN-Main')
              .filter,
          'govpn-premium-',
        );
        expect(
          back.globalRules.whereType<LogicRule>().single.op,
          RuleAction.AND,
        );
        expect(
          back.lists.firstWhere((l) => l.id == 'ads').behavior,
          'classical',
        );
        expect(back.tunnelMode, TunnelMode.blacklist);
        expect(
          ProfileRulesDocument(out).excludedPackages,
          contains('com.bypass.me'),
        );
        expect(back.exitGroup, 'Exit');
        expect(back.groups.any((g) => g.name == 'Exit'), isTrue);
        // The whole edited profile is still valid and stable on re-materialize.
        final twice = back.toYaml(out);
        expect(
          ProfileRulesDocument(twice).rules.map((r) => r.serialize()),
          ProfileRulesDocument(out).rules.map((r) => r.serialize()),
        );
      },
    );
  });
}
