import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/network_rules.g.dart';

/// Live stream of all rules sorted by priority. UI / engine listen here.
@riverpod
Stream<List<NetworkRule>> networkRulesStream(Ref ref) {
  return database.networkRulesDao.watchAll();
}

/// Repository facade with CRUD + reorder. keepAlive because the engine
/// needs to keep watching even when no UI page is mounted.
@Riverpod(keepAlive: true)
class NetworkRulesRepo extends _$NetworkRulesRepo {
  @override
  List<NetworkRule> build() {
    return ref.watch(networkRulesStreamProvider).value ?? const [];
  }

  Future<int> add(NetworkRule rule) async {
    final maxPriority = await database.networkRulesDao.currentMaxPriority();
    return database.networkRulesDao.upsert(
      rule.copyWith(id: 0, priority: maxPriority + 1).toCompanion(),
    );
  }

  Future<int> update(NetworkRule rule) {
    return database.networkRulesDao.upsert(rule.toCompanion());
  }

  Future<int> delete(int id) {
    return database.networkRulesDao.deleteById(id);
  }

  Future<void> reorder(List<int> idsInNewOrder) {
    return database.networkRulesDao.reorder(idsInNewOrder);
  }
}
