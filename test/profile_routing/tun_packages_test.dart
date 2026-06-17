import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

Map<String, dynamic> _asMap(String yaml) =>
    Map<String, dynamic>.from(loadYaml(yaml) as YamlMap);

void main() {
  test('reads tun.exclude-package', () {
    const doc =
        'tun:\n  enable: true\n  exclude-package:\n    - com.a\n    - com.b\n';
    expect(ProfileRulesDocument(doc).excludedPackages, ['com.a', 'com.b']);
  });

  test('absent tun yields empty exclude list', () {
    expect(ProfileRulesDocument('mode: rule\n').excludedPackages, isEmpty);
  });

  test('writes exclude-package creating tun, round-trips, preserves rest', () {
    const doc = '# top\nmixed-port: 7890\nmode: rule\n';
    final out = ProfileRulesDocument(doc).withExcludedPackages(['com.x']);
    expect(ProfileRulesDocument(out).excludedPackages, ['com.x']);
    expect(out, contains('# top'));
    expect(out, contains('mixed-port: 7890'));
  });

  test('written exclude is read by aclFromTunYaml as a reject-list', () {
    const doc = 'tun:\n  enable: true\nmode: rule\n';
    final out = ProfileRulesDocument(doc).withExcludedPackages(['com.y']);
    final acl = aclFromTunYaml(_asMap(out));
    expect(acl, isNotNull);
    expect(acl!.mode, AccessControlMode.rejectSelected);
    expect(acl.rejectList, contains('com.y'));
  });

  test('empty list removes the exclude-package key', () {
    const doc = 'tun:\n  enable: true\n  exclude-package:\n    - com.a\n';
    final out = ProfileRulesDocument(doc).withExcludedPackages([]);
    expect(ProfileRulesDocument(out).excludedPackages, isEmpty);
    expect(out, contains('enable: true'));
  });

  test('updating exclude preserves a sibling tun field', () {
    const doc = 'tun:\n  enable: true\n  stack: system\n';
    final out = ProfileRulesDocument(doc).withExcludedPackages(['com.z']);
    expect(out, contains('stack: system'));
    expect(ProfileRulesDocument(out).excludedPackages, ['com.z']);
  });

  test('reads tun.include-package', () {
    const doc =
        'tun:\n  enable: true\n  include-package:\n    - com.a\n    - com.b\n';
    expect(ProfileRulesDocument(doc).includedPackages, ['com.a', 'com.b']);
  });

  test('absent include-package yields empty list', () {
    expect(
      ProfileRulesDocument('tun:\n  enable: true\n').includedPackages,
      isEmpty,
    );
  });

  test('writes include-package, round-trips, preserves rest', () {
    const doc = '# top\nmode: rule\n';
    final out = ProfileRulesDocument(doc).withIncludedPackages(['com.x']);
    expect(ProfileRulesDocument(out).includedPackages, ['com.x']);
    expect(out, contains('# top'));
    expect(out, contains('mode: rule'));
  });

  test('written include is read by aclFromTunYaml as an accept-list', () {
    const doc = 'tun:\n  enable: true\n';
    final out = ProfileRulesDocument(doc).withIncludedPackages(['com.y']);
    final acl = aclFromTunYaml(_asMap(out));
    expect(acl, isNotNull);
    expect(acl!.mode, AccessControlMode.acceptSelected);
    expect(acl.acceptList, contains('com.y'));
  });

  test('empty list removes the include-package key', () {
    const doc = 'tun:\n  include-package:\n    - com.a\n';
    final out = ProfileRulesDocument(doc).withIncludedPackages([]);
    expect(ProfileRulesDocument(out).includedPackages, isEmpty);
  });

  test('writing include leaves a sibling exclude untouched', () {
    const doc = 'tun:\n  enable: true\n  exclude-package:\n    - com.keep\n';
    final out = ProfileRulesDocument(doc).withIncludedPackages(['com.in']);
    final back = ProfileRulesDocument(out);
    expect(back.includedPackages, ['com.in']);
    expect(back.excludedPackages, ['com.keep']);
  });
}
