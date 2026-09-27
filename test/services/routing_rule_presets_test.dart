import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:fl_clash/services/routing_rule_presets.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal Part I envelope: inline proxy + a single exit group, no routing yet.
const _envelope = '''
proxies:
  - {name: node-a, type: ss, server: a.example, port: 443}
proxy-groups:
  - name: PROXY
    type: url-test
    proxies: [node-a]
    url: http://cp.cloudflare.com/generate_204
''';

RoutingModel _seedWith(List<ScenarioRule> globalRules) => RoutingModel(
  exitGroup: 'PROXY',
  lists: const [],
  scenarios: const [],
  apps: const [],
  globalRules: globalRules,
  defaultRoute: toVpn,
);

List<String> _materialize(List<ScenarioRule> globalRules) {
  final out = _seedWith(globalRules).toYaml(_envelope);
  return ProfileRulesDocument(out).rules.map((r) => r.serialize()).toList();
}

void main() {
  group('RulePreset rules materialize to valid mihomo syntax', () {
    test('blockQuicStunDot rejects QUIC, STUN and DoT', () {
      expect(_materialize(RulePreset.blockQuicStunDot.rules), [
        'AND,((NETWORK,UDP),(DST-PORT,443)),REJECT',
        'AND,((NETWORK,UDP),(DST-PORT,3478/19302)),REJECT',
        'DST-PORT,853,REJECT',
        'MATCH,PROXY',
      ]);
    });

    test('lanDirect bypasses the private/reserved ranges', () {
      expect(_materialize(RulePreset.lanDirect.rules), [
        'GEOIP,private,DIRECT,no-resolve',
        'MATCH,PROXY',
      ]);
    });

    test('systemServicesDirect bypasses Apple and Microsoft geosites', () {
      expect(_materialize(RulePreset.systemServicesDirect.rules), [
        'GEOSITE,apple,DIRECT',
        'GEOSITE,microsoft,DIRECT',
        'MATCH,PROXY',
      ]);
    });

    test('bittorrentDirect bypasses public tracker/PT geosites', () {
      expect(_materialize(RulePreset.bittorrentDirect.rules), [
        'GEOSITE,category-public-tracker,DIRECT',
        'GEOSITE,category-pt,DIRECT',
        'MATCH,PROXY',
      ]);
    });
  });

  group('addRulePreset', () {
    test('re-adding the same preset does not duplicate its rules', () {
      final once = addRulePreset(const [], RulePreset.lanDirect);
      final twice = addRulePreset(once, RulePreset.lanDirect);
      expect(twice, once);
    });

    test(
      'only appends the rules of the preset that are not already present',
      () {
        final existing = [RulePreset.systemServicesDirect.rules.first];
        final result = addRulePreset(existing, RulePreset.systemServicesDirect);
        expect(result, [
          RulePreset.systemServicesDirect.rules.first,
          RulePreset.systemServicesDirect.rules.last,
        ]);
      },
    );

    test('adding a different preset appends on top of an existing one', () {
      final withLan = addRulePreset(const [], RulePreset.lanDirect);
      final withBoth = addRulePreset(withLan, RulePreset.bittorrentDirect);
      expect(withBoth, [...withLan, ...RulePreset.bittorrentDirect.rules]);
    });
  });
}
