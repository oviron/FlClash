part of 'database.dart';

/// Persisted form of a [NetworkRule]. Conditions are stored as a JSON
/// array in a single TEXT column, action is stored as the underlying
/// enum index (0 turnOn, 1 turnOff, 2 keep) so it stays compact and
/// migrations stay trivial.
@DataClassName('RawNetworkRule')
class NetworkRules extends Table {
  @override
  String get tableName => 'network_rules';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().nullable()();

  /// JSON-encoded `List<NetworkCondition>`.
  TextColumn get conditions => text()();

  /// Stored as `NetworkAction.index` (0=turnOn, 1=turnOff, 2=keep).
  IntColumn get action => integer()();

  IntColumn get priority => integer()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DriftAccessor(tables: [NetworkRules])
class NetworkRulesDao extends DatabaseAccessor<Database>
    with _$NetworkRulesDaoMixin {
  NetworkRulesDao(super.attachedDatabase);

  /// Watch all rules ordered by priority (lower = higher precedence).
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

  /// Insert (companion id absent) or update (id present). Returns the row id.
  Future<int> upsert(NetworkRulesCompanion companion) async {
    return into(networkRules).insertOnConflictUpdate(companion);
  }

  Future<int> deleteById(int id) {
    return (delete(networkRules)..where((t) => t.id.equals(id))).go();
  }

  /// Rewrite priority for the given ids in the supplied order
  /// (idsInNewOrder.first becomes priority 0, next 1, etc.).
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
}

extension RawNetworkRuleExt on RawNetworkRule {
  NetworkRule toNetworkRule() {
    return NetworkRule(
      id: id,
      name: name,
      conditions: NetworkConditionListCodec.decode(conditions),
      action: NetworkAction.values[action],
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
      action: Value(action.index),
      priority: Value(priority),
      enabled: Value(enabled),
    );
  }
}
