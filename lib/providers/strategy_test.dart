import 'dart:async';

import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/strategy_test_cache.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';
import 'package:fl_clash/byedpi/strategy_test_runner.dart';
import 'package:fl_clash/byedpi/strategy_test_store.dart';
import 'package:fl_clash/byedpi/test_store.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/providers/byedpi_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/strategy_test.g.dart';

// In-app strategy auto-test: pauses the VPN, runs byedpi standalone per strategy
// via native, caches results. Apply selects the id + writes the exclude list
// (its failed hosts → routed via VPN).
@riverpod
class StrategyTestController extends _$StrategyTestController {
  Service get _svc => Service();
  late final StrategyTestCache _cache = const StrategyTestCache(
    read: readTestResults,
    write: writeTestResults,
  );
  late final StrategyTestStore _store = const StrategyTestStore();
  late final StrategyTestNativeRunner _runner = StrategyTestNativeRunner(
    bindProgress: (cb) => _svc.onStrategyTestProgress = cb,
    startNative: _svc.startStrategyTest,
    stopNative: _svc.stopStrategyTest,
  );
  bool _wasVpnOn = false;

  @override
  StrategyTestState build() => const StrategyTestState();

  // Render last results from the on-disk cache (no re-test).
  Future<void> loadCached() async {
    if (state.phase == TestPhase.running || state.results.isNotEmpty) return;
    final results = await _cache.load();
    if (results.isEmpty) return;
    state = StrategyTestState(phase: TestPhase.done, results: results);
  }

  // [onlyIds] limits the run to those strategies (re-test one/few); null tests
  // the whole set. Existing results stay visible and update in place.
  Future<void> run({
    Set<String>? onlyIds,
    int requests = 1,
    int timeout = 5,
    int concurrency = 20,
  }) async {
    if (state.phase == TestPhase.running) return;

    final all = await ref.read(byeDpiStrategiesProvider.future);
    final strategies = onlyIds == null
        ? all
        : all.where((s) => onlyIds.contains(s.id)).toList();
    final request = StrategyTestRunRequest(
      strategies: strategies,
      sites: parseStrategyTestSites(await readHostList()),
      requests: requests,
      timeout: timeout,
      concurrency: concurrency,
    );
    if (request.isEmpty) {
      state = const StrategyTestState(
        phase: TestPhase.done,
        error: 'no strategies or sites',
      );
      return;
    }

    _wasVpnOn = appController.isStart;
    if (_wasVpnOn) await appController.updateStatus(false);

    state = StrategyTestState(
      phase: TestPhase.running,
      total: strategies.length,
      results: state.results,
    );
    final ok = await _runner.start(request: request, onProgress: _onProgress);
    if (!ok) await _finish(error: 'failed to start test');
  }

  Future<void> testOne(String id) => run(onlyIds: {id});

  void _onProgress(StrategyTestProgress progress) {
    if (progress.error != null) {
      unawaited(_finish(error: progress.error));
      return;
    }
    final res = progress.result;
    if (res == null) return;
    final results = [...state.results];
    final idx = results.indexWhere((r) => r.id == res.id);
    if (idx >= 0) {
      results[idx] = res;
    } else {
      results.add(res);
    }
    state = state.copyWith(
      results: results,
      completed: progress.completed,
      currentLabel: res.label,
    );
    if (progress.done) unawaited(_finish());
  }

  Future<void> stop() async {
    if (state.phase != TestPhase.running) return;
    await _runner.stop();
    await _finish();
  }

  Future<void> _finish({String? error}) async {
    _runner.detach();
    if (_wasVpnOn) {
      await appController.updateStatus(true);
      _wasVpnOn = false;
    }
    final sorted = sortStrategyTestResults(state.results);
    await _cache.merge(sorted);
    state = StrategyTestState(
      phase: TestPhase.done,
      completed: state.completed,
      total: state.total,
      results: sorted,
      error: error,
    );
  }

  // Apply a strategy: make it active AND route its failed hosts via VPN by
  // writing them to the exclude list, then re-apply the profile so the byedpi
  // routing rules rebuild. Returns the byedpi/VPN split for the UI.
  Future<ApplySplit> apply(String id) async {
    final result = state.results.where((r) => r.id == id).firstOrNull;
    final failed = result?.failedHosts ?? const <String>[];
    await writeExclude(failed);
    // setPreset → engine reload (args, if the preset changed); the core bump
    // makes the reconciler rebuild routing for the new exclude. Both apply live.
    await ref.read(byeDpiSettingsProvider.notifier).setPreset(id);
    ref.invalidate(byeDpiRoutingHostListProvider);
    ref.read(byeDpiCoreRevisionProvider.notifier).bump();
    final total = result?.sites.length ?? 0;
    return (byedpi: total - failed.length, vpn: failed.length);
  }

  // Curation — writes the on-disk strategy override (persists; reset reverts to
  // the bundled default). The picker/test/routing all read the same set.
  Future<void> removeStrategy(String id) async {
    await _store.remove(id);
    await _cache.drop({id});
    ref.invalidate(byeDpiStrategiesProvider);
    state = state.copyWith(
      results: state.results.where((r) => r.id != id).toList(),
    );
    await _syncRuntimeIfActive({id});
  }

  // Drop strategies whose last test is below [pct]. Untested ones are kept
  // (not measured). Returns how many were removed.
  Future<int> pruneBelow(int pct) async {
    final tested = {for (final r in state.results) r.id: r.percent};
    final prune = await _store.pruneBelow(
      testedPercentById: tested,
      percent: pct,
    );
    if (prune.removed == 0) return 0;
    await _cache.drop(prune.removedIds);
    final keptIds = {for (final s in prune.kept) s.id};
    ref.invalidate(byeDpiStrategiesProvider);
    state = state.copyWith(
      results: state.results.where((r) => keptIds.contains(r.id)).toList(),
    );
    await _syncRuntimeIfActive(prune.removedIds);
    return prune.removed;
  }

  Future<void> resetStrategies() async {
    await _store.reset();
    await _cache.clear();
    ref.invalidate(byeDpiStrategiesProvider);
    state = const StrategyTestState();
    // Args of the still-active preset may revert to the bundled set.
    await ref.read(byeDpiSettingsProvider.notifier).syncRuntime();
  }

  // Restart byedpi only when a removed strategy was the active one — its
  // effective args change (falls back to default); others don't touch the engine.
  Future<void> _syncRuntimeIfActive(Set<String> removedIds) async {
    final active = ref.read(byeDpiSettingsProvider).preset;
    if (removedIds.contains(active)) {
      await ref.read(byeDpiSettingsProvider.notifier).syncRuntime();
    }
  }
}
