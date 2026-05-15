part of 'database.dart';

@DataClassName('BypassProfileRow')
class BypassProfiles extends Table {
  @override
  String get tableName => 'bypass_profiles';

  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get domainsJson => text().withDefault(const Constant('[]'))();
  TextColumn get appsJson => text().withDefault(const Constant('[]'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [BypassProfiles])
class BypassProfilesDao extends DatabaseAccessor<Database>
    with _$BypassProfilesDaoMixin {
  BypassProfilesDao(super.attachedDatabase);

  Stream<List<BypassProfile>> watchAll() {
    return (select(bypassProfiles)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList(growable: false));
  }

  Future<int> upsert(BypassProfile profile) async =>
      bypassProfiles.insertOnConflictUpdate(_toCompanion(profile));

  Future<void> deleteById(int id) async {
    await (delete(bypassProfiles)..where((t) => t.id.equals(id))).go();
  }

  BypassProfile _fromRow(BypassProfileRow row) {
    return BypassProfile(
      id: row.id,
      name: row.name,
      enabled: row.enabled,
      domains: (jsonDecode(row.domainsJson) as List).cast<String>(),
      apps: (jsonDecode(row.appsJson) as List).cast<String>(),
    );
  }

  BypassProfilesCompanion _toCompanion(BypassProfile p) {
    return BypassProfilesCompanion.insert(
      id: Value(p.id),
      name: Value(p.name),
      enabled: Value(p.enabled),
      domainsJson: Value(jsonEncode(p.domains)),
      appsJson: Value(jsonEncode(p.apps)),
    );
  }
}
