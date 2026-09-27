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
}
