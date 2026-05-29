import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/byedpi/model.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _assetPath = 'assets/data/byedpi-strategies.json';

Future<String> strategyListPath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'byedpi-strategies.json');
}

// The bundled JSON asset is the source of truth; an on-disk file (dropped by a
// future remote refresh or by hand) overrides it. Intentionally not
// force-installed on start, so an updated on-disk set persists across launches.
Future<List<ByeDpiStrategy>> loadByeDpiStrategies() async {
  final f = File(await strategyListPath());
  final raw = f.existsSync()
      ? await f.readAsString()
      : await rootBundle.loadString(_assetPath);
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ByeDpiStrategy.fromJson)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

Future<Map<String, String>> readStrategyArgs() async {
  final list = await loadByeDpiStrategies();
  return {for (final s in list) s.id: s.args};
}
