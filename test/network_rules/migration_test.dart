import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'v6 -> v9 upgrade backfills matchMode=all and actionProfileId=null',
    () async {
      final dir = await Directory.systemTemp.createTemp('flclash_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');

      // Build a v6-shaped database: network_rules without the v7 actionProfileId
      // or v8 matchMode columns, holding one legacy row. onCreate lays down the
      // current (v9) schema first, then we recreate the table at its v6 shape.
      final v6 = Database(NativeDatabase(file));
      await v6.customStatement('DROP TABLE network_rules');
      await v6.customStatement(
        'CREATE TABLE network_rules ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NULL, '
        'conditions TEXT NOT NULL, '
        'action INTEGER NOT NULL, '
        'priority INTEGER NOT NULL, '
        'enabled INTEGER NOT NULL DEFAULT 1)',
      );
      await v6.customStatement(
        "INSERT INTO network_rules (name, conditions, action, priority, enabled) VALUES ('legacy', '[]', 1, 0, 1)",
      );
      // Drop the v9 profiles column so the migration is the one that re-adds it
      // (onCreate laid down the current shape, but a real v6 db predates it).
      await v6.customStatement(
        'ALTER TABLE profiles DROP COLUMN app_filter_stash',
      );
      await v6.customStatement('PRAGMA user_version = 6');
      await v6.close();

      // Reopen: drift sees user_version 6 and runs onUpgrade(6, 9).
      final db = Database(NativeDatabase(file));
      addTearDown(db.close);

      // The highest onUpgrade branch must equal the declared schema version, or a
      // future migration silently never runs.
      expect(db.schemaVersion, 9);

      final rows = await db.networkRulesDao.watchAll().first;
      expect(rows, hasLength(1));
      expect(rows.single.name, 'legacy');
      expect(rows.single.action.vpn, NetworkVpnMode.turnOff);
      expect(rows.single.matchMode, NetworkMatchMode.all);
      expect(rows.single.action.profileId, isNull);

      // v9 re-added the per-profile app-filter stash column.
      final profileCols = await db
          .customSelect('PRAGMA table_info(profiles)')
          .get();
      expect(
        profileCols.any((r) => r.data['name'] == 'app_filter_stash'),
        isTrue,
      );
    },
  );
}
