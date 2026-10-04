import 'package:fl_clash/common/migration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('migrateFindProcessMode', () {
    Map<String, Object?> config(String? mode) => {
      'patchClashConfig': {'mixed-port': 7890, 'find-process-mode': ?mode},
    };

    test('moves the old always default to strict', () {
      final map = config('always');
      migrateFindProcessMode(map);
      expect((map['patchClashConfig'] as Map)['find-process-mode'], 'strict');
    });

    test('keeps an explicit off', () {
      final map = config('off');
      migrateFindProcessMode(map);
      expect((map['patchClashConfig'] as Map)['find-process-mode'], 'off');
    });

    test('tolerates a config without the key or the section', () {
      final map = config(null);
      migrateFindProcessMode(map);
      expect(map['patchClashConfig'], {'mixed-port': 7890});

      final empty = <String, Object?>{};
      migrateFindProcessMode(empty);
      expect(empty, isEmpty);
    });
  });

  group('migrateBackupConfig', () {
    Map<String, Object?> backup(Object? version) => {
      'version': ?version,
      'patchClashConfig': {'find-process-mode': 'always'},
    };

    String? mode(Map<String, Object?> map) =>
        (map['patchClashConfig'] as Map)['find-process-mode'] as String?;

    test('moves always to strict in a backup written before version 2', () {
      for (final version in [null, 0, 1]) {
        final map = backup(version);
        migrateBackupConfig(map);
        expect(mode(map), 'strict', reason: 'version $version');
      }
    });

    test('keeps always chosen in a backup from version 2 on', () {
      final map = backup(2);
      migrateBackupConfig(map);
      expect(mode(map), 'always');
    });
  });
}
