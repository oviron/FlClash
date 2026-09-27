import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// These labels replaced dynamic Intl.message('${e.name}...') lookups that no
// static analysis could see; this test is the anchor that keeps their arb keys
// alive through any future l10n cleanup.
void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  test('every enum label resolves to a non-empty localized string', () {
    final labels = <String>[
      for (final v in Mode.values) v.label,
      for (final v in PageLabel.values) v.title,
      for (final v in ProxiesType.values) v.label,
      for (final v in ProxyCardType.values) v.label,
      for (final v in RouteMode.values) v.label,
      for (final v in RestoreStrategy.values) v.label,
      for (final v in FindProcessMode.values) v.label,
      for (final v in DynamicSchemeVariant.values) v.label,
      for (final l in AppLocalizations.delegate.supportedLocales)
        localeDisplayName(l.toString()),
    ];
    for (final label in labels) {
      expect(label, isNotEmpty);
      expect(label, isNot(contains('Scheme(')), reason: 'raw enum leak');
    }
  });

  test('more-pages carry a description, primary pages do not', () {
    expect(PageLabel.requests.moreDescription, isNotEmpty);
    expect(PageLabel.connections.moreDescription, isNotEmpty);
    expect(PageLabel.logs.moreDescription, isNotEmpty);
    expect(PageLabel.resources.moreDescription, isNotEmpty);
    expect(PageLabel.dashboard.moreDescription, isNull);
  });

  test('an unknown locale code falls back to itself', () {
    expect(localeDisplayName('xx_YY'), 'xx_YY');
  });
}
