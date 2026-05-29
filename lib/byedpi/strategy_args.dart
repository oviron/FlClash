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

/// Strict parse + validation shared by the loader and the remote updater.
/// Throws [FormatException] on malformed JSON, an empty set, or empty/duplicate ids.
List<ByeDpiStrategy> parseStrategyList(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List || decoded.isEmpty) {
    throw const FormatException('strategy list must be a non-empty array');
  }
  final list = decoded
      .whereType<Map<String, dynamic>>()
      .map(ByeDpiStrategy.fromJson)
      .toList(growable: false);
  if (list.isEmpty) {
    throw const FormatException('no valid strategy entries');
  }
  final ids = <String>{};
  for (final s in list) {
    if (s.id.isEmpty) {
      throw const FormatException('strategy id must be non-empty');
    }
    if (!ids.add(s.id)) {
      throw FormatException('duplicate strategy id: ${s.id}');
    }
  }
  return list;
}

// Bundled JSON asset is the source of truth; an on-disk file (written by the
// remote updater or by hand) overrides it. Not force-installed on start, so an
// updated set persists across launches. Falls back to the asset, then empty, if
// the on-disk copy is unreadable.
Future<List<ByeDpiStrategy>> loadByeDpiStrategies() async {
  final f = File(await strategyListPath());
  if (f.existsSync()) {
    try {
      return parseStrategyList(await f.readAsString());
    } catch (_) {
      // fall through to the bundled asset
    }
  }
  try {
    return parseStrategyList(await rootBundle.loadString(_assetPath));
  } catch (_) {
    return const [];
  }
}

Future<Map<String, String>> readStrategyArgs() async {
  final list = await loadByeDpiStrategies();
  return {for (final s in list) s.id: s.args};
}

// Atomic write of an already-validated strategy list to the on-disk override.
Future<void> writeStrategyList(String raw) async {
  final path = await strategyListPath();
  final tmp = File('$path.tmp');
  await tmp.writeAsString(raw);
  await tmp.rename(path);
}

// Drop the on-disk override so the bundled asset takes over again.
Future<void> resetStrategyList() async {
  final f = File(await strategyListPath());
  if (f.existsSync()) await f.delete();
}
