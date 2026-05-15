import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/repository.dart';
import 'package:fl_clash/byedpi/settings_store.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'generated/byedpi.g.dart';

Future<void> writeByeDpiRuntime(ByeDpiSettings s) async {
  final dir = await appPath.homeDirPath;
  final file = File(join(dir, 'byedpi-runtime.json'));
  await file.writeAsString(jsonEncode({
    'enabled': s.enabled,
    'port': s.port,
    'cliArgs': s.cliArgs,
  }));
}

@riverpod
class ByeDpiSettingsNotifier extends _$ByeDpiSettingsNotifier
    with AutoDisposeNotifierMixin {
  @override
  ByeDpiSettings build() {
    return const ByeDpiSettings();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    value = ByeDpiSettingsStore(prefs).read();
  }

  Future<void> setEnabled(bool v) async {
    final next = value.copyWith(enabled: v);
    await _persist(next);
  }

  Future<void> setPort(int v) async {
    final next = value.copyWith(port: v);
    await _persist(next);
  }

  Future<void> setCliArgs(String v) async {
    final next = value.copyWith(cliArgs: v);
    await _persist(next);
  }

  Future<void> setFallbackGroup(String v) async {
    final next = value.copyWith(fallbackGroup: v);
    await _persist(next);
  }

  Future<void> _persist(ByeDpiSettings next) async {
    value = next;
    final prefs = await SharedPreferences.getInstance();
    await ByeDpiSettingsStore(prefs).write(next);
    await writeByeDpiRuntime(next);
  }
}

@riverpod
Stream<List<BypassProfile>> bypassProfilesStream(Ref ref) {
  return database.bypassProfilesDao.watchAll();
}

@riverpod
Future<List<BypassProfile>> bypassProfilesOnce(Ref ref) {
  return currentBypassProfiles(database);
}
