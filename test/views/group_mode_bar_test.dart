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
    String pinnedName = '',
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
            pinnedName: pinnedName,
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
    expect(
      find.textContaining('vless-qde', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('qde', findRichText: true), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Auto'), findsNothing);
  });

  testWidgets('a pinned node is named and released with one tap', (
    tester,
  ) async {
    var released = 0;
    await pumpBar(
      tester,
      chain: const ['vless-qde', 'qde'],
      pinnedName: 'vless-qde',
      onAuto: () => released++,
    );

    expect(find.text('Pinned'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Auto'));
    await tester.pumpAndSettle();

    expect(released, 1);
  });

  testWidgets('a pin the group has not taken up names both nodes', (
    tester,
  ) async {
    // mihomo skips a pinned node that is not alive yet, so the pin and the node
    // actually carrying the traffic can differ.
    await pumpBar(tester, chain: const ['amsterdam'], pinnedName: 'fujairah');

    expect(find.textContaining('fujairah', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('amsterdam', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a group that picked nothing says so instead of going blank', (
    tester,
  ) async {
    await pumpBar(tester, chain: const []);

    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('—', findRichText: true), findsOneWidget);
  });

  testWidgets('the delay of the leaf rides along', (tester) async {
    await pumpBar(tester, delay: 120);

    expect(find.byType(LatencyBadge), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
  });
}
