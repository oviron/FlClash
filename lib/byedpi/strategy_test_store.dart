import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';

typedef ByeDpiStrategiesLoader = Future<List<ByeDpiStrategy>> Function();
typedef ByeDpiStrategiesSaver =
    Future<void> Function(List<ByeDpiStrategy> strategies);
typedef ByeDpiStrategiesResetter = Future<void> Function();

class StrategyTestStore {
  final ByeDpiStrategiesLoader load;
  final ByeDpiStrategiesSaver save;
  final ByeDpiStrategiesResetter reset;

  const StrategyTestStore({
    this.load = loadByeDpiStrategies,
    this.save = saveStrategyList,
    this.reset = resetStrategyList,
  });

  Future<List<ByeDpiStrategy>> remove(String id) async {
    final current = await load();
    final kept = current.where((strategy) => strategy.id != id).toList();
    await save(kept);
    return kept;
  }

  Future<PruneStrategyResult> pruneBelow({
    required Map<String, int> testedPercentById,
    required int percent,
  }) async {
    final current = await load();
    final kept = current
        .where(
          (strategy) => (testedPercentById[strategy.id] ?? percent) >= percent,
        )
        .toList();
    if (kept.length == current.length) {
      return PruneStrategyResult(kept: current, removedIds: const {});
    }
    await save(kept);
    final keptIds = {for (final strategy in kept) strategy.id};
    return PruneStrategyResult(
      kept: kept,
      removedIds: {
        for (final strategy in current)
          if (!keptIds.contains(strategy.id)) strategy.id,
      },
    );
  }
}

class PruneStrategyResult {
  final List<ByeDpiStrategy> kept;
  final Set<String> removedIds;

  const PruneStrategyResult({required this.kept, required this.removedIds});

  int get removed => removedIds.length;
}
