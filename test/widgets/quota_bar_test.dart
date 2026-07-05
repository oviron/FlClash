import 'package:fl_clash/common/color.dart';
import 'package:fl_clash/widgets/quota_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark()),
  home: Scaffold(body: Center(child: child)),
);

LinearProgressIndicator _bar(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

void main() {
  const scheme = ColorScheme.dark();

  testWidgets('primary color below warn threshold', (tester) async {
    await tester.pumpWidget(_host(const QuotaBar(value: 0.3)));
    expect(_bar(tester).color, scheme.primary);
    expect(_bar(tester).value, 0.3);
  });

  testWidgets('warning color past threshold', (tester) async {
    await tester.pumpWidget(_host(const QuotaBar(value: 0.7)));
    expect(_bar(tester).color, scheme.warning);
  });

  testWidgets('error color and clamped bar when over limit', (tester) async {
    await tester.pumpWidget(_host(const QuotaBar(value: 1.3)));
    expect(_bar(tester).color, scheme.error);
    expect(_bar(tester).value, 1.0);
  });

  testWidgets('defends against NaN / Infinity / negative from a panel', (
    tester,
  ) async {
    for (final bad in [double.nan, double.infinity, -0.5]) {
      await tester.pumpWidget(_host(QuotaBar(value: bad)));
      expect(_bar(tester).value, 0.0);
      expect(_bar(tester).color, scheme.primary);
    }
  });

  testWidgets('renders the optional caption', (tester) async {
    await tester.pumpWidget(
      _host(const QuotaBar(value: 0.5, label: '5 / 50 GB')),
    );
    expect(find.text('5 / 50 GB'), findsOneWidget);
  });
}
