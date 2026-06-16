import 'package:fl_clash/profile_routing/reapply.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';

String _doc(List<String> rules) =>
    'mixed-port: 7890\nrules:\n${rules.map((r) => '  - $r').join('\n')}\n';

List<String> _rulesOf(String content) =>
    serializeRoutingRules(ProfileRulesDocument(content).rules);

void main() {
  test('no prior app rules leaves fresh untouched', () {
    final fresh = _doc(['DOMAIN-SUFFIX,a.com,DIRECT', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: _doc(['MATCH,Proxy']), fresh: fresh);
    expect(r.changed, false);
    expect(r.content, fresh);
  });

  test('dropped user app rule is re-added at the front', () {
    final previous = _doc(['PROCESS-NAME,com.a,GrpA', 'MATCH,Proxy']);
    final fresh = _doc(['DOMAIN-SUFFIX,a.com,DIRECT', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: previous, fresh: fresh);
    expect(r.overlaid, 1);
    expect(r.conflicts, 0);
    expect(_rulesOf(r.content).first, 'PROCESS-NAME,com.a,GrpA');
  });

  test('conflict keeps the user target (prefer-user)', () {
    final previous = _doc(['PROCESS-NAME,com.a,GrpA', 'MATCH,Proxy']);
    final fresh = _doc(['PROCESS-NAME,com.a,GrpB', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: previous, fresh: fresh);
    expect(r.conflicts, 1);
    expect(r.overlaid, 0);
    final rules = _rulesOf(r.content);
    expect(rules.contains('PROCESS-NAME,com.a,GrpA'), true);
    expect(rules.contains('PROCESS-NAME,com.a,GrpB'), false);
  });

  test('identical app rule is a no-op', () {
    final same = _doc(['PROCESS-NAME,com.a,GrpA', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: same, fresh: same);
    expect(r.changed, false);
  });

  test('UID rule is treated as an app intent', () {
    final previous = _doc(['UID,10086,DIRECT', 'MATCH,Proxy']);
    final fresh = _doc(['MATCH,Proxy']);
    final r = reapplyAppRouting(previous: previous, fresh: fresh);
    expect(r.overlaid, 1);
    expect(_rulesOf(r.content).first, 'UID,10086,DIRECT');
  });

  test('non-app rule edits are not carried over', () {
    final previous = _doc(['DOMAIN-SUFFIX,a.com,GrpA', 'MATCH,Proxy']);
    final fresh = _doc(['DOMAIN-SUFFIX,a.com,GrpB', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: previous, fresh: fresh);
    expect(r.changed, false);
    expect(_rulesOf(r.content).contains('DOMAIN-SUFFIX,a.com,GrpB'), true);
  });

  test('mix of overlaid and conflict counts both, preserves other config', () {
    final previous = _doc([
      'PROCESS-NAME,com.a,GrpA',
      'PROCESS-NAME,com.b,GrpB',
      'MATCH,Proxy',
    ]);
    final fresh = _doc(['PROCESS-NAME,com.a,GrpX', 'MATCH,Proxy']);
    final r = reapplyAppRouting(previous: previous, fresh: fresh);
    expect(r.conflicts, 1); // com.a target differs -> user GrpA wins
    expect(r.overlaid, 1); // com.b dropped -> re-added
    expect(r.content, contains('mixed-port: 7890'));
    final rules = _rulesOf(r.content);
    expect(rules.contains('PROCESS-NAME,com.a,GrpA'), true);
    expect(rules.contains('PROCESS-NAME,com.b,GrpB'), true);
  });
}
