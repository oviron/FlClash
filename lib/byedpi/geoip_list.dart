import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _assetPath = 'assets/data/byedpi-geoip-default.txt';

Future<String> geoipListPath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'byedpi-geoip.txt');
}

Future<void> ensureDefaultGeoipPresent() async {
  final path = await geoipListPath();
  if (File(path).existsSync()) return;
  final contents = await rootBundle.loadString(_assetPath);
  await _atomicWrite(path, contents);
}

Future<String> readGeoipList() async {
  final path = await geoipListPath();
  final f = File(path);
  if (!f.existsSync()) {
    return rootBundle.loadString(_assetPath);
  }
  return f.readAsString();
}

Future<void> writeGeoipList(String contents) async {
  await _atomicWrite(await geoipListPath(), contents);
}

Future<void> resetGeoipListToDefault() async {
  final contents = await rootBundle.loadString(_assetPath);
  await _atomicWrite(await geoipListPath(), contents);
}

Future<int> countGeoipCategories() async {
  final text = await readGeoipList();
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
