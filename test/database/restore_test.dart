import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(int id) => Profile(
  id: id,
  label: 'p$id',
  url: '',
  autoUpdateDuration: const Duration(hours: 1),
);

Rule _rule(int id) => Rule(id: id, value: 'DOMAIN,r$id.example,DIRECT');

Script _script(int id) =>
    Script(id: id, label: 's$id', lastUpdateTime: DateTime.utc(2026));

void main() {
  const deviceLink = ProfileRuleLink(
    profileId: 1,
    ruleId: 10,
    scene: RuleScene.added,
  );
  const backupLink = ProfileRuleLink(
    profileId: 1,
    ruleId: 20,
    scene: RuleScene.added,
  );

  late Database db;

  setUp(() async {
    db = Database(NativeDatabase.memory());
    await db.profiles.put(_profile(1).toCompanion());
    await db.rulesDao.putProfileAddedRule(1, _rule(10));
    await db.scriptsDao.setAll([_script(1)]);
  });

  tearDown(() => db.close());

  Future<void> restoreBackup({required bool isOverride}) {
    return db.restore(
      [_profile(1)],
      [_script(2)],
      [_rule(20)],
      [backupLink],
      isOverride: isOverride,
    );
  }

  Future<Set<String>> linkIds() async {
    final rows = await db.select(db.profileRuleLinks).get();
    return rows.map((row) => row.id).toSet();
  }

  Future<Set<int>> ruleIds() async {
    final rows = await db.select(db.rules).get();
    return rows.map((row) => row.id).toSet();
  }

  Future<Set<int>> scriptIds() async {
    final scripts = await db.scriptsDao.all().get();
    return scripts.map((script) => script.id).toSet();
  }

  group('merge restore keeps what only the device has', () {
    setUp(() => restoreBackup(isOverride: false));

    test('rules and their links', () async {
      expect(await linkIds(), {deviceLink.key, backupLink.key});
      expect(await ruleIds(), {10, 20});
    });

    test('scripts', () async {
      expect(await scriptIds(), {1, 2});
    });
  });

  group('override restore replaces the device data with the backup', () {
    setUp(() => restoreBackup(isOverride: true));

    test('rules and their links', () async {
      expect(await linkIds(), {backupLink.key});
      expect(await ruleIds(), {20});
    });

    test('scripts', () async {
      expect(await scriptIds(), {2});
    });
  });
}
