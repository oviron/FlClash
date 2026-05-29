import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/settings_store.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'generated/byedpi.g.dart';

@riverpod
Future<List<ByeDpiStrategy>> byeDpiStrategies(Ref ref) =>
    loadByeDpiStrategies();

// File-driven reload signals (host-list / exclude / strategy-set) the reconciler
// watches; settings changes flow through byeDpiSettingsProvider directly.
@riverpod
class ByeDpiCoreRevision extends _$ByeDpiCoreRevision {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

@riverpod
class ByeDpiEngineRevision extends _$ByeDpiEngineRevision {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

Future<void> writeByeDpiRuntime(ByeDpiSettings s) async {
  final dir = await appPath.homeDirPath;
  final hostsFile = await hostListPath();
  final strategyArgs = await readStrategyArgs();
  final target = File(join(dir, 'byedpi-runtime.json'));
  final tmp = File(join(dir, 'byedpi-runtime.json.tmp'));
  await tmp.writeAsString(
    jsonEncode({
      'enabled': s.enabled,
      'port': s.port,
      'cliArgs': effectiveByeDpiCliArgs(s, strategyArgs),
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

  Future<void> setPreset(String v) => _persist(value.copyWith(preset: v));

  Future<void> setCliArgs(String v) => _persist(value.copyWith(cliArgs: v));

  Future<void> _persist(ByeDpiSettings next) async {
    value = next;
    final prefs = await SharedPreferences.getInstance();
    await ByeDpiSettingsStore(prefs).write(next);
    await writeByeDpiRuntime(next);
  }

  // Re-derive runtime.json after the strategy set changed (remote update, prune,
  // reset) — the active preset's effective args may differ though its id didn't.
  // Bumps the engine signal so the reconciler restarts byedpi to read them.
  Future<void> syncRuntime() async {
    await writeByeDpiRuntime(value);
    ref.read(byeDpiEngineRevisionProvider.notifier).bump();
  }
}
