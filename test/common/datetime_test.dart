import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/datetime.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  test('expiresInDesc clamps a sub-hour remainder to 1 hour, never 0', () {
    final soon = DateTime.now().add(const Duration(minutes: 30));
    expect(soon.expiresInDesc, appLocalizations.subHoursLeft(1));
    expect(soon.expiresInDesc, isNot(appLocalizations.subHoursLeft(0)));
  });

  test('expiresInDesc reports whole days when over a day remains', () {
    final later = DateTime.now().add(const Duration(days: 3, hours: 2));
    expect(later.expiresInDesc, appLocalizations.subDaysLeft(3));
  });

  test('expiresInDesc is the Expired label once past', () {
    final past = DateTime.now().subtract(const Duration(minutes: 5));
    expect(past.expiresInDesc, appLocalizations.subExpired);
  });
}
