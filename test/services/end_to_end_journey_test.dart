import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

// The whole product thesis, proven at the config level with zero device and
// zero built-in content: paste a vless link -> a working default profile ->
// reshape it through the constructor model with the user's OWN lists, scenario,
// and per-app intents, never touching YAML.
void main() {
  test('vless link -> default profile -> user-built routing via the model', () {
    // 1. From zero: the user pastes a real vless+reality share link.
    const link =
        'vless://11111111-2222-3333-4444-555555555555@1.2.3.4:443'
        '?security=reality&sni=dl.google.com&fp=chrome&pbk=PUBKEY&sid=ab12'
        '&type=tcp&flow=xtls-rprx-vision#My node';
    final proxies = [parseShareLink(link)!];
    final envelope = yaml.encode(synthesizeConfig(proxies));
    final defaultProfile = applyQuickStartRouting(envelope);

    // The default profile is a valid full tunnel through the pasted node.
    final zero = RoutingModel.fromYaml(defaultProfile);
    expect(zero.exitGroup, 'PROXY');
    expect(zero.defaultRoute, toVpn);
    expect(defaultProfile, contains('1.2.3.4'));
    expect(defaultProfile, contains('reality-opts'));

    // 2. The user configures it entirely from their OWN sources: two lists
    //    they connected (a blocklist by URL, a domestic set by URL), a scenario
    //    they built, per-app intents, and fail-closed unlisted apps.
    final configured = zero
        .copyWith(
          lists: const [
            RoutingList(
              id: 'my-blocklist',
              name: 'my-blocklist',
              kind: ListKind.url,
              url: 'https://example.com/blocked.mrs',
              behavior: 'domain',
              format: 'mrs',
            ),
            RoutingList(
              id: 'home-sites',
              name: 'home-sites',
              kind: ListKind.url,
              url: 'https://example.com/home.mrs',
              behavior: 'domain',
              format: 'mrs',
            ),
          ],
          scenarios: const [
            Scenario(
              name: 'smart-split',
              rules: [
                ListRule(listId: 'my-blocklist', dest: toVpn),
                ListRule(listId: 'home-sites', dest: toBypass),
                CountryRule(countryCode: 'RU', dest: toBypass),
              ],
              defaultDest: toVpn,
            ),
          ],
          apps: const [
            AppAssignment(packageName: 'org.telegram.messenger', dest: toVpn),
            AppAssignment(
              packageName: 'com.android.chrome',
              dest: ToScenario('smart-split'),
            ),
            AppAssignment(packageName: 'com.some.game', dest: toBlock),
          ],
          defaultRoute: toBlock,
        )
        .toYaml(defaultProfile);

    final doc = ProfileRulesDocument(configured);

    // The pasted node and its Reality params survive verbatim.
    expect(configured, contains('PUBKEY'));
    expect(configured, contains('xtls-rprx-vision'));

    // Whitelist: in-VPN and blocked apps enter the tunnel; the smart-split
    // browser is whitelisted too. (Block = enter tunnel then REJECT = no net.)
    expect(
      doc.includedPackages,
      containsAll([
        'org.telegram.messenger',
        'com.android.chrome',
        'com.some.game',
      ]),
    );

    // The user's lists became rule-providers, keyed by the names they gave.
    expect(doc.ruleProviders.keys, containsAll(['my-blocklist', 'home-sites']));

    // The scenario they built became a named sub-rule.
    expect(doc.subRuleNames, contains('smart-split'));
    final split = doc.subRules['smart-split']!.map((r) => r.serialize());
    expect(split, contains('RULE-SET,my-blocklist,PROXY'));
    expect(split, contains('RULE-SET,home-sites,DIRECT'));
    expect(split, contains('GEOIP,RU,DIRECT,no-resolve'));
    expect(split.last, 'MATCH,PROXY');

    // Top-level rules: per-app routing and the fail-closed terminal.
    final rules = doc.rules.map((r) => r.serialize());
    expect(
      rules,
      contains('SUB-RULE,(PROCESS-NAME,com.android.chrome),smart-split'),
    );
    expect(rules, contains('PROCESS-NAME,com.some.game,REJECT'));
    expect(rules.last, 'MATCH,REJECT');

    // The whole thing round-trips back into the same human model.
    final back = RoutingModel.fromYaml(configured);
    expect(back.defaultRoute, toBlock);
    expect(back.scenarios.any((s) => s.name == 'smart-split'), isTrue);
    expect(
      back.apps.firstWhere((a) => a.packageName == 'com.android.chrome').dest,
      const ToScenario('smart-split'),
    );
  });
}
