import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/test_store.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/strategy_test.g.dart';

enum TestPhase { idle, running, done }

class SiteOutcome {
  final String site;
  final int ok;
  final int total;

  const SiteOutcome(this.site, this.ok, this.total);
}

class StrategyTestResult {
  final String id;
  final String label;
  final int percent;
  final int success;
  final int totalRequests;
  final List<SiteOutcome> sites;
  final int? testedAt; // epoch ms

  const StrategyTestResult({
    required this.id,
    required this.label,
    required this.percent,
    required this.success,
    required this.totalRequests,
    required this.sites,
    this.testedAt,
  });

  List<String> get failedHosts => [
    for (final s in sites)
      if (s.ok == 0) s.site,
  ];
}

// (byedpiCount, vpnCount) reported back to the UI on apply().
typedef ApplySplit = ({int byedpi, int vpn});

class StrategyTestState {
  final TestPhase phase;
  final int completed;
  final int total;
  final String currentLabel;
  final List<StrategyTestResult> results;
  final String? error;

  const StrategyTestState({
    this.phase = TestPhase.idle,
    this.completed = 0,
    this.total = 0,
    this.currentLabel = '',
    this.results = const [],
    this.error,
  });

  StrategyTestState copyWith({
    TestPhase? phase,
    int? completed,
    int? total,
    String? currentLabel,
    List<StrategyTestResult>? results,
  }) => StrategyTestState(
    phase: phase ?? this.phase,
    completed: completed ?? this.completed,
    total: total ?? this.total,
    currentLabel: currentLabel ?? this.currentLabel,
    results: results ?? this.results,
    error: error,
  );
}

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
      results.add(_resultFromCache(id, Map<String, dynamic>.from(raw)));
    });
    results.sort((a, b) => b.percent.compareTo(a.percent));
    state = StrategyTestState(phase: TestPhase.done, results: results);
  }

  StrategyTestResult _resultFromCache(String id, Map<String, dynamic> raw) {
    final sites = [
      for (final s in (raw['sites'] as List? ?? []))
        SiteOutcome(
          (s as Map)['site'].toString(),
          (s['ok'] as num).toInt(),
          (s['total'] as num).toInt(),
        ),
    ];
    return StrategyTestResult(
      id: id,
      label: (raw['label'] ?? id).toString(),
      percent: (raw['percent'] as num?)?.toInt() ?? 0,
      success: sites.fold(0, (a, s) => a + s.ok),
      totalRequests: sites.fold(0, (a, s) => a + s.total),
      sites: sites,
      testedAt: (raw['timestamp'] as num?)?.toInt(),
    );
  }

  Future<void> run({
    int requests = 1,
    int timeout = 5,
    int concurrency = 20,
  }) async {
    if (state.phase == TestPhase.running) return;

    final strategies = await ref.read(byeDpiStrategiesProvider.future);
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

    _labels = {for (final s in strategies) s.id: s.label};
    _wasVpnOn = appController.isStart;
    if (_wasVpnOn) await appController.updateStatus(false);

    state = StrategyTestState(
      phase: TestPhase.running,
      total: strategies.length,
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

  void _onProgress(String jsonStr) {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (m['error'] != null) {
      unawaited(_finish(error: m['error'].toString()));
      return;
    }
    final id = m['id'] as String;
    final sites = [
      for (final s in (m['sites'] as List))
        SiteOutcome(
          (s as Map)['site'].toString(),
          (s['ok'] as num).toInt(),
          (s['total'] as num).toInt(),
        ),
    ];
    final res = StrategyTestResult(
      id: id,
      label: _labels[id] ?? id,
      percent: (m['percent'] as num).toInt(),
      success: (m['success'] as num).toInt(),
      totalRequests: (m['totalRequests'] as num).toInt(),
      sites: sites,
    );
    state = state.copyWith(
      results: [...state.results, res],
      completed: (m['index'] as num).toInt() + 1,
      currentLabel: res.label,
    );
    if (m['done'] == true) unawaited(_finish());
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
    final now = DateTime.now().millisecondsSinceEpoch;
    final stamped = [
      for (final r in state.results)
        StrategyTestResult(
          id: r.id,
          label: r.label,
          percent: r.percent,
          success: r.success,
          totalRequests: r.totalRequests,
          sites: r.sites,
          testedAt: now,
        ),
    ]..sort((a, b) => b.percent.compareTo(a.percent));
    await _persist(stamped);
    state = StrategyTestState(
      phase: TestPhase.done,
      completed: state.completed,
      total: state.total,
      results: stamped,
      error: error,
    );
  }

  // Merge this run's results into the on-disk cache (other strategies' prior
  // entries survive), so per-strategy dates and offline render work.
  Future<void> _persist(List<StrategyTestResult> results) async {
    final cache = await readTestResults();
    for (final r in results) {
      cache[r.id] = {
        'label': r.label,
        'percent': r.percent,
        'timestamp': r.testedAt,
        'sites': [
          for (final s in r.sites)
            {'site': s.site, 'ok': s.ok, 'total': s.total},
        ],
      };
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
    await ref.read(byeDpiSettingsProvider.notifier).setPreset(id);
    await appController.applyProfile(silence: true);
    final total = result?.sites.length ?? 0;
    return (byedpi: total - failed.length, vpn: failed.length);
  }
}
