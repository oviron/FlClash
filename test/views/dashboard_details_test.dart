import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the details toggle reveals the customizable grid', (
    tester,
  ) async {
    final open = ValueNotifier(false);
    addTearDown(open.dispose);
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
          body: DashboardDetailsSection(
            openNotifier: open,
            grid: const Text('GRID'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    AnimatedCrossFade fade() =>
        tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
    expect(fade().crossFadeState, CrossFadeState.showFirst);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(open.value, isTrue);
    expect(fade().crossFadeState, CrossFadeState.showSecond);
    expect(find.text('GRID'), findsOneWidget);
  });
}
