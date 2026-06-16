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
  test('reads the rules block', () {
    const doc = ProfileRulesDocument(_sample);
    final rules = doc.rules;
    expect(rules.length, 4);
    expect(rules.first, isA<TypedRule>());
    expect((rules.first as TypedRule).action, RuleAction.PROCESS_NAME);
    // The logical rule survives read as Passthrough.
    expect(rules[2], isA<PassthroughRule>());
    expect(
      (rules[2] as PassthroughRule).raw,
      'AND,((DOMAIN,x.com),(NETWORK,UDP)),REJECT',
    );
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
    final kept = doc.rules.where((r) => r is! PassthroughRule).toList();
    final out = doc.withRules(kept);
    final reread = ProfileRulesDocument(out).rules;
    expect(reread.length, 3);
    expect(reread.any((r) => r is PassthroughRule), false);
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
