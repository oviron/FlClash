import 'dart:async';
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
      expect(rule['actionVpn'], 'turnOff');
      expect(rule.containsKey('action'), isFalse);
      expect(rule['priority'], 0);
      expect(rule['enabled'], true);

      final conditions = rule['conditions'] as List;
      expect(conditions.first, {'kind': 'wifi_named', 'ssid': 'Home'});
    });

    test('serializes each default action to its exact wire string', () {
      // Literal wire contract shared with Kotlin NetworkRulesCodec; must not
      // drift from the enum's `.name` silently.
      const wire = {
        DefaultNetworkAction.turnOn: 'turnOn',
        DefaultNetworkAction.turnOff: 'turnOff',
        DefaultNetworkAction.leaveAsIs: 'leaveAsIs',
      };
      expect(wire.length, DefaultNetworkAction.values.length);
      for (final entry in wire.entries) {
        final json = encodeNetworkRulesMirror(
          enabled: false,
          defaultAction: entry.key,
          rules: const [],
        );
        expect((jsonDecode(json) as Map)['defaultAction'], entry.value);
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
      expect(rule.containsKey('action'), isFalse);
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

    test(
      'writes commit atomically (last wins) and leave no orphan temp',
      () async {
        // MirrorWriteQueue serializes writes, so the contract is: each write
        // rename-commits its content and cleans up its temp.
        await writeNetworkRulesMirror(dir.path, '{"n":1}');
        await writeNetworkRulesMirror(dir.path, '{"n":2}');
        final file = File(join(dir.path, networkRulesMirrorFileName));
        expect(jsonDecode(await file.readAsString()), {'n': 2});
        final leftovers = dir.listSync().where((e) => e.path.endsWith('.tmp'));
        expect(leftovers, isEmpty, reason: 'no orphan .tmp files left behind');
      },
    );

    test('creates the home dir when it does not exist yet', () async {
      final nested = join(dir.path, 'sub', 'home');
      await writeNetworkRulesMirror(nested, '{"ok":true}');
      expect(
        await File(join(nested, networkRulesMirrorFileName)).exists(),
        true,
      );
    });
  });

  group('MirrorWriteQueue', () {
    test('coalesces overlapping requests into one trailing run', () async {
      final queue = MirrorWriteQueue();
      final runs = <bool>[];
      final gate = Completer<void>();
      final firstStarted = Completer<void>();

      Future<void> run({required bool rebake}) async {
        final first = runs.isEmpty;
        runs.add(rebake);
        if (first) {
          firstStarted.complete();
          await gate.future;
        }
      }

      final f1 = queue.schedule(run, rebake: false);
      await firstStarted.future; // run #1 is in flight, blocked on the gate.
      final f2 = queue.schedule(run, rebake: false); // queued
      final f3 = queue.schedule(run, rebake: true); // coalesced; asks to rebake
      gate.complete();
      await Future.wait([f1, f2, f3]);

      // Three schedules collapse to two runs: the first, then one trailing run
      // that reads the freshest state, so nothing older can land after it.
      expect(runs, [false, true]); // trailing run inherits f3's rebake flag
    });

    test('runs each non-overlapping request', () async {
      final queue = MirrorWriteQueue();
      var count = 0;
      Future<void> run({required bool rebake}) async => count++;

      await queue.schedule(run, rebake: false);
      await queue.schedule(run, rebake: true);
      expect(count, 2);
    });
  });
}
