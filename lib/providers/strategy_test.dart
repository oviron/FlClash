import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:fl_clash/byedpi/strategy_test_codec.dart';
import 'package:fl_clash/byedpi/strategy_test_model.dart';
import 'package:fl_clash/byedpi/test_store.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/strategy_test.g.dart';

// In-app strategy auto-test: pauses the VPN, runs byedpi standalone per strategy
// via native, caches results. Apply selects the id + writes the exclude list
// (its failed hosts → routed via VPN).
@riverpod
class StrategyTestController extends _$StrategyTestController {
  Service get _svc => Service();
  bool _wasVpnOn = false;
  Map<String, String> _labels = const {};

  @override
  StrategyTestState build() => const StrategyTestState();

  // Render last results from the on-disk cache (no re-test).
  Future<void> loadCached() async {
    if (state.phase == TestPhase.running || state.results.isNotEmpty) return;
    final cache = await readTestResults();
    if (cache.isEmpty) return;
    final results = <StrategyTestResult>[];
    cache.forEach((id, raw) {
      if (raw is! Map) return;
      try {
        results.add(
          strategyTestResultFromCache(id, Map<String, dynamic>.from(raw)),
        );
      } catch (_) {
        return;
      }
    });
    results.sort((a, b) => b.percent.compareTo(a.percent));
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
    final hostsRaw = await readHostList();
    final sites = hostsRaw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('#'))
        .toList();
    if (strategies.isEmpty || sites.isEmpty) {
      state = const StrategyTestState(
        phase: TestPhase.done,
        error: 'no strategies or sites',
      );
      return;
    }

    _labels = {for (final s in all) s.id: s.label};
    _wasVpnOn = appController.isStart;
    if (_wasVpnOn) await appController.updateStatus(false);

    state = StrategyTestState(
      phase: TestPhase.running,
      total: strategies.length,
      results: state.results,
    );
    _svc.onStrategyTestProgress = _onProgress;

    final params = jsonEncode({
      'strategies': [
        for (final s in strategies) {'id': s.id, 'args': s.args},
      ],
      'sites': sites,
      'requests': requests,
      'timeout': timeout,
      'concurrency': concurrency,
    });
    final ok = await _svc.startStrategyTest(params);
    if (!ok) await _finish(error: 'failed to start test');
  }

  Future<void> testOne(String id) => run(onlyIds: {id});

  void _onProgress(String jsonStr) {
    final StrategyTestProgress progress;
    try {
      progress = parseStrategyTestProgress(
        jsonStr,
        labelFor: (id) => _labels[id] ?? id,
      );
    } catch (_) {
      return;
    }
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
    await _svc.stopStrategyTest();
    await _finish();
  }

  Future<void> _finish({String? error}) async {
    _svc.onStrategyTestProgress = null;
    if (_wasVpnOn) {
      await appController.updateStatus(true);
      _wasVpnOn = false;
    }
    final sorted = [...state.results]
      ..sort((a, b) => b.percent.compareTo(a.percent));
    await _persist(sorted);
    state = StrategyTestState(
      phase: TestPhase.done,
      completed: state.completed,
      total: state.total,
      results: sorted,
      error: error,
    );
  }

  // Merge this run's results into the on-disk cache (other strategies' prior
  // entries survive), so per-strategy dates and offline render work.
  Future<void> _persist(List<StrategyTestResult> results) async {
    final cache = await readTestResults();
    for (final r in results) {
      cache[r.id] = strategyTestResultToCache(r);
    }
    await writeTestResults(cache);
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
    ref.read(byeDpiCoreRevisionProvider.notifier).bump();
    final total = result?.sites.length ?? 0;
    return (byedpi: total - failed.length, vpn: failed.length);
  }

  // Curation — writes the on-disk strategy override (persists; reset reverts to
  // the bundled default). The picker/test/routing all read the same set.
  Future<void> removeStrategy(String id) async {
    final current = await loadByeDpiStrategies();
    await saveStrategyList(current.where((s) => s.id != id).toList());
    await _dropFromCache({id});
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
    final current = await loadByeDpiStrategies();
    final kept = current.where((s) => (tested[s.id] ?? pct) >= pct).toList();
    final removed = current.length - kept.length;
    if (removed == 0) return 0;
    final keptIds = {for (final s in kept) s.id};
    await saveStrategyList(kept);
    await _dropFromCache({
      for (final s in current)
        if (!keptIds.contains(s.id)) s.id,
    });
    ref.invalidate(byeDpiStrategiesProvider);
    state = state.copyWith(
      results: state.results.where((r) => keptIds.contains(r.id)).toList(),
    );
    await _syncRuntimeIfActive({
      for (final s in current)
        if (!keptIds.contains(s.id)) s.id,
    });
    return removed;
  }

  Future<void> resetStrategies() async {
    await resetStrategyList();
    await writeTestResults({});
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

  Future<void> _dropFromCache(Set<String> ids) async {
    final cache = await readTestResults();
    for (final id in ids) {
      cache.remove(id);
    }
    await writeTestResults(cache);
  }
}
