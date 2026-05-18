import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/settings_store.dart';
import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'generated/byedpi.g.dart';

Future<void> writeByeDpiRuntime(ByeDpiSettings s) async {
  final dir = await appPath.homeDirPath;
  final hostsFile = await hostListPath();
  final target = File(join(dir, 'byedpi-runtime.json'));
  final tmp = File(join(dir, 'byedpi-runtime.json.tmp'));
  await tmp.writeAsString(
    jsonEncode({
      'enabled': s.enabled,
      'port': s.port,
      'cliArgs': effectiveByeDpiCliArgs(s),
      'hostsFile': hostsFile,
    }),
  );
  await tmp.rename(target.path);
}

@riverpod
class ByeDpiSettingsNotifier extends _$ByeDpiSettingsNotifier
    with AutoDisposeNotifierMixin {
  @override
  ByeDpiSettings build() {
    return const ByeDpiSettings();
  }

  Future<void> setEnabled(bool v) => _persist(value.copyWith(enabled: v));

  Future<void> setMode(ByeDpiMode v) => _persist(value.copyWith(mode: v));

  Future<void> setFallbackEnabled(bool v) =>
      _persist(value.copyWith(fallbackEnabled: v));

  Future<void> setFallbackGroup(String v) =>
      _persist(value.copyWith(fallbackGroup: v));

  Future<void> setPort(int v) => _persist(value.copyWith(port: v));

  Future<void> setPreset(ByeDpiPreset v) => _persist(value.copyWith(preset: v));

  Future<void> setCliArgs(String v) => _persist(value.copyWith(cliArgs: v));

  Future<void> _persist(ByeDpiSettings next) async {
    value = next;
    final prefs = await SharedPreferences.getInstance();
    await ByeDpiSettingsStore(prefs).write(next);
    await writeByeDpiRuntime(next);
  }
}
