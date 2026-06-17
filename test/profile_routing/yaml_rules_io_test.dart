import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = '''
# top comment
mixed-port: 7890
mode: rule
# dns section
dns:
  enable: true
proxies:
  - {name: A, type: ss}
rules:
  - PROCESS-NAME,com.foo,A
  - DOMAIN-SUFFIX,google.com,DIRECT
  - 'AND,((DOMAIN,x.com),(NETWORK,UDP)),REJECT'
  - MATCH,DIRECT
''';

void main() {
  test('subRuleNames lists the sub-rules: keys, empty when absent', () {
    const withSub =
        'sub-rules:\n  vpn-app-route:\n    - MATCH,VPN\n  browser-route:\n    - MATCH,DIRECT\n';
    expect(const ProfileRulesDocument(withSub).subRuleNames, [
      'vpn-app-route',
      'browser-route',
    ]);
    expect(const ProfileRulesDocument(_sample).subRuleNames, isEmpty);
  });

  test('subRules parses each entry into a rule list', () {
    const doc =
        'sub-rules:\n  vpn:\n    - PROCESS-NAME,com.a,VPN\n    - MATCH,VPN\n';
    final sub = const ProfileRulesDocument(doc).subRules;
    expect(sub.keys, ['vpn']);
    expect(sub['vpn']!.map((r) => r.serialize()).toList(), [
      'PROCESS-NAME,com.a,VPN',
      'MATCH,VPN',
    ]);
  });

  test('withSubRules round-trips and preserves other keys', () {
    const doc = '# top\nmode: rule\n';
    final out = const ProfileRulesDocument(doc).withSubRules({
      'browser': [
        RoutingRule.parse('RULE-SET,ru,DIRECT'),
        RoutingRule.parse('MATCH,VPN'),
      ],
    });
    expect(out, contains('# top'));
    final back = ProfileRulesDocument(out).subRules;
    expect(back['browser']!.map((r) => r.serialize()).toList(), [
      'RULE-SET,ru,DIRECT',
      'MATCH,VPN',
    ]);
  });

  test('empty map removes the sub-rules key', () {
    const doc = 'sub-rules:\n  x:\n    - MATCH,VPN\n';
    final out = const ProfileRulesDocument(doc).withSubRules({});
    expect(ProfileRulesDocument(out).subRules, isEmpty);
  });

  test('reads the rules block', () {
    const doc = ProfileRulesDocument(_sample);
    final rules = doc.rules;
    expect(rules.length, 4);
    expect(rules.first, isA<TypedRule>());
    expect((rules.first as TypedRule).action, RuleAction.PROCESS_NAME);
    // The logical rule reads as a LogicalRule and round-trips verbatim.
    expect(rules[2], isA<LogicalRule>());
    expect(rules[2].serialize(), 'AND,((DOMAIN,x.com),(NETWORK,UDP)),REJECT');
  });

  test('rewrite preserves other keys and comments', () {
    const doc = ProfileRulesDocument(_sample);
    final out = doc.withRules(doc.rules);
    expect(out, contains('# top comment'));
    expect(out, contains('mixed-port: 7890'));
    expect(out, contains('# dns section'));
    expect(out, contains('proxies:'));
    // Re-reading yields the same rule set.
    expect(
      serializeRoutingRules(ProfileRulesDocument(out).rules),
      serializeRoutingRules(doc.rules),
    );
  });

  test('adding a rule shows up and round-trips', () {
    const doc = ProfileRulesDocument(_sample);
    final next = [
      const TypedRule(
        action: RuleAction.PROCESS_NAME,
        value: 'com.bar',
        target: 'Proxy',
      ),
      ...doc.rules,
    ];
    final out = doc.withRules(next);
    final reread = ProfileRulesDocument(out).rules;
    expect(reread.length, 5);
    expect((reread.first as TypedRule).value, 'com.bar');
    expect(out, contains('mixed-port: 7890'));
  });

  test('removing a rule works', () {
    const doc = ProfileRulesDocument(_sample);
    final kept = doc.rules.where((r) => r is! LogicalRule).toList();
    final out = doc.withRules(kept);
    final reread = ProfileRulesDocument(out).rules;
    expect(reread.length, 3);
    expect(reread.any((r) => r is LogicalRule), false);
  });

  test('missing rules key is created', () {
    const noRules = 'mixed-port: 7890\nmode: rule\n';
    const doc = ProfileRulesDocument(noRules);
    expect(doc.rules, isEmpty);
    final out = doc.withRules([
      const TypedRule(action: RuleAction.MATCH, value: '', target: 'DIRECT'),
    ]);
    expect(ProfileRulesDocument(out).rules.length, 1);
    expect(out, contains('mixed-port: 7890'));
  });

  test('non-map root throws', () {
    expect(
      () => const ProfileRulesDocument('- just\n- a\n- list\n').withRules([]),
      throwsA(isA<ProfileRulesWriteException>()),
    );
  });

  test('unparseable document yields empty rules', () {
    expect(const ProfileRulesDocument(':\n  bad: [').rules, isEmpty);
  });
}
