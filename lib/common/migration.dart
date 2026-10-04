import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';

class Migration {
  static Migration? _instance;
  late int _oldVersion;

  Migration._internal();

  final currentVersion = 2;

  factory Migration() {
    _instance ??= Migration._internal();
    return _instance!;
  }

  Future<Config> migrationIfNeeded(
    Map<String, Object?>? configMap, {
    required Future<Config> Function(MigrationData data) sync,
  }) async {
    _oldVersion = await preferences.getVersion();
    if (_oldVersion >= 1) {
      try {
        if (_oldVersion == 1 && configMap != null) {
          migrateFindProcessMode(configMap);
        }
        final config = Config.realFromJson(configMap);
        if (_oldVersion != currentVersion) {
          await preferences.saveConfig(config);
          await preferences.setVersion(currentVersion);
        }
        return config;
      } catch (_) {
        final isV0 = configMap?['proxiesStyle'] != null;
        if (isV0) {
          _oldVersion = 0;
        } else {
          throw 'Local data is damaged. A reset is required to fix this issue.';
        }
      }
    }
    MigrationData data = MigrationData(configMap: configMap);
    if (_oldVersion == 0 && configMap != null) {
      final clashConfigMap = await preferences.getClashConfigMap();
      if (clashConfigMap != null) {
        configMap['patchClashConfig'] = clashConfigMap;
        await preferences.clearClashConfig();
      }
      data = await _oldToNow(configMap);
      final migrated = data.configMap;
      if (migrated != null) migrateFindProcessMode(migrated);
    }
    final res = await sync(data);
    await preferences.setVersion(currentVersion);
    return res;
  }

  Future<MigrationData> _oldToNow(Map<String, Object?> configMap) async {
    return await oldToNowTask(configMap);
  }
}

// `always` was the stored default, indistinguishable from a deliberate choice.
void migrateFindProcessMode(Map<String, Object?> configMap) {
  final clash = configMap['patchClashConfig'];
  if (clash is Map && clash['find-process-mode'] == 'always') {
    clash['find-process-mode'] = 'strict';
  }
}

// Backups carry the preferences version they were written at.
void migrateBackupConfig(Map<String, Object?> configMap) {
  final version = configMap['version'];
  if (version is! int || version < 2) {
    migrateFindProcessMode(configMap);
  }
}

final migration = Migration();
