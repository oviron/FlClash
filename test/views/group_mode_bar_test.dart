import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/views/proxies/group_mode_bar.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    List<String> chain = const ['vless-qde', 'qde'],
    bool pinned = false,
    VoidCallback? onAuto,
    int? delay,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: GroupModeBar(
            chain: chain,
            pinned: pinned,
            onAuto: onAuto ?? () {},
            delay: delay,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('auto mode names what the group picked, with no release', (
    tester,
  ) async {
    await pumpBar(tester);

    expect(find.text('Auto'), findsOneWidget);
    expect(find.textContaining('vless-qde'), findsOneWidget);
    expect(find.textContaining('qde'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Auto'), findsNothing);
  });

  testWidgets('a pinned node is named and released with one tap', (
    tester,
  ) async {
    var released = 0;
    await pumpBar(tester, pinned: true, onAuto: () => released++);

    expect(find.text('Pinned'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Auto'));
    await tester.pumpAndSettle();

    expect(released, 1);
  });

  testWidgets('a group that picked nothing says so instead of going blank', (
    tester,
  ) async {
    await pumpBar(tester, chain: const []);

    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('the delay of the leaf rides along', (tester) async {
    await pumpBar(tester, delay: 120);

    expect(find.byType(LatencyBadge), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
  });
}
