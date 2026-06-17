import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/target_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const _config = '''
proxies:
  - name: SS-A
    type: ss
proxy-groups:
  - name: Auto
    type: url-test
  - name: Manual
    type: select
''';

void main() {
  test('configTargets collects group and proxy names', () {
    expect(configTargets(_config), {'SS-A', 'Auto', 'Manual'});
  });

  test('unparseable config yields empty target set', () {
    expect(configTargets(':\n bad: ['), isEmpty);
  });

  test('configTargets includes sub-rule names', () {
    const cfg = 'sub-rules:\n  vpn-app-route:\n    - MATCH,VPN\n';
    expect(configTargets(cfg), contains('vpn-app-route'));
  });

  test('app->sub-rule route is dangling when the sub-rule is gone', () {
    final rules = [
      RoutingRule.parse('SUB-RULE,(PROCESS-NAME,com.a),present'),
      RoutingRule.parse('SUB-RULE,(PROCESS-NAME,com.b),gone'),
    ];
    expect(danglingTargets(rules, {'present'}), ['gone']);
  });

  test('flags only targets absent from valid set and builtins', () {
    final rules = parseRoutingRules([
      'PROCESS-NAME,com.a,Auto', // valid group
      'PROCESS-NAME,com.b,Gone', // dangling
      'PROCESS-NAME,com.c,DIRECT', // builtin
      'UID,1,REJECT', // builtin
      'AND,((DOMAIN,x)),Whatever', // passthrough -> skipped
    ]);
    expect(danglingTargets(rules, {'Auto', 'Manual'}), ['Gone']);
  });

  test('dedups repeated dangling targets', () {
    final rules = parseRoutingRules([
      'PROCESS-NAME,com.a,Gone',
      'PROCESS-NAME,com.b,Gone',
    ]);
    expect(danglingTargets(rules, const {}), ['Gone']);
  });

  test('end-to-end: dangling resolved against a fresh config', () {
    final rules = parseRoutingRules([
      'PROCESS-NAME,com.a,Manual',
      'PROCESS-NAME,com.b,OldGroup',
    ]);
    expect(danglingTargets(rules, configTargets(_config)), ['OldGroup']);
  });
}
