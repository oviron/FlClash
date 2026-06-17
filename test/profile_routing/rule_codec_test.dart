import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('byte-for-byte round-trip', () {
    const corpus = [
      'PROCESS-NAME,com.foo.bar,ProxyGroup',
      'PROCESS-PATH,/system/bin/app,DIRECT',
      'PROCESS-NAME-REGEX,.*chrome.*,Proxy',
      'UID,10086,REJECT',
      'DOMAIN-SUFFIX,google.com,Proxy',
      'IP-CIDR,127.0.0.0/8,DIRECT,no-resolve',
      'GEOIP,CN,DIRECT,no-resolve',
      'MATCH,Proxy',
      'RULE-SET,my-set,Proxy',
      'AND,((DOMAIN,example.com),(NETWORK,UDP)),REJECT',
      'OR,((NETWORK,UDP),(DOMAIN,a.com)),Proxy',
      'NOT,((DOMAIN,example.com)),Proxy',
      'SUB-RULE,(NETWORK,UDP),sub-name',
    ];
    for (final line in corpus) {
      test('"$line"', () {
        expect(RoutingRule.parse(line).serialize(), line);
      });
    }
  });

  group('app-to-sub-rule routing', () {
    test('single PROCESS-NAME clause parses as AppToSubRuleRoute', () {
      final r = RoutingRule.parse(
        'SUB-RULE,(PROCESS-NAME,app.morphe.android.youtube),vpn-app-route',
      );
      expect(r, isA<AppToSubRuleRoute>());
      r as AppToSubRuleRoute;
      expect(r.packageName, 'app.morphe.android.youtube');
      expect(r.subRuleName, 'vpn-app-route');
    });

    test('round-trips byte-for-byte', () {
      const line = 'SUB-RULE,(PROCESS-NAME,com.x),browser-route';
      expect(RoutingRule.parse(line).serialize(), line);
    });

    test('constructed route serializes to the canonical form', () {
      expect(
        const AppToSubRuleRoute(
          packageName: 'com.y',
          subRuleName: 'route',
        ).serialize(),
        'SUB-RULE,(PROCESS-NAME,com.y),route',
      );
    });

    test('non-PROCESS-NAME clause stays Passthrough', () {
      final r = RoutingRule.parse('SUB-RULE,(NETWORK,UDP),sub-name');
      expect(r, isA<PassthroughRule>());
    });

    test('multi-clause AND payload stays Passthrough', () {
      const line = 'SUB-RULE,((PROCESS-NAME,com.a),(NETWORK,TCP)),route';
      final r = RoutingRule.parse(line);
      expect(r, isA<PassthroughRule>());
      expect(r.serialize(), line);
    });

    test('SUB-RULE with a trailing flag stays Passthrough', () {
      const line = 'SUB-RULE,(PROCESS-NAME,com.a),route,no-resolve';
      final r = RoutingRule.parse(line);
      expect(r, isA<PassthroughRule>());
      expect(r.serialize(), line);
    });
  });

  test('process rules parse as TypedRule and flag isAppRouting', () {
    final r = RoutingRule.parse('PROCESS-NAME,com.foo,Grp');
    expect(r, isA<TypedRule>());
    r as TypedRule;
    expect(r.action, RuleAction.PROCESS_NAME);
    expect(r.value, 'com.foo');
    expect(r.target, 'Grp');
    expect(r.isAppRouting, true);
  });

  test('domain rule is typed but not app-routing', () {
    final r = RoutingRule.parse('DOMAIN-SUFFIX,a.com,Proxy') as TypedRule;
    expect(r.isAppRouting, false);
  });

  test('logical rules stay Passthrough', () {
    expect(
      RoutingRule.parse('AND,((DOMAIN,a)),REJECT'),
      isA<PassthroughRule>(),
    );
    expect(RoutingRule.parse('NOT,((DOMAIN,a)),Proxy'), isA<PassthroughRule>());
    expect(
      RoutingRule.parse('SUB-RULE,(NETWORK,UDP),s'),
      isA<PassthroughRule>(),
    );
  });

  test('MATCH carries only a target', () {
    final r = RoutingRule.parse('MATCH,Auto') as TypedRule;
    expect(r.value, '');
    expect(r.target, 'Auto');
    expect(r.serialize(), 'MATCH,Auto');
  });

  test('trailing flags are captured and re-emitted', () {
    final r = RoutingRule.parse('IP-CIDR,10.0.0.0/8,DIRECT,no-resolve');
    r as TypedRule;
    expect(r.noResolve, true);
    expect(r.serialize(), 'IP-CIDR,10.0.0.0/8,DIRECT,no-resolve');
  });

  test('unknown action is Passthrough', () {
    expect(RoutingRule.parse('FOO-BAR,x,y'), isA<PassthroughRule>());
  });

  test('malformed field count stays lossless via Passthrough', () {
    const weird = 'DOMAIN,a,b,Proxy';
    expect(RoutingRule.parse(weird), isA<PassthroughRule>());
    expect(RoutingRule.parse(weird).serialize(), weird);
  });

  test('editing a TypedRule reserializes canonically', () {
    final r = RoutingRule.parse('PROCESS-NAME,com.foo,A') as TypedRule;
    expect(r.copyWith(target: 'B').serialize(), 'PROCESS-NAME,com.foo,B');
  });

  test('whitespace inside fields is preserved', () {
    const spaced = 'PROCESS-NAME, com.foo, Group';
    expect(RoutingRule.parse(spaced).serialize(), spaced);
  });

  test('list helpers round-trip', () {
    const lines = ['PROCESS-NAME,a,X', 'AND,((DOMAIN,b)),Y', 'MATCH,Z'];
    expect(serializeRoutingRules(parseRoutingRules(lines)), lines);
  });

  test(
    'editableRuleActions excludes forms that need nested/special syntax',
    () {
      // The typed editor authors a flat TYPE,value,target; logical and special
      // actions cannot be expressed that way and must not be offered.
      for (final a in const [
        RuleAction.AND,
        RuleAction.OR,
        RuleAction.NOT,
        RuleAction.MATCH,
        RuleAction.RULE_SET,
        RuleAction.SUB_RULE,
      ]) {
        expect(editableRuleActions, isNot(contains(a)), reason: a.value);
      }
      expect(editableRuleActions, contains(RuleAction.PROCESS_NAME));
      expect(editableRuleActions, contains(RuleAction.UID));
      expect(editableRuleActions, contains(RuleAction.DOMAIN_SUFFIX));
    },
  );
}
