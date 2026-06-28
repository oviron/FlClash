import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/network_rules/engine.dart';
import 'package:fl_clash/network_rules/mirror.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  group('encodeNetworkRulesMirror', () {
    test('emits the schema the Kotlin codec expects', () {
      final json = encodeNetworkRulesMirror(
        enabled: true,
        defaultAction: DefaultNetworkAction.turnOff,
        rules: const [
          NetworkRule(
            id: 1,
            name: 'Home',
            conditions: [WifiNamed('Home')],
            action: NetworkAction.turnOff,
            priority: 0,
          ),
        ],
      );
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['version'], networkRulesMirrorVersion);
      expect(decoded['enabled'], true);
      expect(decoded['defaultAction'], 'turnOff');

      final rules = decoded['rules'] as List;
      expect(rules, hasLength(1));
      final rule = rules.first as Map<String, dynamic>;
      expect(rule['id'], 1);
      expect(rule['name'], 'Home');
      expect(rule['match'], 'all');
      expect(rule['action'], 'turnOff');
      expect(rule['priority'], 0);
      expect(rule['enabled'], true);

      final conditions = rule['conditions'] as List;
      expect(conditions.first, {'kind': 'wifi_named', 'ssid': 'Home'});
    });

    test('serializes every default action by name', () {
      for (final action in DefaultNetworkAction.values) {
        final json = encodeNetworkRulesMirror(
          enabled: false,
          defaultAction: action,
          rules: const [],
        );
        expect((jsonDecode(json) as Map)['defaultAction'], action.name);
      }
    });

    test('inlines profile-switch action with selectedMap and name', () {
      final json = encodeNetworkRulesMirror(
        enabled: true,
        defaultAction: DefaultNetworkAction.leaveAsIs,
        rules: const [
          NetworkRule(
            id: 3,
            conditions: [AnyCellular()],
            action: NetworkAction(vpn: NetworkVpnMode.turnOn, profileId: 7),
            priority: 0,
          ),
        ],
        selectedMaps: const {
          7: {'GLOBAL': 'us'},
        },
        profileNames: const {7: 'Work'},
        activeProfileId: 2,
      );
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['activeProfileId'], 2);
      final rule = (decoded['rules'] as List).first as Map<String, dynamic>;
      expect(rule['actionVpn'], 'turnOn');
      expect(rule['action'], 'turnOn'); // legacy on/off mirror
      expect(rule['actionProfileId'], 7);
      expect(rule['actionSelectedMap'], {'GLOBAL': 'us'});
      expect(rule['actionProfileName'], 'Work');
    });

    test('omits profile fields for a plain on/off action', () {
      final json = encodeNetworkRulesMirror(
        enabled: true,
        defaultAction: DefaultNetworkAction.leaveAsIs,
        rules: const [
          NetworkRule(
            conditions: [AnyCellular()],
            action: NetworkAction.turnOff,
            priority: 0,
          ),
        ],
      );
      final rule = ((jsonDecode(json) as Map)['rules'] as List).first as Map;
      expect(rule['actionVpn'], 'turnOff');
      expect(rule.containsKey('actionProfileId'), false);
      expect(rule.containsKey('actionSelectedMap'), false);
      expect((jsonDecode(json) as Map).containsKey('activeProfileId'), false);
    });

    test('serializes ethernet and cellular conditions', () {
      final json = encodeNetworkRulesMirror(
        enabled: true,
        defaultAction: DefaultNetworkAction.leaveAsIs,
        rules: const [
          NetworkRule(
            conditions: [AnyEthernet()],
            action: NetworkAction.turnOn,
            priority: 0,
          ),
          NetworkRule(
            conditions: [AnyCellular()],
            action: NetworkAction.turnOff,
            priority: 1,
          ),
        ],
      );
      final rules = (jsonDecode(json) as Map)['rules'] as List;
      expect((rules[0] as Map)['conditions'], [
        {'kind': 'any_ethernet'},
      ]);
      expect((rules[1] as Map)['conditions'], [
        {'kind': 'any_cellular'},
      ]);
    });
  });

  group('writeNetworkRulesMirror', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('nr_mirror');
    });
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('concurrent writes do not race on a shared temp file', () async {
      await Future.wait([
        for (var i = 0; i < 8; i++)
          writeNetworkRulesMirror(dir.path, '{"n":$i}'),
      ]);
      final file = File(join(dir.path, networkRulesMirrorFileName));
      expect(await file.exists(), true);
      expect(
        jsonDecode(await file.readAsString()),
        isA<Map<String, dynamic>>(),
      );
      final leftovers = dir.listSync().where((e) => e.path.endsWith('.tmp'));
      expect(leftovers, isEmpty, reason: 'no orphan .tmp files left behind');
    });

    test('creates the home dir when it does not exist yet', () async {
      final nested = join(dir.path, 'sub', 'home');
      await writeNetworkRulesMirror(nested, '{"ok":true}');
      expect(
        await File(join(nested, networkRulesMirrorFileName)).exists(),
        true,
      );
    });
  });
}
