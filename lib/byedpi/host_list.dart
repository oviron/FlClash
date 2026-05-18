import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _assetPath = 'assets/data/byedpi-hosts-default.txt';

Future<String> hostListPath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'byedpi-hosts.txt');
}

Future<void> installDefaultHostList() async {
  // The bundled asset is the source of truth; the on-disk file is replaced
  // every app start so stale broad lists from older RCs cannot survive.
  final path = await hostListPath();
  final tmp = File('$path.tmp');
  final contents = await rootBundle.loadString(_assetPath);
  await tmp.writeAsString(contents);
  await tmp.rename(path);
}

Future<String> readHostList() async {
  final path = await hostListPath();
  final f = File(path);
  if (!f.existsSync()) return rootBundle.loadString(_assetPath);
  return f.readAsString();
}
