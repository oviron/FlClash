import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/views/profiles/app_routing.dart';
import 'package:fl_clash/views/profiles/app_routing_model.dart';
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

/// The IgnorePointer that wraps the step-2 route list (its child is the route
/// Column, not a scaffold-level barrier).
Finder _step2Barrier() =>
    find.byWidgetPredicate((w) => w is IgnorePointer && w.child is Opacity);

void main() {
  testWidgets('step 2 is interactive in-tunnel, disabled when bypassing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AppRoutingPickerSheet(
          type: SheetType.page,
          title: 'YouTube',
          initialInTunnel: true,
          initialTarget: (value: kRoutingDefault, isSubRule: false),
          groupNames: ['VPN', 'Auto'],
          subRuleNames: ['browser-route'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final en = AppLocalizations();
    // Step 2 sections are rendered (in-tunnel start).
    expect(find.text(en.appRoutingSectionFast), findsOneWidget);
    expect(find.text('VPN'), findsOneWidget);
    expect(find.text('browser-route'), findsOneWidget);

    IgnorePointer barrier() => tester.widget<IgnorePointer>(_step2Barrier());
    expect(barrier().ignoring, isFalse);

    await tester.tap(find.text(en.appRoutingBypassDirect).first);
    await tester.pumpAndSettle();

    // Bypass selected: step 2 dims and stops accepting input.
    expect(barrier().ignoring, isTrue);
    final opacity = tester.widget<Opacity>(
      find.descendant(of: _step2Barrier(), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
  });
}
