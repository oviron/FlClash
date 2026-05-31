import 'package:fl_clash/byedpi/strategy_test_codec.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';

typedef StrategyTestResultsReader = Future<Map<String, dynamic>> Function();
typedef StrategyTestResultsWriter =
    Future<void> Function(Map<String, dynamic> results);

class StrategyTestCache {
  final StrategyTestResultsReader read;
  final StrategyTestResultsWriter write;

  const StrategyTestCache({required this.read, required this.write});

  Future<List<StrategyTestResult>> load() async {
    final rawCache = await read();
    final results = <StrategyTestResult>[];
    rawCache.forEach((id, raw) {
      if (raw is! Map) return;
      try {
        results.add(
          strategyTestResultFromCache(id, Map<String, dynamic>.from(raw)),
        );
      } catch (_) {
        return;
      }
    });
    return sortStrategyTestResults(results);
  }

  Future<void> merge(List<StrategyTestResult> results) async {
    final cache = await read();
    for (final result in results) {
      cache[result.id] = strategyTestResultToCache(result);
    }
    await write(cache);
  }

  Future<void> drop(Set<String> ids) async {
    final cache = await read();
    for (final id in ids) {
      cache.remove(id);
    }
    await write(cache);
  }

  Future<void> clear() {
    return write({});
  }
}

List<StrategyTestResult> sortStrategyTestResults(
  Iterable<StrategyTestResult> results,
) {
  return [...results]..sort((a, b) => b.percent.compareTo(a.percent));
}
