import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated_migrations/schema.dart';

Future<Map<int, int?>> _scriptIds(Database db) async {
  final rows = await db
      .customSelect('SELECT id, script_id FROM profiles')
      .get();
  return {
    for (final row in rows)
      row.read<int>('id'): row.readNullable<int>('script_id'),
  };
}

Future<Map<int, int?>> _actionProfileIds(Database db) async {
  final rows = await db
      .customSelect('SELECT id, action_profile_id FROM network_rules')
      .get();
  return {
    for (final row in rows)
      row.read<int>('id'): row.readNullable<int>('action_profile_id'),
  };
}

Profile _profile(int id, {int? scriptId}) => Profile(
  id: id,
  label: 'p$id',
  autoUpdateDuration: const Duration(hours: 1),
  scriptId: scriptId,
);

NetworkRule _rule(int id, int? profileId) => NetworkRule(
  id: id,
  action: NetworkAction(vpn: NetworkVpnMode.turnOn, profileId: profileId),
  priority: id,
);

Script _script(int id) =>
    Script(id: id, label: 's$id', lastUpdateTime: DateTime(2026));

void main() {
  test('v10 -> v11 clears dangling refs, then deleting a target '
      'clears the refs to it', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(10);
    schema.rawDatabase.execute('''
      INSERT INTO scripts (id, label, last_update_time) VALUES (5, 's5', 0);
      INSERT INTO profiles (id, label, url, overwrite_type,
        auto_update_duration_millis, auto_update, selected_map, unfold_set,
        script_id)
      VALUES (1, 'p1', '', 'standard', 0, 0, '{}', '[]', 5),
             (2, 'p2', '', 'standard', 0, 0, '{}', '[]', 99);
      INSERT INTO network_rules (id, conditions, action, priority,
        action_profile_id)
      VALUES (1, '[]', 0, 0, 1), (2, '[]', 0, 1, 42);
      INSERT INTO rules (id, value) VALUES (7, 'DOMAIN,a.example,DIRECT');
      INSERT INTO profile_rule_mapping (id, profile_id, rule_id, scene)
      VALUES ('link', 1, 7, 'added');
    ''');
    final db = Database(schema.newConnection());
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 11);

    expect(await _scriptIds(db), {1: 5, 2: null});
    expect(await _actionProfileIds(db), {1: 1, 2: null});
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    // Rebuilding profiles must not cascade into the links that point at it.
    final links = await db.select(db.profileRuleLinks).get();
    expect(links.map((row) => row.id), ['link']);

    await db.scripts.remove((t) => t.id.equals(5));
    await db.deleteProfile(1);

    expect(await _scriptIds(db), {2: null});
    expect(await _actionProfileIds(db), {1: null, 2: null});
  });

  group('with foreign keys enforced', () {
    late Database db;

    setUp(() => db = Database(NativeDatabase.memory()));

    tearDown(() => db.close());

    test('a profile pointing at a missing script is rejected', () async {
      await expectLater(
        db.profiles.put(_profile(1, scriptId: 99).toCompanion()),
        throwsA(isA<SqliteException>()),
      );
    });

    for (final isOverride in [true, false]) {
      test('restore (isOverride: $isOverride) clears dangling script and '
          'profile refs from a backup instead of failing', () async {
        await db.restore(
          [_profile(1, scriptId: 5), _profile(2, scriptId: 99)],
          [_script(5)],
          const [],
          const [],
          networkRules: [_rule(1, 1), _rule(2, 42)],
          isOverride: isOverride,
        );

        expect(await _scriptIds(db), {1: 5, 2: null});
        expect(await _actionProfileIds(db), {1: 1, 2: null});
      });
    }
  });
}
