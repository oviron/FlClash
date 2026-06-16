import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';

// The power table edits the profile's rules: list through ProfileRulesDocument;
// these exercise that data path: typed edits apply, passthrough stays verbatim,
// order is honoured.
const _doc = '''
mixed-port: 7890
rules:
  - PROCESS-NAME,com.a,GrpA
  - DOMAIN-SUFFIX,x.com,DIRECT
  - 'AND,((DOMAIN,y.com),(NETWORK,UDP)),REJECT'
  - MATCH,Proxy
''';

List<RoutingRule> _rules(String c) => ProfileRulesDocument(c).rules;
List<String> _ser(String c) => serializeRoutingRules(_rules(c));

const _passthrough = 'AND,((DOMAIN,y.com),(NETWORK,UDP)),REJECT';

void main() {
  test('projection splits typed vs passthrough/MATCH', () {
    final rules = _rules(_doc);
    expect(rules[0], isA<TypedRule>());
    expect((rules[0] as TypedRule).action, RuleAction.PROCESS_NAME);
    expect(rules[2], isA<PassthroughRule>());
    expect((rules[3] as TypedRule).action, RuleAction.MATCH);
  });

  test('editing a typed rule target preserves passthrough verbatim', () {
    final rules = _rules(_doc);
    rules[0] = (rules[0] as TypedRule).copyWith(target: 'GrpB');
    final out = const ProfileRulesDocument(_doc).withRules(rules);
    final reread = _ser(out);
    expect(reread.contains('PROCESS-NAME,com.a,GrpB'), true);
    expect(reread.contains(_passthrough), true);
    expect(out, contains('mixed-port: 7890'));
  });

  test('reorder persists order, passthrough survives', () {
    final rules = _rules(_doc);
    final moved = [rules[1], rules[2], rules[0], rules[3]];
    final out = const ProfileRulesDocument(_doc).withRules(moved);
    final reread = _ser(out);
    expect(reread.first, 'DOMAIN-SUFFIX,x.com,DIRECT');
    expect(reread[2], 'PROCESS-NAME,com.a,GrpA');
    expect(reread.contains(_passthrough), true);
  });

  test('delete removes one rule, others intact', () {
    final rules = _rules(_doc)..removeAt(0);
    final out = const ProfileRulesDocument(_doc).withRules(rules);
    final reread = _ser(out);
    expect(reread.length, 3);
    expect(reread.any((r) => r.startsWith('PROCESS-NAME')), false);
    expect(reread.contains(_passthrough), true);
  });

  test('adding a typed rule at the front lands first', () {
    final rules = [
      const TypedRule(
        action: RuleAction.PROCESS_NAME,
        value: 'com.new',
        target: 'GrpA',
      ),
      ..._rules(_doc),
    ];
    final out = const ProfileRulesDocument(_doc).withRules(rules);
    expect(_ser(out).first, 'PROCESS-NAME,com.new,GrpA');
  });
}
