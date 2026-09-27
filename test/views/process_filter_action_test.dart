import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/connection/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _t(String id, String process) => TrackerInfo(
  id: id,
  upload: 0,
  download: 0,
  start: DateTime(2020),
  metadata: Metadata(process: process),
  chains: const [],
  rule: '',
  rulePayload: '',
);

void main() {
  testWidgets('filter button shows only once an app is known', (tester) async {
    final notifier = ValueNotifier(
      TrackerInfosState(trackerInfos: [_t('a', '')]),
    );
    addTearDown(notifier.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(actions: [buildProcessFilterAction(notifier)]),
        ),
      ),
    );
    expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);

    notifier.value = notifier.value.copyWith(
      trackerInfos: [_t('a', ''), _t('b', 'com.example')],
    );
    await tester.pump();
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
  });
}
