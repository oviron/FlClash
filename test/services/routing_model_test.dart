import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

// A sanitized, structurally-faithful copy of the reference power-user profile
// (whitelist TUN + browser smart-split sub-rule + rule-providers + ads REJECT +
// per-app SUB-RULEs + terminal MATCH,REJECT, over untouched DNS/sniffer/mesh).
// No private endpoints/keys: dummy servers only.
const _reference = '''
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
    - com.google.android.youtube
    - com.android.chrome
    - com.example.blocked
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
  - {name: node-b, type: ss, server: b.example, port: 443}
proxy-groups:
  - name: VPN
    type: select
    proxies: [Auto, node-a, node-b]
  - name: Auto
    type: fallback
    hidden: true
    proxies: [node-a, node-b]
    url: http://www.gstatic.com/generate_204
    interval: 90
proxy-providers:
  sub-one:
    type: http
    url: https://sub.example/list.yaml
    path: ./providers/sub-one.yaml
rule-providers:
  ads:
    type: http
    behavior: domain
    format: mrs
    url: https://example/ads.mrs
    path: ./ruleset/ads.mrs
    interval: 86400
  category-bank-ru:
    type: http
    behavior: domain
    format: mrs
    url: https://example/category-bank-ru.mrs
    path: ./ruleset/category-bank-ru.mrs
    interval: 86400
  ru-blocked-domains:
    type: http
    behavior: domain
    format: text
    url: https://example/ru-blocked.txt
    path: ./ruleset/ru-blocked.txt
    interval: 21600
sub-rules:
  vpn-app-route:
    - MATCH,VPN
  browser-route:
    - RULE-SET,ru-blocked-domains,VPN
    - RULE-SET,category-bank-ru,DIRECT
    - DOMAIN-SUFFIX,ru,DIRECT
    - GEOIP,RU,DIRECT,no-resolve
    - MATCH,VPN
rules:
  - IP-CIDR,45.142.164.71/32,DIRECT,no-resolve
  - GEOIP,private,DIRECT,no-resolve
  - RULE-SET,ads,REJECT
  - DOMAIN-SUFFIX,sponsor.ajay.app,DIRECT
  - SUB-RULE,(PROCESS-NAME,org.telegram.messenger),vpn-app-route
  - SUB-RULE,(PROCESS-NAME,com.google.android.youtube),vpn-app-route
  - SUB-RULE,(PROCESS-NAME,com.android.chrome),browser-route
  - PROCESS-NAME,com.example.blocked,REJECT
  - MATCH,REJECT
''';

