import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _assetPath = 'assets/data/byedpi-strategies.json';

Future<String> strategyArgsPath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'byedpi-strategies.json');
}

// Args are data, not code: the bundled JSON asset is primary, an on-disk file
// (dropped by a future remote-refresh or by hand) overrides it. Unlike the host
// list this is NOT force-installed on start, so an updated on-disk file persists
// across launches — the seam Level-2 remote refresh will write to.
Future<Map<String, String>> readStrategyArgs() async {
  final path = await strategyArgsPath();
  final f = File(path);
  final raw = f.existsSync()
      ? await f.readAsString()
      : await rootBundle.loadString(_assetPath);
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  } catch (_) {
    return const {};
  }
}
