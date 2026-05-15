import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
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

@Riverpod(keepAlive: true)
class BypassProfilesRepo extends _$BypassProfilesRepo {
  @override
  List<BypassProfile> build() {
    return ref.watch(bypassProfilesStreamProvider).value ?? const [];
  }

  Future<void> add(BypassProfile profile) =>
      database.bypassProfilesDao.upsert(profile);

  Future<void> update(BypassProfile profile) =>
      database.bypassProfilesDao.upsert(profile);

  Future<void> delete(int id) =>
      database.bypassProfilesDao.deleteById(id);

  Future<void> reorder(List<int> idsInNewOrder) async {
    if (idsInNewOrder.isEmpty) return;
    await database.batch((b) {
      for (var i = 0; i < idsInNewOrder.length; i++) {
        b.update(
          database.bypassProfiles,
          BypassProfilesCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(idsInNewOrder[i]),
        );
      }
    });
  }
}
