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
      'SUB-RULE,(DOMAIN-SUFFIX,ya.ru),browser-route',
      'SUB-RULE,(GEOIP,RU),browser-route',
      'SUB-RULE,(RULE-SET,ads),browser-route',
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

    test('non-PROCESS-NAME single clause parses as SubRuleRoute', () {
      final r = RoutingRule.parse(
        'SUB-RULE,(DOMAIN-SUFFIX,ya.ru),browser-route',
      );
      expect(r, isA<SubRuleRoute>());
      r as SubRuleRoute;
      expect(r.action, RuleAction.DOMAIN_SUFFIX);
      expect(r.params, 'ya.ru');
      expect(r.subRuleName, 'browser-route');
      expect(r.serialize(), 'SUB-RULE,(DOMAIN-SUFFIX,ya.ru),browser-route');
    });

    test('a RULE-SET sub-rule clause parses as SubRuleRoute', () {
      final r =
          RoutingRule.parse('SUB-RULE,(RULE-SET,ads),route') as SubRuleRoute;
      expect(r.action, RuleAction.RULE_SET);
      expect(r.params, 'ads');
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

  group('wildcard matchers are typed (not Passthrough)', () {
    test('DOMAIN-WILDCARD parses as TypedRule, not app-routing', () {
      final r = RoutingRule.parse('DOMAIN-WILDCARD,*.example.com,DIRECT');
      expect(r, isA<TypedRule>());
      r as TypedRule;
      expect(r.action, RuleAction.DOMAIN_WILDCARD);
      expect(r.value, '*.example.com');
      expect(r.target, 'DIRECT');
      expect(r.isAppRouting, false);
      expect(r.serialize(), 'DOMAIN-WILDCARD,*.example.com,DIRECT');
    });

    test('PROCESS-NAME-WILDCARD is a typed app-routing rule', () {
      final r = RoutingRule.parse('PROCESS-NAME-WILDCARD,com.foo.*,Proxy');
      expect(r, isA<TypedRule>());
      r as TypedRule;
      expect(r.action, RuleAction.PROCESS_NAME_WILDCARD);
      expect(r.value, 'com.foo.*');
      expect(r.isAppRouting, true);
      expect(r.serialize(), 'PROCESS-NAME-WILDCARD,com.foo.*,Proxy');
    });

    test('PROCESS-PATH-WILDCARD is a typed app-routing rule', () {
      final r = RoutingRule.parse(
        'PROCESS-PATH-WILDCARD,/data/*/base.apk,DIRECT',
      );
      expect(r, isA<TypedRule>());
      r as TypedRule;
      expect(r.action, RuleAction.PROCESS_PATH_WILDCARD);
      expect(r.isAppRouting, true);
      expect(r.serialize(), 'PROCESS-PATH-WILDCARD,/data/*/base.apk,DIRECT');
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

  test('flat AND/OR/NOT parse as LogicalRule and round-trip', () {
    final and =
        RoutingRule.parse('AND,((DOMAIN,a),(NETWORK,UDP)),REJECT')
            as LogicalRule;
    expect(and.op, RuleAction.AND);
    expect(and.clauses.length, 2);
    expect(and.clauses.first.action, RuleAction.DOMAIN);
    expect(and.clauses.first.params, 'a');
    expect(and.target, 'REJECT');
    expect(and.serialize(), 'AND,((DOMAIN,a),(NETWORK,UDP)),REJECT');
    expect(RoutingRule.parse('NOT,((DOMAIN,a)),Proxy'), isA<LogicalRule>());
  });

  test('a logical clause keeps its raw params (flags stay inside)', () {
    final r =
        RoutingRule.parse('AND,((GEOIP,CN,no-resolve),(NETWORK,UDP)),DIRECT')
            as LogicalRule;
    expect(r.clauses.first.action, RuleAction.GEOIP);
    expect(r.clauses.first.params, 'CN,no-resolve');
    expect(r.serialize(), 'AND,((GEOIP,CN,no-resolve),(NETWORK,UDP)),DIRECT');
  });

  test('a logical rule trailing flag round-trips', () {
    const line = 'AND,((DOMAIN,a)),DIRECT,no-resolve';
    final r = RoutingRule.parse(line) as LogicalRule;
    expect(r.noResolve, isTrue);
    expect(r.serialize(), line);
  });

  test('nested logical or bad NOT arity stay Passthrough', () {
    expect(
      RoutingRule.parse('AND,((AND,((DOMAIN,a))),(NETWORK,UDP)),X'),
      isA<PassthroughRule>(),
    );
    expect(
      RoutingRule.parse('NOT,((DOMAIN,a),(NETWORK,UDP)),X'),
      isA<PassthroughRule>(),
    );
    expect(
      RoutingRule.parse('SUB-RULE,((DOMAIN,a),(NETWORK,UDP)),s'),
      isA<PassthroughRule>(),
    );
  });

  test('editing a logical clause reserializes canonically', () {
    final r =
        RoutingRule.parse('AND,((DOMAIN,a),(NETWORK,UDP)),REJECT')
            as LogicalRule;
    final edited = r.copyWith(
      clauses: [
        const LogicalClause(action: RuleAction.DOMAIN_SUFFIX, params: 'b.com'),
        r.clauses[1],
      ],
      target: 'Proxy',
    );
    expect(
      edited.serialize(),
      'AND,((DOMAIN-SUFFIX,b.com),(NETWORK,UDP)),Proxy',
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

  group('src trailing flag (T3)', () {
    test('src alone parses and round-trips', () {
      final r = RoutingRule.parse('IP-CIDR,10.0.0.0/8,DIRECT,src') as TypedRule;
      expect(r.src, isTrue);
      expect(r.noResolve, isFalse);
      expect(r.serialize(), 'IP-CIDR,10.0.0.0/8,DIRECT,src');
    });

    test('src before no-resolve is the canonical order', () {
      final r =
          RoutingRule.parse('SRC-IP-CIDR,192.168.0.0/16,REJECT,src,no-resolve')
              as TypedRule;
      expect(r.src, isTrue);
      expect(r.noResolve, isTrue);
      expect(r.serialize(), 'SRC-IP-CIDR,192.168.0.0/16,REJECT,src,no-resolve');
    });

    test('reversed flags canonicalize to src,no-resolve on re-serialize', () {
      // parse strips flags in any order; serialize re-emits the canonical order.
      expect(
        RoutingRule.parse(
          'IP-CIDR,10.0.0.0/8,DIRECT,no-resolve,src',
        ).serialize(),
        'IP-CIDR,10.0.0.0/8,DIRECT,src,no-resolve',
      );
    });

    test('a logical rule carries src too', () {
      final r =
          RoutingRule.parse('AND,((DOMAIN,a)),DIRECT,src,no-resolve')
              as LogicalRule;
      expect(r.src, isTrue);
      expect(r.noResolve, isTrue);
      expect(r.serialize(), 'AND,((DOMAIN,a)),DIRECT,src,no-resolve');
    });
  });

  group('constructed-rule round-trip: parse(serialize(r)) == r (D5)', () {
    const rules = <RoutingRule>[
      TypedRule(action: RuleAction.DOMAIN, value: 'a.com', target: 'DIRECT'),
      TypedRule(
        action: RuleAction.GEOIP,
        value: 'CN',
        target: 'PROXY',
        noResolve: true,
      ),
      TypedRule(
        action: RuleAction.IP_CIDR,
        value: '10.0.0.0/8',
        target: 'DIRECT',
        src: true,
      ),
      TypedRule(
        action: RuleAction.SRC_IP_CIDR,
        value: '192.168.0.0/16',
        target: 'REJECT',
        src: true,
        noResolve: true,
      ),
      TypedRule(action: RuleAction.MATCH, value: '', target: 'PROXY'),
      AppToSubRuleRoute(packageName: 'com.x', subRuleName: 'route'),
      SubRuleRoute(
        action: RuleAction.DOMAIN_SUFFIX,
        params: 'ya.ru',
        subRuleName: 'route',
      ),
      SubRuleRoute(
        action: RuleAction.GEOIP,
        params: 'CN,no-resolve',
        subRuleName: 'route',
      ),
      LogicalRule(
        op: RuleAction.AND,
        clauses: [
          LogicalClause(action: RuleAction.DOMAIN, params: 'a.com'),
          LogicalClause(action: RuleAction.NETWORK, params: 'UDP'),
        ],
        target: 'REJECT',
      ),
      LogicalRule(
        op: RuleAction.OR,
        clauses: [
          LogicalClause(action: RuleAction.GEOIP, params: 'CN,no-resolve'),
        ],
        target: 'PROXY',
        src: true,
        noResolve: true,
      ),
      PassthroughRule('AND,((AND,((DOMAIN,a))),(NETWORK,UDP)),X'),
    ];
    for (final r in rules) {
      test('${r.runtimeType}: ${r.serialize()}', () {
        expect(RoutingRule.parse(r.serialize()), r);
      });
    }
  });

  test('every non-logical action round-trips as a TypedRule (D5)', () {
    const logical = {
      RuleAction.AND,
      RuleAction.OR,
      RuleAction.NOT,
      RuleAction.SUB_RULE,
      RuleAction.MATCH,
    };
    for (final action in RuleAction.values) {
      if (logical.contains(action)) continue;
      final r = TypedRule(action: action, value: 'x', target: 'DIRECT');
      expect(
        RoutingRule.parse(r.serialize()),
        r,
        reason: '${action.value} did not round-trip',
      );
    }
  });

  test('an unknown rule type survives verbatim as a PassthroughRule (D5)', () {
    const line = 'MYSTERY-TYPE,payload,DIRECT,extra';
    final r = RoutingRule.parse(line);
    expect(r, isA<PassthroughRule>());
    expect(r.serialize(), line);
  });
}
