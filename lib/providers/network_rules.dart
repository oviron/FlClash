import 'package:collection/collection.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/network_rules.g.dart';

/// Live stream of all rules sorted by priority. UI / engine listen here.
@riverpod
Stream<List<NetworkRule>> networkRulesStream(Ref ref) {
  return database.networkRulesDao.watchAll();
}

// Changes whenever a baked <id>.yaml or the mirror's per-profile entry would.
@riverpod
Future<int> networkRulesBakeInputs(Ref ref) async {
  final rules = ref.watch(networkRulesStreamProvider).value ?? const [];
  final parts = <Object?>[
    ref.watch(patchClashConfigProvider),
    ref.watch(vpnSettingProvider.select((state) => state.systemProxy)),
  ];
  final setupStates = <Future<SetupState>>[];
  for (final id in networkRuleProfileIds(rules)) {
    final profile = ref.watch(profileProvider(id));
    parts.addAll([
      id,
      profile?.label,
      const DeepCollectionEquality().hash(profile?.selectedMap),
    ]);
    setupStates.add(ref.watch(setupStateProvider(id).future));
  }
  parts.addAll(await Future.wait(setupStates));
  return Object.hashAll(parts);
}

Set<int> networkRuleProfileIds(List<NetworkRule> rules) => {
  for (final r in rules)
    if (r.enabled && r.action.profileId != null) r.action.profileId!,
};

/// Repository facade with CRUD + reorder. keepAlive because the engine
/// needs to keep watching even when no UI page is mounted.
@Riverpod(keepAlive: true)
class NetworkRulesRepo extends _$NetworkRulesRepo {
  @override
  List<NetworkRule> build() {
    return ref.watch(networkRulesStreamProvider).value ?? const [];
  }

  Future<int> add(NetworkRule rule) {
    return database.networkRulesDao.insertAtEnd(rule);
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
