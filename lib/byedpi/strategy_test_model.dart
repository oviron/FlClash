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
  final int? testedAt;

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

class StrategyTestProgress {
  final StrategyTestResult? result;
  final String? error;
  final int completed;
  final bool done;

  const StrategyTestProgress({
    this.result,
    this.error,
    this.completed = 0,
    this.done = false,
  });
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
    String? error,
  }) => StrategyTestState(
    phase: phase ?? this.phase,
    completed: completed ?? this.completed,
    total: total ?? this.total,
    currentLabel: currentLabel ?? this.currentLabel,
    results: results ?? this.results,
    error: error ?? this.error,
  );
}
