import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkRulesDao roundtrip', () {
    late Database db;

    setUp(() {
      db = Database(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('insert -> read -> update -> reorder -> delete', () async {
      final dao = db.networkRulesDao;

      // Initially empty.
      final empty = await dao.watchAll().first;
      expect(empty, isEmpty);

      // Insert two rules.
      final aId = await dao.upsert(
        const NetworkRule(
          name: 'home',
          conditions: [WifiNamed('HomeWifi')],
          action: NetworkAction.turnOff,
          priority: 1,
        ).toCompanion(),
      );
      final bId = await dao.upsert(
        const NetworkRule(
          name: 'cellular',
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ).toCompanion(),
      );

      expect(aId, isPositive);
      expect(bId, isPositive);
      expect(aId, isNot(bId));

      // Read sorted by priority asc.
      final initial = await dao.watchAll().first;
      expect(initial, hasLength(2));
      expect(initial[0].name, 'cellular');
      expect(initial[0].priority, 0);
      expect(initial[1].name, 'home');
      expect(initial[1].priority, 1);

      // Conditions decoded back into the right concrete types.
      expect(initial[0].conditions, [const AnyCellular()]);
      expect(initial[1].conditions, [const WifiNamed('HomeWifi')]);
      expect(initial[1].action, NetworkAction.turnOff);
      expect(initial[1].enabled, isTrue);

      // Update: rename and toggle disabled on the home rule.
      final homeRow = initial[1];
      await dao.upsert(
        homeRow.copyWith(name: 'home wifi', enabled: false).toCompanion(),
      );

      final afterUpdate = await dao.watchAll().first;
      final updatedHome = afterUpdate.firstWhere((r) => r.id == homeRow.id);
      expect(updatedHome.name, 'home wifi');
      expect(updatedHome.enabled, isFalse);

      // Reorder: put home (id=aId) first, cellular (id=bId) second.
      await dao.reorder([aId, bId]);
      final reordered = await dao.watchAll().first;
      expect(reordered.map((r) => r.id).toList(), [aId, bId]);
      expect(reordered[0].priority, 0);
      expect(reordered[1].priority, 1);

      // Delete one.
      final removed = await dao.deleteById(aId);
      expect(removed, 1);
      final afterDelete = await dao.watchAll().first;
      expect(afterDelete, hasLength(1));
      expect(afterDelete.single.id, bId);
    });
  });

  group('database.restore respects the strategy for network rules', () {
    late Database db;

    setUp(() {
      db = Database(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> seedHome(NetworkRulesDao dao) => dao.upsert(
      const NetworkRule(
        name: 'home',
        conditions: [WifiNamed('HomeWifi')],
        action: NetworkAction.turnOff,
        priority: 0,
      ).toCompanion(),
    );

    const work = NetworkRule(
      id: 42,
      name: 'work',
      conditions: [WifiNamed('WorkWifi')],
      action: NetworkAction.turnOn,
      priority: 1,
    );

    test(
      'compatible restore of a backup without network rules keeps them',
      () async {
        final dao = db.networkRulesDao;
        await seedHome(dao);
        expect(await dao.watchAll().first, hasLength(1));

        // Old backup: a profile, no network rules. Merge (compatible) mode must
        // not wipe the user's current rules.
        await db.restore(
          [Profile.normal(label: 'imported')],
          const [],
          const [],
          const [],
          isOverride: false,
          networkRules: const [],
        );

        expect(await dao.watchAll().first, hasLength(1));
      },
    );

    test('compatible restore merges rules absent from the backup', () async {
      final dao = db.networkRulesDao;
      await seedHome(dao);

      await db.restore(
        const [],
        const [],
        const [],
        const [],
        isOverride: false,
        networkRules: const [work],
      );

      final rules = await dao.watchAll().first;
      expect(rules.map((r) => r.name), containsAll(['home', 'work']));
    });

    test('override restore replaces network rules wholesale', () async {
      final dao = db.networkRulesDao;
      await seedHome(dao);

      await db.restore(
        const [],
        const [],
        const [],
        const [],
        isOverride: true,
        networkRules: const [work],
      );

      final rules = await dao.watchAll().first;
      expect(rules.map((r) => r.name), ['work']);
    });
  });
}
