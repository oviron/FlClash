import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';

part 'generated/database.g.dart';
part 'byedpi.dart';
part 'links.dart';
part 'network_rules.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';

@DriftDatabase(
  tables: [Profiles, Scripts, Rules, ProfileRuleLinks, NetworkRules, BypassProfiles],
  daos: [ProfilesDao, ScriptsDao, RulesDao, NetworkRulesDao, BypassProfilesDao],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(profiles, profiles.accessControlProps);
      }
      if (from < 3) {
        await m.createTable(networkRules);
      }
      if (from < 4) {
        await m.createTable(bypassProfiles);
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
  }) async {
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
