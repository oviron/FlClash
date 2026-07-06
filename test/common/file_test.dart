import 'dart:io';

import 'package:fl_clash/common/file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmpDir;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('flclash_file_test');
  });

  tearDown(() async {
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
    }
  });

  test(
    'safeWriteAsStringAtomic writes full content and creates parents',
    () async {
      final f = File(p.join(tmpDir.path, 'nested', 'a.txt'));
      await f.safeWriteAsStringAtomic('hello');
      expect(await f.readAsString(), 'hello');
    },
  );

  test(
    'concurrent atomic writes leave one complete content, never torn',
    () async {
      final f = File(p.join(tmpDir.path, 'c.txt'));
      final a = 'A' * 200000;
      final b = 'B' * 200000;

      await Future.wait([
        f.safeWriteAsStringAtomic(a),
        f.safeWriteAsStringAtomic(b),
      ]);

      final got = await f.readAsString();
      // Exactly one full write won; never a mix, never a truncated file.
      expect(got.length, 200000);
      expect(got == a || got == b, isTrue);

      // No temp files left behind at the destination dir.
      final leftovers = tmpDir
          .listSync()
          .whereType<File>()
          .where((e) => p.basename(e.path).contains('.tmp'))
          .toList();
      expect(leftovers, isEmpty);
    },
  );
}
