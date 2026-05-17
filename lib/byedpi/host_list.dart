import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _assetPath = 'assets/data/byedpi-hosts-default.txt';

Future<String> hostListPath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'byedpi-hosts.txt');
}

Future<void> ensureDefaultPresent() async {
  // The narrow default is the source of truth; the on-disk file is replaced
  // every app start. UI edits are session-only and get reset on next launch.
  final path = await hostListPath();
  final contents = await rootBundle.loadString(_assetPath);
  await _atomicWrite(path, contents);
}

Future<String> readHostList() async {
  final path = await hostListPath();
  final f = File(path);
  if (!f.existsSync()) {
    return rootBundle.loadString(_assetPath);
  }
  return f.readAsString();
}

Future<void> writeHostList(String contents) async {
  final path = await hostListPath();
  await _atomicWrite(path, contents);
}

Future<void> resetHostListToDefault() async {
  final contents = await rootBundle.loadString(_assetPath);
  await _atomicWrite(await hostListPath(), contents);
}

Future<int> countHosts() async {
  final text = await readHostList();
  return text
      .split('\n')
      .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
      .length;
}

Future<void> _atomicWrite(String path, String contents) async {
  final tmp = File('$path.tmp');
  await tmp.writeAsString(contents);
  await tmp.rename(path);
}
