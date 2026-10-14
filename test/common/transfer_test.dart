import 'dart:io';

import 'package:fl_clash/common/backup_task.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/provider_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('transfer');
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<File> write(String path, String content) async {
    final file = File(join(root.path, path));
    await file.parent.create(recursive: true);
    return file.writeAsString(content);
  }

  test('takes in the other build\'s cache and index over its own', () async {
    await write('mine/index.json', '{"1":["proxies/a"]}');
    await write('mine/proxies/${'a' * 32}', 'mine');
    await write('mine/proxies/${'b' * 32}', 'old');
    await write('theirs/index.json', '{"2":["proxies/b"]}');
    await write('theirs/proxies/${'b' * 32}', 'theirs');
    await importProviderCache(
      join(root.path, 'mine'),
      join(root.path, 'theirs'),
    );
    String read(String path) =>
        File(join(root.path, 'mine', path)).readAsStringSync();
    expect(read('index.json'), '{"2":["proxies/b"]}');
    expect(read('proxies/${'b' * 32}'), 'theirs');
    expect(read('proxies/${'a' * 32}'), 'mine');
  });

  test('takes in no cache when the other build had none', () async {
    await write('mine/index.json', '{}');
    await importProviderCache(join(root.path, 'mine'), join(root.path, 'no'));
    expect(File(join(root.path, 'mine/index.json')).existsSync(), isTrue);
  });

  test(
    'takes in device values and the other build\'s group snapshots',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'groupsSnapshot.1': 'mine',
        'happHwid': 'mine',
        'config': 'mine',
      });
      await preferences.importTransferred({
        'groupsSnapshot.2': 'theirs',
        'happHwid': 'theirs',
        'inboundAuth': 'theirs',
        'config': 'theirs',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('groupsSnapshot.1'), isNull);
      expect(prefs.getString('groupsSnapshot.2'), 'theirs');
      expect(await preferences.getHwid(), 'theirs');
      expect(await preferences.getInboundAuth(), 'theirs');
      expect(prefs.getString('config'), 'mine');
    },
  );

  test('reads the schema version from the database header', () async {
    final header = List.filled(100, 0)..[63] = 12;
    final file = File(join(root.path, 'database.sqlite'));
    await file.writeAsBytes(header);
    expect(await databaseUserVersion(file), 12);
    await file.writeAsBytes([1, 2, 3]);
    expect(await databaseUserVersion(file), 0);
  });
}
