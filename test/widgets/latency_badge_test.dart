import 'package:fl_clash/common/color.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/latency_badge.dart';
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
  theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark()),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders ms with the good-tier color', (tester) async {
    await tester.pumpWidget(_host(const LatencyBadge(120)));
    await tester.pumpAndSettle();
    expect(find.text('120 ms'), findsOneWidget);
    final style = tester.widget<Text>(find.text('120 ms')).style!;
    expect(style.color, const ColorScheme.dark().success);
  });

  testWidgets('renders nothing for null', (tester) async {
    await tester.pumpWidget(_host(const LatencyBadge(null)));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('renders the timeout label for <= 0 in error color', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const LatencyBadge(0)));
    await tester.pumpAndSettle();
    final finder = find.text('timeout');
    expect(finder, findsOneWidget);
    expect(
      tester.widget<Text>(finder).style!.color,
      const ColorScheme.dark().error,
    );
  });

  testWidgets('hides the unit when asked', (tester) async {
    await tester.pumpWidget(_host(const LatencyBadge(88, showUnit: false)));
    await tester.pumpAndSettle();
    expect(find.text('88'), findsOneWidget);
  });
}
