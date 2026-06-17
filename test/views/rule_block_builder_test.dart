import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/views/profiles/rule_block_builder.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.delegate.supportedLocales,
  locale: const Locale('en'),
  home: child,
);

void main() {
  group('clauseActions', () {
    test('excludes logical operators, SUB-RULE and MATCH', () {
      expect(clauseActions, isNot(contains(RuleAction.AND)));
      expect(clauseActions, isNot(contains(RuleAction.OR)));
      expect(clauseActions, isNot(contains(RuleAction.NOT)));
      expect(clauseActions, isNot(contains(RuleAction.SUB_RULE)));
      expect(clauseActions, isNot(contains(RuleAction.MATCH)));
      expect(clauseActions, contains(RuleAction.DOMAIN));
      expect(clauseActions, contains(RuleAction.NETWORK));
    });
  });

  testWidgets('AND with two clauses + target yields correct serialize()', (
    tester,
  ) async {
    // Tall viewport so the whole builder (incl. confirm) fits without scrolling.
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const initial = LogicalRule(
      op: RuleAction.AND,
      clauses: [
        LogicalClause(action: RuleAction.DOMAIN, params: 'a.com'),
        LogicalClause(action: RuleAction.NETWORK, params: 'UDP'),
      ],
      target: 'REJECT',
    );
    LogicalRule? result;
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      _host(
        Navigator(
          key: key,
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => const SizedBox()),
        ),
      ),
    );
    unawaited(
      key.currentState!
          .push<LogicalRule>(
            MaterialPageRoute(
              builder: (_) => RuleBlockBuilder(
                type: SheetType.page,
                initial: initial,
                pickTarget: (current) async => current,
              ),
            ),
          )
          .then((value) => result = value),
    );
    await tester.pumpAndSettle();

    final en = AppLocalizations();
    // Live preview equals serialize() of the seeded rule.
    expect(find.text(initial.serialize()), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, en.confirm));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.serialize(), 'AND,((DOMAIN,a.com),(NETWORK,UDP)),REJECT');
    expect(result!.serialize(), initial.serialize());
  });

  testWidgets('NOT enforces a single clause (collapses extra clauses)', (
    tester,
  ) async {
    const initial = LogicalRule(
      op: RuleAction.AND,
      clauses: [
        LogicalClause(action: RuleAction.DOMAIN, params: 'a.com'),
        LogicalClause(action: RuleAction.NETWORK, params: 'UDP'),
      ],
      target: 'REJECT',
    );
    await tester.pumpWidget(
      _host(
        Scaffold(
          body: RuleBlockBuilder(
            type: SheetType.page,
            initial: initial,
            pickTarget: (current) async => current,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final en = AppLocalizations();
    await tester.tap(find.text(en.ruleOpNot));
    await tester.pumpAndSettle();

    // Preview reflects a single-clause NOT (the second clause was dropped).
    expect(find.text('NOT,((DOMAIN,a.com)),REJECT'), findsOneWidget);
  });

  testWidgets('live preview updates as params are edited', (tester) async {
    const initial = LogicalRule(
      op: RuleAction.AND,
      clauses: [LogicalClause(action: RuleAction.DOMAIN, params: 'a.com')],
      target: 'DIRECT',
    );
    await tester.pumpWidget(
      _host(
        Scaffold(
          body: RuleBlockBuilder(
            type: SheetType.page,
            initial: initial,
            pickTarget: (current) async => current,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AND,((DOMAIN,a.com)),DIRECT'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'b.com');
    await tester.pumpAndSettle();

    expect(find.text('AND,((DOMAIN,b.com)),DIRECT'), findsOneWidget);
  });
}
