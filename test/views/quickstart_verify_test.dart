import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/quickstart_verification.dart';
import 'package:fl_clash/views/dashboard/widgets/quickstart_verify.dart';
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
  theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark()),
  home: Scaffold(body: child),
);

QuickStartVerifyCard _card(
  QuickStartVerifyStatus status, {
  VoidCallback? onRetry,
  VoidCallback? onUseDifferent,
}) => QuickStartVerifyCard(
  status: status,
  onRetry: onRetry ?? () {},
  onUseDifferent: onUseDifferent ?? () {},
);

void main() {
  testWidgets('idle renders nothing', (tester) async {
    await tester.pumpWidget(_host(_card(QuickStartVerifyStatus.idle)));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CommonCard), findsNothing);
  });

  testWidgets('verifying shows a spinner and the checking text', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_card(QuickStartVerifyStatus.verifying)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(appLocalizations.quickStartVerifying), findsOneWidget);
  });

  testWidgets('verified shows the verified label, no error', (tester) async {
    await tester.pumpWidget(_host(_card(QuickStartVerifyStatus.verified)));
    expect(find.text(appLocalizations.quickStartVerified), findsOneWidget);
    expect(find.text(appLocalizations.quickStartFailedTitle), findsNothing);
  });

  testWidgets('failure shows the fail screen and both CTAs fire', (
    tester,
  ) async {
    var retried = false;
    var different = false;
    await tester.pumpWidget(
      _host(
        _card(
          QuickStartVerifyStatus.failed,
          onRetry: () => retried = true,
          onUseDifferent: () => different = true,
        ),
      ),
    );
    expect(find.text(appLocalizations.quickStartFailedTitle), findsOneWidget);
    expect(find.text(appLocalizations.quickStartFailedBody), findsOneWidget);

    await tester.tap(find.text(appLocalizations.quickStartTryAgain));
    await tester.tap(find.text(appLocalizations.quickStartUseDifferent));
    expect(retried, isTrue);
    expect(different, isTrue);
  });
}
