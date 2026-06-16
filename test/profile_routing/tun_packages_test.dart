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
    expect(const ProfileRulesDocument(doc).excludedPackages, [
      'com.a',
      'com.b',
    ]);
  });

  test('absent tun yields empty exclude list', () {
    expect(
      const ProfileRulesDocument('mode: rule\n').excludedPackages,
      isEmpty,
    );
  });

  test('writes exclude-package creating tun, round-trips, preserves rest', () {
    const doc = '# top\nmixed-port: 7890\nmode: rule\n';
    final out = const ProfileRulesDocument(doc).withExcludedPackages(['com.x']);
    expect(ProfileRulesDocument(out).excludedPackages, ['com.x']);
    expect(out, contains('# top'));
    expect(out, contains('mixed-port: 7890'));
  });

  test('written exclude is read by aclFromTunYaml as a reject-list', () {
    const doc = 'tun:\n  enable: true\nmode: rule\n';
    final out = const ProfileRulesDocument(doc).withExcludedPackages(['com.y']);
    final acl = aclFromTunYaml(_asMap(out));
    expect(acl, isNotNull);
    expect(acl!.mode, AccessControlMode.rejectSelected);
    expect(acl.rejectList, contains('com.y'));
  });

  test('empty list removes the exclude-package key', () {
    const doc = 'tun:\n  enable: true\n  exclude-package:\n    - com.a\n';
    final out = const ProfileRulesDocument(doc).withExcludedPackages([]);
    expect(ProfileRulesDocument(out).excludedPackages, isEmpty);
    expect(out, contains('enable: true'));
  });

  test('updating exclude preserves a sibling tun field', () {
    const doc = 'tun:\n  enable: true\n  stack: system\n';
    final out = const ProfileRulesDocument(doc).withExcludedPackages(['com.z']);
    expect(out, contains('stack: system'));
    expect(ProfileRulesDocument(out).excludedPackages, ['com.z']);
  });
}
