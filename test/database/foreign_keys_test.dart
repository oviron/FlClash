import 'dart:io';

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

Future<Set<String>> _linkIds(Database db) async {
  final rows = await db.select(db.profileRuleLinks).get();
  return rows.map((row) => row.id).toSet();
}

Future<Set<int>> _ruleIds(Database db) async {
  final rows = await db.select(db.rules).get();
  return rows.map((row) => row.id).toSet();
}

Future<void> _insertLink(Database db, ProfileRuleLink link) {
  return db.into(db.profileRuleLinks).insert(link.toCompanion());
}

void main() {
  const globalLink = ProfileRuleLink(ruleId: 10);
  const profileLink = ProfileRuleLink(
    profileId: 1,
    ruleId: 11,
    scene: RuleScene.added,
  );
  const missingProfileLink = ProfileRuleLink(
    profileId: 99,
    ruleId: 12,
    scene: RuleScene.added,
  );
  const missingRuleLink = ProfileRuleLink(ruleId: 999);
  const secondProfileLink = ProfileRuleLink(
    profileId: 2,
    ruleId: 12,
    scene: RuleScene.added,
  );

  test('v9 -> v10 upgrade purges orphans, then enforces FKs', () async {
    final dir = await Directory.systemTemp.createTemp('flclash_fk');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v9 = Database(NativeDatabase(file));
    await v9.customStatement('PRAGMA foreign_keys = OFF');
    await v9.profiles.put(_profile(1).toCompanion());
    for (final id in [10, 11, 12, 13]) {
      await v9.rules.put(_rule(id).toCompanion());
    }
    for (final link in [
      globalLink,
      profileLink,
      missingProfileLink,
      missingRuleLink,
    ]) {
      await _insertLink(v9, link);
    }
    await v9.customStatement('PRAGMA user_version = 9');
    await v9.close();

    final db = Database(NativeDatabase(file));
    addTearDown(db.close);

    expect(await _linkIds(db), {globalLink.key, profileLink.key});
    // Rule 12 lost its only link with the missing profile; rule 13 never had one.
    expect(await _ruleIds(db), {10, 11});
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    final pragma = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(pragma.data.values.single, 1);
  });

  group('with foreign keys enforced', () {
    late Database db;

    setUp(() async {
      db = Database(NativeDatabase.memory());
      await db.profiles.put(_profile(1).toCompanion());
      await db.rulesDao.putGlobalRule(_rule(10));
      await db.rulesDao.putProfileAddedRule(1, _rule(11));
    });

    tearDown(() => db.close());

    test('a link to a missing profile is rejected', () async {
      await expectLater(
        _insertLink(db, missingProfileLink),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'deleting a profile drops its links and the rules only it used',
      () async {
        await db.deleteProfile(1);

        expect(await _linkIds(db), {globalLink.key});
        expect(await _ruleIds(db), {10});
      },
    );

    for (final isOverride in [true, false]) {
      test('restore (isOverride: $isOverride) drops orphans from a backup '
          'instead of failing', () async {
        await db.restore(
          [_profile(1), _profile(2)],
          const [],
          [_rule(10), _rule(11), _rule(12)],
          [
            globalLink,
            profileLink,
            missingProfileLink,
            secondProfileLink,
            missingRuleLink,
          ],
          isOverride: isOverride,
        );

        expect(await _linkIds(db), {
          globalLink.key,
          profileLink.key,
          secondProfileLink.key,
        });
        expect(await _ruleIds(db), {10, 11, 12});
      });
    }
  });
}
