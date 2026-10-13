import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/active_chain_strip.dart';
import 'package:fl_clash/views/proxies/group_mode_bar.dart';
import 'package:fl_clash/widgets/latency_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _outer = Group(
  name: 'Outer',
  type: GroupType.URLTest,
  now: 'Inner',
  testUrl: 'https://outer.test/204',
);
const _inner = Group(
  name: 'Inner',
  type: GroupType.URLTest,
  now: 'node',
  testUrl: 'https://inner.test/204',
);

// The core stores a nested group's node under the url of the group that
// picked it; a badge reading the outer group's url shows nothing.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupsProvider.overrideWithBuild((_, _) => [_outer, _inner]),
          currentGroupsStateProvider.overrideWithValue(
            const GroupsState(value: [_outer, _inner]),
          ),
          selectedMapProvider.overrideWithValue(const {}),
          delayDataSourceProvider.overrideWithBuild(
            (_, _) => {
              'https://inner.test/204': {'node': 120},
            },
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the mode bar shows the nested node as measured', (tester) async {
    await pump(tester, const GroupModeBarView(groupName: 'Outer'));
    expect(tester.widget<GroupModeBar>(find.byType(GroupModeBar)).delay, 120);
  });

  testWidgets('the active chain shows the nested node as measured', (
    tester,
  ) async {
    await pump(tester, const ActiveChainStrip());
    expect(tester.widget<LatencyBadge>(find.byType(LatencyBadge)).delay, 120);
  });
}
