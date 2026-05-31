import 'dart:convert';

import 'strategy_test_model.dart';

int _requiredInt(Map<String, dynamic> raw, String key) {
  final value = raw[key];
  if (value is! num) {
    throw FormatException('strategy test field "$key" must be numeric');
  }
  return value.toInt();
}

String _requiredString(Map<String, dynamic> raw, String key) {
  final value = raw[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('strategy test field "$key" must be a string');
  }
  return value;
}

List<SiteOutcome> _parseSites(Object? raw) {
  if (raw is! List) {
    throw const FormatException('strategy test field "sites" must be a list');
  }
  return [
    for (final site in raw)
      if (site is Map)
        SiteOutcome(
          site['site'].toString(),
          (site['ok'] as num).toInt(),
          (site['total'] as num).toInt(),
        )
      else
        throw const FormatException('strategy test site must be an object'),
  ];
}

StrategyTestResult strategyTestResultFromCache(
  String id,
  Map<String, dynamic> raw,
) {
  final sites = _parseSites(raw['sites']);
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

Map<String, dynamic> strategyTestResultToCache(StrategyTestResult result) => {
  'label': result.label,
  'percent': result.percent,
  'timestamp': result.testedAt,
  'sites': [
    for (final site in result.sites)
      {'site': site.site, 'ok': site.ok, 'total': site.total},
  ],
};

StrategyTestProgress parseStrategyTestProgress(
  String raw, {
  required String Function(String id) labelFor,
  int? testedAt,
}) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('strategy test progress must be an object');
  }

  final error = decoded['error'];
  if (error != null) {
    return StrategyTestProgress(error: error.toString(), done: true);
  }

  final id = _requiredString(decoded, 'id');
  final result = StrategyTestResult(
    id: id,
    label: labelFor(id),
    percent: _requiredInt(decoded, 'percent'),
    success: _requiredInt(decoded, 'success'),
    totalRequests: _requiredInt(decoded, 'totalRequests'),
    sites: _parseSites(decoded['sites']),
    testedAt: testedAt ?? DateTime.now().millisecondsSinceEpoch,
  );

  return StrategyTestProgress(
    result: result,
    completed: _requiredInt(decoded, 'index') + 1,
    done: decoded['done'] == true,
  );
}
