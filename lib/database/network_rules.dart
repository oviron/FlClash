part of 'database.dart';

@DataClassName('RawNetworkRule')
class NetworkRules extends Table {
  @override
  String get tableName => 'network_rules';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().nullable()();

  // JSON-encoded `List<NetworkCondition>`.
  TextColumn get conditions => text()();

  // How conditions combine as `NetworkMatchMode.index` (0=all/AND, 1=any/OR).
  IntColumn get matchMode => integer().withDefault(const Constant(0))();

  // VPN mode as `NetworkVpnMode.index` (0=turnOn, 1=turnOff, 2=leave).
  IntColumn get action => integer()();

  // Profile-switch target; null = leave profile as-is.
  IntColumn get actionProfileId => integer().nullable()();

  IntColumn get priority => integer()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DriftAccessor(tables: [NetworkRules])
class NetworkRulesDao extends DatabaseAccessor<Database>
    with _$NetworkRulesDaoMixin {
  NetworkRulesDao(super.attachedDatabase);

  Stream<List<NetworkRule>> watchAll() {
    final stmt = select(networkRules);
    stmt.orderBy([
      (t) => OrderingTerm.asc(t.priority),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return stmt.watch().map(
      (rows) => rows.map((r) => r.toNetworkRule()).toList(growable: false),
    );
  }

  Future<int> upsert(NetworkRulesCompanion companion) async {
    return into(networkRules).insertOnConflictUpdate(companion);
  }

  // max-priority read + insert share one transaction so two concurrent adds
  // can't land on the same priority.
  Future<int> insertAtEnd(NetworkRule rule) {
    return transaction(() async {
      final maxPriority = await currentMaxPriority();
      return upsert(
        rule.copyWith(id: 0, priority: maxPriority + 1).toCompanion(),
      );
    });
  }

  Future<int> deleteById(int id) {
    return (delete(networkRules)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorder(List<int> idsInNewOrder) async {
    if (idsInNewOrder.isEmpty) return;
    await batch((b) {
      for (var i = 0; i < idsInNewOrder.length; i++) {
        b.update<NetworkRules, RawNetworkRule>(
          networkRules,
          NetworkRulesCompanion(priority: Value(i)),
          where: (t) => t.id.equals(idsInNewOrder[i]),
        );
      }
    });
  }

  // Highest stored priority, or -1 when empty, so max + 1 = 0 for the first
  // rule.
  Future<int> currentMaxPriority() async {
    final priority = networkRules.priority;
    final query = selectOnly(networkRules)..addColumns([priority.max()]);
    final row = await query.getSingleOrNull();
    return row?.read(priority.max()) ?? -1;
  }

  // Merge restore: upsert without deleting rows absent from the backup, so an
  // old backup predating network rules can't wipe the user's current rules.
  void putAllWithBatch(Batch batch, Iterable<NetworkRule> items) {
    batch.insertAllOnConflictUpdate(
      networkRules,
      items.map((r) => r.toCompanion()),
    );
  }

  // Override restore: rows absent from `items` are deleted. Symmetric with
  // ProfilesDao.setAllWithBatch.
  void setAllWithBatch(Batch batch, Iterable<NetworkRule> items) {
    final companions = items.map((r) => r.toCompanion()).toList();
    final ids = items.map((r) => r.id).toList();
    networkRules.setAll(
      batch,
      companions,
      deleteFilter: (t) => t.id.isNotIn(ids),
    );
  }
}

extension RawNetworkRuleExt on RawNetworkRule {
  NetworkRule toNetworkRule() {
    return NetworkRule(
      id: id,
      name: name,
      conditions: NetworkConditionListCodec.decode(conditions),
      matchMode: matchMode >= 0 && matchMode < NetworkMatchMode.values.length
          ? NetworkMatchMode.values[matchMode]
          : NetworkMatchMode.all,
      action: NetworkAction(
        vpn: action >= 0 && action < NetworkVpnMode.values.length
            ? NetworkVpnMode.values[action]
            : NetworkVpnMode.turnOn,
        profileId: actionProfileId,
      ),
      priority: priority,
      enabled: enabled,
    );
  }
}

extension NetworkRulesCompanionExt on NetworkRule {
  NetworkRulesCompanion toCompanion() {
    return NetworkRulesCompanion(
      id: id == 0 ? const Value.absent() : Value(id),
      name: Value(name),
      conditions: Value(NetworkConditionListCodec.encode(conditions)),
      matchMode: Value(matchMode.index),
      action: Value(action.vpn.index),
      actionProfileId: Value(action.profileId),
      priority: Value(priority),
      enabled: Value(enabled),
    );
  }
}
