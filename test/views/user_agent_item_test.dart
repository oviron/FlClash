import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  String userAgent() => container.read(appSettingProvider).userAgent;

  Future<void> pumpItem(WidgetTester tester, {String userAgent = ''}) async {
    container = ProviderContainer(
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 600)),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(userAgent: userAgent));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: UserAgentItem()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String option) async {
    await tester.tap(find.byType(UserAgentItem));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  test('settings saved before the option existed keep the app UA', () {
    expect(AppSettingProps.fromJson(const {}).userAgent, isEmpty);
  });

  testWidgets('a known User-Agent is picked from the list', (tester) async {
    await pumpItem(tester);

    await choose(tester, 'clash-verge/v2.4.2');

    expect(userAgent(), 'clash-verge/v2.4.2');
  });

  testWidgets('Default goes back to the app User-Agent', (tester) async {
    await pumpItem(tester, userAgent: 'ClashforWindows/0.19.23');

    await choose(tester, 'Default');

    expect(userAgent(), isEmpty);
  });

  testWidgets('a custom User-Agent is typed in', (tester) async {
    await pumpItem(tester);

    await choose(tester, 'Custom');
    await tester.enterText(find.byType(TextFormField), '  MyClient/1.0 ');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(userAgent(), 'MyClient/1.0');
  });

  testWidgets('a custom User-Agent opens with its current value', (
    tester,
  ) async {
    await pumpItem(tester, userAgent: 'MyClient/1.0');

    await choose(tester, 'Custom');

    expect(find.widgetWithText(TextFormField, 'MyClient/1.0'), findsOneWidget);
  });

  testWidgets('a User-Agent with a line break is refused', (tester) async {
    await pumpItem(tester);

    await choose(tester, 'Custom');
    await tester.enterText(find.byType(TextFormField), 'a\r\nX-Evil: 1');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(userAgent(), isEmpty);
  });
}