void main() {
  group('RoutingModel.fromYaml recognizes the reference profile', () {
    final model = RoutingModel.fromYaml(_reference);

    test('recognizes the VPN group as the exit', () {
      expect(model.exitGroup, 'VPN');
    });

    test('adopts every rule-provider as a List (ads included)', () {
      expect(model.lists.map((l) => l.id).toSet(), {
        'ads',
        'category-bank-ru',
        'ru-blocked-domains',
      });
      final bank = model.lists.firstWhere((l) => l.id == 'category-bank-ru');
      expect(bank.kind, ListKind.url);
      expect(bank.behavior, 'domain');
      expect(bank.format, 'mrs');
    });

    test('adopts the smart-split sub-rule as a Scenario', () {
      final browser = model.scenarios.firstWhere(
        (s) => s.name == 'browser-route',
      );
      // RULE-SET,ru-blocked-domains,VPN -> a ListRule to viaVpn.
      final first = browser.rules.first;
      expect(first, isA<ListRule>());
      expect((first as ListRule).listId, 'ru-blocked-domains');
      expect(first.dest, toVpn);
      // RULE-SET,category-bank-ru,DIRECT -> a ListRule to direct.
      final bank = browser.rules[1] as ListRule;
      expect(bank.listId, 'category-bank-ru');
      expect(bank.dest, toBypass);
      // GEOIP,RU -> a country ListRule to direct.
      expect(browser.rules.whereType<CountryRule>().single.countryCode, 'RU');
      // trailing MATCH,VPN -> the scenario default.
      expect(browser.defaultDest, toVpn);
    });

    test(
      'reads per-app assignments from the SUB-RULE + PROCESS-NAME rules',
      () {
        final byPkg = {for (final a in model.apps) a.packageName: a};
        expect(
          byPkg['org.telegram.messenger']!.dest,
          const ToScenario('vpn-app-route'),
        );
        expect(
          byPkg['com.android.chrome']!.dest,
          const ToScenario('browser-route'),
        );
        expect(byPkg['com.example.blocked']!.dest, toBlock);
      },
    );

    test('recognizes the fail-closed default route', () {
      expect(model.defaultRoute, toBlock);
    });

    test('recognizes top-level rules as editable global rules', () {
      // The pre-app, non-terminal top-level rules become editable rows: a list
      // rule (ads -> block), a country rule (private -> direct), and typed
      // matcher rules (IP-CIDR, DOMAIN-SUFFIX -> direct). Nothing stays opaque.
      final g = model.globalRules;
      expect(g.whereType<RawScenarioRule>(), isEmpty);
      final list = g.whereType<ListRule>().single;
      expect(list.listId, 'ads');
      expect(list.dest, toBlock);
      expect(
        g.whereType<CountryRule>().map((r) => r.countryCode),
        contains('private'),
      );
      final matches = g.whereType<MatchRule>().toList();
      expect(
        matches.map((m) => m.value),
        containsAll(['45.142.164.71/32', 'sponsor.ajay.app']),
      );
      // The per-app rules are NOT global rules.
      expect(
        g.whereType<MatchRule>().map((m) => m.action),
        isNot(contains(RuleAction.PROCESS_NAME)),
      );
    });
  });

  group('RoutingModel.toYaml round-trips through the bridge', () {
    test('re-reading a materialized model yields the same overlay', () {
      final model = RoutingModel.fromYaml(_reference);
      final out = model.toYaml(_reference);
      final back = RoutingModel.fromYaml(out);

      expect(back.exitGroup, model.exitGroup);
      expect(
        back.lists.map((l) => l.id).toSet(),
        model.lists.map((l) => l.id).toSet(),
      );
      expect(back.defaultRoute, model.defaultRoute);
      expect(
        {for (final a in back.apps) a.packageName: a.dest},
        {for (final a in model.apps) a.packageName: a.dest},
      );
      final browser = back.scenarios.firstWhere(
        (s) => s.name == 'browser-route',
      );
      expect(browser.defaultDest, toVpn);
      expect((browser.rules.first as ListRule).listId, 'ru-blocked-domains');
      expect(browser.rules.whereType<CountryRule>().single.countryCode, 'RU');
    });

    test('preserves everything the model does not manage', () {
      final out = RoutingModel.fromYaml(_reference).toYaml(_reference);
      // DNS, sniffer, the server mesh, and proxy-providers are untouched.
      expect(out, contains('enhanced-mode: fake-ip'));
      expect(out, contains('sniffer:'));
      expect(out, contains('sub-one'));
      final groups = ProfileRulesDocument(out).proxyGroups.map((g) => g.name);
      expect(groups, containsAll(['VPN', 'Auto']));
      // Anti-loop DIRECT rules and the SponsorBlock carveout survive.
      final rules = ProfileRulesDocument(out).rules.map((r) => r.serialize());
      expect(rules, contains('GEOIP,private,DIRECT,no-resolve'));
      expect(rules, contains('DOMAIN-SUFFIX,sponsor.ajay.app,DIRECT'));
      // A top-level RULE-SET,...,REJECT is not special-cased; it round-trips as-is.
      expect(rules, contains('RULE-SET,ads,REJECT'));
      // Fail-closed stays terminal.
      expect(rules.last, 'MATCH,REJECT');
    });

    test('global rules round-trip, add, and stay editable', () {
      final model = RoutingModel.fromYaml(_reference);
      // Add a typed matcher rule to the editable global chain.
      final edited = model.copyWith(
        globalRules: [
          ...model.globalRules,
          const MatchRule(
            action: RuleAction.DOMAIN,
            value: 'extra.example',
            dest: toVpn,
          ),
        ],
      );
      final out = edited.toYaml(_reference);
      final back = RoutingModel.fromYaml(out);
      // The added matcher and the recognized ads->block rule both survive.
      expect(
        back.globalRules.whereType<MatchRule>().map((m) => m.value),
        contains('extra.example'),
      );
      expect(
        back.globalRules.whereType<ListRule>().any(
          (l) => l.listId == 'ads' && l.dest == toBlock,
        ),
        isTrue,
      );
      // It emits as a real rule, before the per-app rules and terminal.
      final rules = ProfileRulesDocument(out).rules.map((r) => r.serialize());
      expect(rules, contains('DOMAIN,extra.example,VPN'));
      expect(rules, contains('RULE-SET,ads,REJECT'));
      expect(rules.last, 'MATCH,REJECT');
    });

    test('is idempotent (materialize twice is stable)', () {
      final once = RoutingModel.fromYaml(_reference).toYaml(_reference);
      final twice = RoutingModel.fromYaml(once).toYaml(once);
      expect(
        RoutingModel.fromYaml(twice).apps.length,
        RoutingModel.fromYaml(once).apps.length,
      );
      expect(
        ProfileRulesDocument(twice).rules.map((r) => r.serialize()),
        ProfileRulesDocument(once).rules.map((r) => r.serialize()),
      );
    });

    test('materializes a from-zero seed onto a minimal envelope', () {
      // The Part I envelope: inline proxies + a single exit group, no routing.
      const envelope = '''
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
proxy-groups:
  - name: PROXY
    type: url-test
    proxies: [node-a]
    url: http://cp.cloudflare.com/generate_204
''';
      const seed = RoutingModel(
        exitGroup: 'PROXY',
        lists: [
          RoutingList(
            id: 'ads',
            name: 'Ads',
            kind: ListKind.url,
            url: 'https://example/ads.mrs',
            behavior: 'domain',
            format: 'mrs',
          ),
        ],
        scenarios: [],
        apps: [AppAssignment(packageName: 'com.example.app', dest: toVpn)],
        defaultRoute: toBlock,
      );

      final out = seed.toYaml(envelope);
      final back = RoutingModel.fromYaml(out);
      expect(back.exitGroup, 'PROXY');
      expect(back.defaultRoute, toBlock);
      expect(back.lists.single.id, 'ads');
      expect(ProfileRulesDocument(out).includedPackages, ['com.example.app']);
      expect(
        ProfileRulesDocument(out).rules.map((r) => r.serialize()).last,
        'MATCH,REJECT',
      );
      // The envelope's nodes and exit group are intact.
      expect(out, contains('node-a'));
      expect(ProfileRulesDocument(out).proxyGroups.single.name, 'PROXY');
    });

    test('a full-tunnel seed (Part I) round-trips as MATCH,<exit>', () {
      const envelope = '''
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
proxy-groups:
  - name: PROXY
    type: url-test
    proxies: [node-a]
''';
      const fullTunnel = RoutingModel(
        exitGroup: 'PROXY',
        lists: [],
        scenarios: [],
        apps: [],
        defaultRoute: toVpn,
      );
      final out = fullTunnel.toYaml(envelope);
      expect(ProfileRulesDocument(out).rules.map((r) => r.serialize()), [
        'MATCH,PROXY',
      ]);
      expect(RoutingModel.fromYaml(out).defaultRoute, toVpn);
    });
  });

  // A1 deltas: provider-backed (use/filter) groups are the user's PRIMARY
  // topology and must be human-editable SmartGroups (not raw); logic rules stay
  // editable; tunnel mode (whitelist/blacklist) and rename-cascade round-trip.
  const meshProfile = '''
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
proxy-providers:
  govpn:
    type: http
    url: https://sub.example/gov.yaml
    path: ./providers/govpn.yaml
proxy-groups:
  - name: VPN
    type: select
    proxies: [Fast, node-a]
  - name: Fast
    type: url-test
    use: [govpn]
    filter: "govpn-main-"
    interval: 300
    lazy: true
    url: http://cp/generate_204
rules:
  - AND,((DOMAIN,ads.example),(NETWORK,udp)),REJECT
  - MATCH,VPN
''';

  group('A1: provider-backed groups are editable SmartGroups', () {
    final model = RoutingModel.fromYaml(meshProfile);

    test('a use/filter url-test group is a SmartGroup, not raw', () {
      final fast = model.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Fast',
      );
      expect(fast.behavior, GroupBehavior.autoFastest);
      expect(fast.use, ['govpn']);
      expect(fast.filter, 'govpn-main-');
      expect(fast.interval, 300);
      expect(fast.lazy, isTrue);
      expect(model.groups.whereType<RawGroup>(), isEmpty);
    });

    test('use/filter/interval/lazy round-trip', () {
      final out = model.toYaml(meshProfile);
      final back = RoutingModel.fromYaml(out);
      final fast = back.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Fast',
      );
      expect(fast.use, ['govpn']);
      expect(fast.filter, 'govpn-main-');
      expect(fast.interval, 300);
      expect(fast.lazy, isTrue);
    });

    test('editing the filter round-trips', () {
      final edited = model.copyWith(
        groups: [
          for (final g in model.groups)
            if (g is SmartGroup && g.name == 'Fast')
              g.copyWith(filter: 'govpn-backup-')
            else
              g,
        ],
      );
      final back = RoutingModel.fromYaml(edited.toYaml(meshProfile));
      final fast = back.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Fast',
      );
      expect(fast.filter, 'govpn-backup-');
    });

    test('hidden/url/tolerance are typed fields that round-trip', () {
      final model = RoutingModel.fromYaml(_reference);
      final auto = model.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Auto',
      );
      expect(auto.hidden, isTrue);
      expect(auto.url, contains('generate_204'));
      expect(auto.interval, 90);
      // They are typed now, not stashed in `extra`.
      expect(auto.extra.containsKey('hidden'), isFalse);
      expect(auto.extra.containsKey('url'), isFalse);
      final back = RoutingModel.fromYaml(model.toYaml(_reference));
      final auto2 = back.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Auto',
      );
      expect(auto2.hidden, isTrue);
      expect(auto2.url, contains('generate_204'));
      // Clearing hidden drops the key.
      final cleared = model.copyWith(
        groups: [
          for (final g in model.groups)
            if (g is SmartGroup && g.name == 'Auto')
              g.copyWith(hidden: false)
            else
              g,
        ],
      );
      final autoCleared = RoutingModel.fromYaml(
        cleared.toYaml(_reference),
      ).groups.whereType<SmartGroup>().firstWhere((g) => g.name == 'Auto');
      expect(autoCleared.hidden, isFalse);
    });

    test('a pure use-group does not gain a spurious empty proxies key', () {
      final out = model.toYaml(meshProfile);
      final fast = ProfileRulesDocument(
        out,
      ).proxyGroups.firstWhere((g) => g.name == 'Fast');
      expect(fast.raw.containsKey('proxies'), isFalse);
    });
  });

  group('A1: logic rules stay editable', () {
    final model = RoutingModel.fromYaml(meshProfile);

    test('AND/OR/NOT is read as an editable LogicRule', () {
      final logic = model.globalRules.whereType<LogicRule>().single;
      expect(logic.op, RuleAction.AND);
      expect(logic.dest, toBlock);
      expect(logic.clauses.map((c) => c.action), [
        RuleAction.DOMAIN,
        RuleAction.NETWORK,
      ]);
      expect(model.globalRules.whereType<RawScenarioRule>(), isEmpty);
    });

    test('a LogicRule round-trips byte-exact and re-adds', () {
      final out = model.toYaml(meshProfile);
      final rules = ProfileRulesDocument(out).rules.map((r) => r.serialize());
      expect(
        rules,
        contains('AND,((DOMAIN,ads.example),(NETWORK,udp)),REJECT'),
      );
      final back = RoutingModel.fromYaml(out);
      expect(back.globalRules.whereType<LogicRule>().single.op, RuleAction.AND);
    });
  });

  group('A1: tunnel mode', () {
    test('include-package reads as whitelist', () {
      const y = '''
tun:
  include-package: [com.a]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      expect(RoutingModel.fromYaml(y).tunnelMode, TunnelMode.whitelist);
    });

    test('exclude-package reads as blacklist and writes exclude-package', () {
      const y = '''
tun:
  exclude-package: [com.a]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      final model = RoutingModel.fromYaml(y);
      expect(model.tunnelMode, TunnelMode.blacklist);
      final out = model
          .copyWith(
            apps: [const AppAssignment(packageName: 'com.a', dest: toBypass)],
          )
          .toYaml(y);
      expect(ProfileRulesDocument(out).excludedPackages, ['com.a']);
      expect(ProfileRulesDocument(out).includedPackages, isEmpty);
    });

    test('exclude-package reads back as bypass assignments (round-trip)', () {
      const y = '''
tun:
  exclude-package: [com.a, com.b]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      final model = RoutingModel.fromYaml(y);
      final byPkg = {for (final a in model.apps) a.packageName: a};
      expect(byPkg['com.a']?.dest, toBypass);
      expect(byPkg['com.b']?.dest, toBypass);
      final out = model.toYaml(y);
      expect(ProfileRulesDocument(out).excludedPackages, ['com.a', 'com.b']);
    });

    test('excluded package with a process rule reads as bypass (OS wins)', () {
      const y = '''
tun:
  exclude-package: [com.a]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - PROCESS-NAME,com.a,PROXY
  - MATCH,PROXY
''';
      final model = RoutingModel.fromYaml(y);
      final forA = model.apps.where((a) => a.packageName == 'com.a').toList();
      expect(forA.length, 1);
      // OS-level exclusion is authoritative: never upgrade an excluded app to VPN.
      expect(forA.single.dest, toBypass);
    });

    test('include-package member without a rule reads as ToVpn', () {
      const y = '''
tun:
  include-package: [com.a, com.b]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - PROCESS-NAME,com.a,PROXY
  - MATCH,PROXY
''';
      final byPkg = {
        for (final a in RoutingModel.fromYaml(y).apps) a.packageName: a,
      };
      expect(byPkg['com.a']?.dest, toVpn);
      // com.b is in the tunnel via include-package but has no rule: keep membership.
      expect(byPkg['com.b']?.dest, toVpn);
      // Round-trip must not strip com.b from include-package.
      final out = RoutingModel.fromYaml(y).toYaml(y);
      expect(
        ProfileRulesDocument(out).includedPackages,
        containsAll(['com.a', 'com.b']),
      );
    });

    test('both include and exclude present: whitelist, excluded is bypass', () {
      const y = '''
tun:
  include-package: [com.a, com.b]
  exclude-package: [com.b]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      final model = RoutingModel.fromYaml(y);
      expect(model.tunnelMode, TunnelMode.whitelist);
      final byPkg = {for (final a in model.apps) a.packageName: a.dest};
      expect(byPkg['com.a'], toVpn);
      expect(byPkg['com.b'], toBypass);
    });

    test('blacklist with no bypass apps keeps its mode (durable)', () {
      const y = '''
tun:
  exclude-package: [com.a]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      // Remove the only exception: the mode must NOT silently flip to whitelist.
      final emptied = RoutingModel.fromYaml(y).copyWith(apps: const []);
      final out = emptied.toYaml(y);
      expect(ProfileRulesDocument(out).excludedPackages, isNotEmpty);
      final back = RoutingModel.fromYaml(out);
      expect(back.tunnelMode, TunnelMode.blacklist);
      expect(back.apps, isEmpty); // the sentinel is not a user app
    });

    test('whitelist with no VPN apps stays fail-closed (non-empty include)', () {
      const y = '''
tun:
  include-package: [com.a]
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
      final emptied = RoutingModel.fromYaml(y).copyWith(apps: const []);
      final out = emptied.toYaml(y);
      // Empty non-bypass set must NOT remove include-package (that captures all
      // apps). A sentinel keeps the tunnel closed.
      expect(ProfileRulesDocument(out).includedPackages, isNotEmpty);
      // The sentinel is never surfaced back as a user app.
      final back = RoutingModel.fromYaml(out);
      expect(
        back.apps.map((a) => a.packageName),
        isNot(contains('com.follow.clash')),
      );
    });
  });

  group('A1: rename cascades references', () {
    test('renaming a group updates the exit and member references', () {
      final model = RoutingModel.fromYaml(meshProfile);
      final renamed = model.renameGroup('Fast', 'Turbo');
      expect(renamed.groups.map((g) => g.name), contains('Turbo'));
      final vpn = renamed.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'VPN',
      );
      expect(vpn.members, contains('Turbo'));
      expect(vpn.members, isNot(contains('Fast')));
      // The exit itself, when renamed, follows.
      final exitRenamed = model
          .copyWith(exitGroup: 'Fast')
          .renameGroup('Fast', 'Turbo');
      expect(exitRenamed.exitGroup, 'Turbo');
    });

    test('renaming a server updates member and use references', () {
      final model = RoutingModel.fromYaml(meshProfile);
      // node-a is a VPN member; rename it.
      final n = model.renameServer('node-a', 'node-x');
      expect(n.servers.map((s) => s.name), contains('node-x'));
      final vpn = n.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'VPN',
      );
      expect(vpn.members, contains('node-x'));
      expect(vpn.members, isNot(contains('node-a')));
      // govpn is Fast's `use:` source; rename it.
      final s = model.renameServer('govpn', 'gov');
      final fast = s.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'Fast',
      );
      expect(fast.use, ['gov']);
    });

    test('renaming a scenario updates the apps that route to it', () {
      final model = RoutingModel.fromYaml(_reference);
      final r = model.renameScenario('browser-route', 'br');
      expect(r.scenarios.map((s) => s.name), contains('br'));
      expect(r.scenarios.map((s) => s.name), isNot(contains('browser-route')));
      final chrome = r.apps.firstWhere(
        (a) => a.packageName == 'com.android.chrome',
      );
      expect(chrome.dest, const ToScenario('br'));
    });
  });

  group('A: editing server data', () {
    test('editing a node field round-trips', () {
      final m = RoutingModel.fromYaml(meshProfile);
      final nodeA = m.servers.firstWhere((s) => s.name == 'node-a');
      final edited = {...nodeA.proxy!, 'server': 'b.example', 'port': 8443};
      final out = m.updateNode('node-a', edited).toYaml(meshProfile);
      final p = ProfileRulesDocument(
        out,
      ).proxies.firstWhere((x) => x['name'] == 'node-a');
      expect(p['server'], 'b.example');
      expect(p['port'], 8443);
    });

    test('renaming a node via updateNode cascades into group members', () {
      final m = RoutingModel.fromYaml(meshProfile);
      final nodeA = m.servers.firstWhere((s) => s.name == 'node-a');
      final r = m.updateNode('node-a', {...nodeA.proxy!, 'name': 'node-x'});
      expect(r.servers.any((s) => s.name == 'node-x'), isTrue);
      expect(r.servers.any((s) => s.name == 'node-a'), isFalse);
      final vpn = r.groups.whereType<SmartGroup>().firstWhere(
        (g) => g.name == 'VPN',
      );
      expect(vpn.members, contains('node-x'));
    });

    test('editing a subscription URL round-trips', () {
      final m = RoutingModel.fromYaml(meshProfile);
      final out = m
          .updateSubscriptionUrl('govpn', 'https://new.example/g.yaml')
          .toYaml(meshProfile);
      expect(
        ProfileRulesDocument(out).proxyProviders['govpn']!.url,
        'https://new.example/g.yaml',
      );
    });
  });
}
