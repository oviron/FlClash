import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';

part 'generated/database.g.dart';
part 'links.dart';
part 'network_rules.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';

@DriftDatabase(
  tables: [Profiles, Scripts, Rules, ProfileRuleLinks, NetworkRules],
  daos: [ProfilesDao, ScriptsDao, RulesDao, NetworkRulesDao],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(profiles, profiles.accessControlProps);
      }
      if (from < 3) {
        await m.createTable(networkRules);
      }
      // v3→v4 created bypass_profiles; v4→v5 immediately dropped it (Bypass
      // Profiles feature abandoned before any user code referenced it). The
      // create+drop pair stays in history for devices that ran v4 briefly.
      if (from < 4) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS bypass_profiles ('
          'id INTEGER NOT NULL PRIMARY KEY, '
          'name TEXT NOT NULL DEFAULT \'\', '
          'enabled INTEGER NOT NULL DEFAULT 1, '
          'domains_json TEXT NOT NULL DEFAULT \'[]\', '
          'apps_json TEXT NOT NULL DEFAULT \'[]\', '
          'sort_order INTEGER NOT NULL DEFAULT 0'
          ')',
        );
      }
      if (from < 5) {
        await customStatement('DROP TABLE IF EXISTS bypass_profiles');
      }
      // v6: collapse legacy NetworkAction.keep (index 2) into turnOn (index 0).
      if (from < 6) {
        await customStatement(
          'UPDATE network_rules SET action = 0 WHERE action = 2',
        );
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  Future<void> restore(
    List<Profile> profiles,
    List<Script> scripts,
    List<Rule> rules,
    List<ProfileRuleLink> links, {
    bool isOverride = false,
    List<NetworkRule> networkRules = const [],
  }) async {
    if (profiles.isNotEmpty ||
        scripts.isNotEmpty ||
        rules.isNotEmpty ||
        links.isNotEmpty ||
        networkRules.isNotEmpty) {
      await batch((b) {
        isOverride
            ? profilesDao.setAllWithBatch(b, profiles)
            : profilesDao.putAllWithBatch(
                b,
                profiles.map((item) => item.toCompanion()),
              );
        scriptsDao.setAllWithBatch(b, scripts);
        rulesDao.restoreWithBatch(b, rules, links);
        networkRulesDao.setAllWithBatch(b, networkRules);
      });
    }
  }
}

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
  }) {
    batch.insertAllOnConflictUpdate(this, items);
    batch.deleteWhere(this, deleteFilter);
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return await (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return await insertOnConflictUpdate(item);
  }
}

final database = Database();
