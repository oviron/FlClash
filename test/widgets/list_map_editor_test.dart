import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/list_map_editor.dart';
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

Future<void> _enterDialogText(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
  await tester.pumpAndSettle();
}

void main() {
  group('ListMapEditor.list', () {
    testWidgets('add appends a row and emits the new list', (tester) async {
      List<String>? emitted;
      await tester.pumpWidget(
        _host(
          ListMapEditor.list(
            value: const ['https://9.9.9.9/dns-query'],
            onChanged: (next) => emitted = next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await _enterDialogText(tester, 'tls://dns.google');

      expect(emitted, ['https://9.9.9.9/dns-query', 'tls://dns.google']);
      expect(find.text('tls://dns.google'), findsOneWidget);
    });

    testWidgets('remove drops the row and emits the trimmed list', (
      tester,
    ) async {
      List<String>? emitted;
      await tester.pumpWidget(
        _host(
          ListMapEditor.list(
            value: const ['a.example', 'b.example'],
            onChanged: (next) => emitted = next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(emitted, ['b.example']);
    });

    testWidgets('reorder moves a row to the front and emits it', (
      tester,
    ) async {
      List<String>? emitted;
      await tester.pumpWidget(
        _host(
          ListMapEditor.list(
            value: const ['first', 'second'],
            onChanged: (next) => emitted = next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drive reorder through the callback the ReorderableListView wires up.
      final reorderable = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      reorderable.onReorder(1, 0);
      await tester.pumpAndSettle();

      expect(emitted, ['second', 'first']);
    });

    testWidgets('renders the per-row tag from tagBuilder', (tester) async {
      await tester.pumpWidget(
        _host(
          ListMapEditor.list(
            value: const ['https://9.9.9.9/dns-query'],
            onChanged: (_) {},
            tagBuilder: (v) => v.startsWith('https://') ? 'DoH' : null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('DoH'), findsOneWidget);
    });
  });

  group('ListMapEditor.map', () {
    testWidgets('add key then add value round-trips through onChanged', (
      tester,
    ) async {
      Map<String, List<String>>? emitted;
      await tester.pumpWidget(
        _host(
          ListMapEditor.map(
            value: const {},
            onChanged: (next) => emitted = next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Add a key (creates an empty-value card). Empty map => one Add button.
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await _enterDialogText(tester, '+.ru');
      expect(emitted, {'+.ru': <String>[]});

      // Add a value to that card via its inline Add chip.
      await tester.tap(find.widgetWithText(ActionChip, 'Add'));
      await tester.pumpAndSettle();
      await _enterDialogText(tester, '77.88.8.8');

      expect(emitted, {
        '+.ru': ['77.88.8.8'],
      });
      expect(find.text('77.88.8.8'), findsOneWidget);
    });

    testWidgets('remove value chip emits the entry without it', (tester) async {
      Map<String, List<String>>? emitted;
      await tester.pumpWidget(
        _host(
          ListMapEditor.map(
            value: const {
              '+.ru': ['77.88.8.8', '8.8.8.8'],
            },
            onChanged: (next) => emitted = next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear).first);
      await tester.pumpAndSettle();

      expect(emitted, {
        '+.ru': ['8.8.8.8'],
      });
    });
  });

  group('MapEditorPage adapter', () {
    test('splits comma-separated persisted values', () {
      expect(MapEditorPage.split('77.88.8.8, 8.8.8.8'), [
        '77.88.8.8',
        '8.8.8.8',
      ]);
      expect(MapEditorPage.split(''), <String>[]);
      expect(MapEditorPage.split('1.1.1.1'), ['1.1.1.1']);
    });
  });
}
