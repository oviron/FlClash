import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> _supportDir() async =>
    (await getApplicationSupportDirectory()).path;

Future<void> _atomicWrite(String path, String contents) async {
  final tmp = File('$path.tmp');
  await tmp.writeAsString(contents);
  await tmp.rename(path);
}

// --- exclude list: hosts the active strategy failed in its last test.
// engine routing uses readHostList() − exclude (see providers/state.dart). ---

Future<String> _excludePath() async =>
    join(await _supportDir(), 'byedpi-exclude.json');

Future<Set<String>> readExclude() async {
  final f = File(await _excludePath());
  if (!f.existsSync()) return const {};
  try {
    final list = jsonDecode(await f.readAsString()) as List<dynamic>;
    return list.map((e) => e.toString()).toSet();
  } catch (_) {
    return const {};
  }
}

Future<void> writeExclude(Iterable<String> hosts) =>
    _excludePath().then((p) => _atomicWrite(p, jsonEncode(hosts.toList())));

// --- test results cache: id -> { percent, timestamp(ms), sites:[{site,ok,total}] }.
// Lets the dashboard render from cache and keep per-strategy dates. ---

Future<String> _resultsPath() async =>
    join(await _supportDir(), 'byedpi-test-results.json');

Future<Map<String, dynamic>> readTestResults() async {
  final f = File(await _resultsPath());
  if (!f.existsSync()) return {};
  try {
    final decoded = jsonDecode(await f.readAsString());
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    return {};
  }
}

Future<void> writeTestResults(Map<String, dynamic> results) =>
    _resultsPath().then((p) => _atomicWrite(p, jsonEncode(results)));
