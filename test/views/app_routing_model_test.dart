import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/profiles/app_routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

Package _pkg(String name, String label, {bool system = false}) => Package(
  packageName: name,
  label: label,
  system: system,
  internet: true,
  lastUpdateTime: 0,
);

void main() {
  group('targetChipKind', () {
    test('null and empty value read as profile rules', () {
      expect(targetChipKind(null), TargetChipKind.profileRules);
      expect(
        targetChipKind((value: kRoutingDefault, isSubRule: false)),
        TargetChipKind.profileRules,
      );
    });

    test('builtins map to their kinds', () {
      expect(
        targetChipKind((value: kRoutingDirect, isSubRule: false)),
        TargetChipKind.direct,
      );
      expect(
        targetChipKind((value: kRoutingReject, isSubRule: false)),
        TargetChipKind.reject,
      );
      expect(
        targetChipKind((value: kRoutingGlobal, isSubRule: false)),
        TargetChipKind.global,
      );
    });

    test('a plain proxy/group name is a group', () {
      expect(
        targetChipKind((value: 'VPN', isSubRule: false)),
        TargetChipKind.group,
      );
    });

    test('a sub-rule target is a sub-rule regardless of name', () {
      expect(
        targetChipKind((value: 'browser-route', isSubRule: true)),
        TargetChipKind.subRule,
      );
      // isSubRule wins even when the name collides with a builtin.
      expect(
        targetChipKind((value: kRoutingDirect, isSubRule: true)),
        TargetChipKind.subRule,
      );
    });
  });

  group('inTunnel', () {
    test('whitelist counts the include-list', () {
      expect(
        inTunnel('a', AccessControlMode.acceptSelected, {'a'}, const {}),
        isTrue,
      );
      expect(
        inTunnel('b', AccessControlMode.acceptSelected, {'a'}, const {}),
        isFalse,
      );
    });

    test('blacklist counts everything not excluded', () {
      expect(
        inTunnel('a', AccessControlMode.rejectSelected, const {}, {'a'}),
        isFalse,
      );
      expect(
        inTunnel('b', AccessControlMode.rejectSelected, const {}, {'a'}),
        isTrue,
      );
    });
  });

  group('partitionApps', () {
    final apps = [_pkg('a', 'A'), _pkg('b', 'B'), _pkg('c', 'C')];

    test('whitelist: only included apps are in-tunnel', () {
      final r = partitionApps(apps, AccessControlMode.acceptSelected, {
        'a',
        'c',
      }, const {});
      expect(r.inTunnel.map((p) => p.packageName), ['a', 'c']);
      expect(r.bypass.map((p) => p.packageName), ['b']);
    });

    test('blacklist: excluded apps bypass, the rest are in-tunnel', () {
      final r = partitionApps(
        apps,
        AccessControlMode.rejectSelected,
        const {},
        {'b'},
      );
      expect(r.inTunnel.map((p) => p.packageName), ['a', 'c']);
      expect(r.bypass.map((p) => p.packageName), ['b']);
    });
  });

  group('filterRoutingApps', () {
    final apps = [
      _pkg('com.chrome', 'Chrome'),
      _pkg('com.bank', 'Bank App'),
      _pkg('com.android.sys', 'System Thing', system: true),
    ];

    test('configuredFirst leads configured apps, each block name-sorted', () {
      final r = filterRoutingApps(
        apps,
        query: '',
        showSystem: false,
        configuredFirst: true,
        configured: {'com.chrome'},
      );
      expect(r.map((p) => p.packageName), ['com.chrome', 'com.bank']);
    });

    test('without configuredFirst stays purely name-sorted', () {
      final r = filterRoutingApps(
        apps,
        query: '',
        showSystem: false,
        configured: {'com.chrome'},
      );
      expect(r.map((p) => p.packageName), ['com.bank', 'com.chrome']);
    });
  });
}
