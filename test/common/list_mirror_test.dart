import 'package:fl_clash/common/list_mirror.dart';
import 'package:fl_clash/common/function.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _State {
  final List<int> values;

  const _State(this.values);
}

void main() {
  setUp(() {
    throttler.cancel(FunctionTag.logs);
    throttler.cancel(FunctionTag.requests);
  });

  tearDown(() {
    throttler.cancel(FunctionTag.logs);
    throttler.cancel(FunctionTag.requests);
  });

  testWidgets('updates mirrored list after throttle and post-frame', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final notifier = ValueNotifier(const _State([]));

    scheduleThrottledListMirrorUpdate<_State, List<int>>(
      tag: FunctionTag.logs,
      mounted: () => true,
      source: () => const [1, 2],
      notifier: notifier,
      currentList: (state) => state.values,
      updateList: (_, values) => _State(values),
      equals: listEquals,
      duration: const Duration(milliseconds: 1),
    );

    await tester.pump(const Duration(milliseconds: 2));
    tester.binding.scheduleFrame();
    await tester.pump();

    expect(notifier.value.values, [1, 2]);
  });

  testWidgets('skips update when unmounted before post-frame', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final notifier = ValueNotifier(const _State([]));
    var mounted = true;

    scheduleThrottledListMirrorUpdate<_State, List<int>>(
      tag: FunctionTag.requests,
      mounted: () => mounted,
      source: () => const [1],
      notifier: notifier,
      currentList: (state) => state.values,
      updateList: (_, values) => _State(values),
      equals: listEquals,
      duration: const Duration(milliseconds: 1),
    );
    mounted = false;

    await tester.pump(const Duration(milliseconds: 2));
    tester.binding.scheduleFrame();
    await tester.pump();

    expect(notifier.value.values, isEmpty);
  });

  testWidgets('resolves source at fire time so the newest list in a window '
      'wins', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final notifier = ValueNotifier(const _State([]));
    var current = const [1, 2];

    void schedule() {
      scheduleThrottledListMirrorUpdate<_State, List<int>>(
        tag: FunctionTag.logs,
        mounted: () => true,
        source: () => current,
        notifier: notifier,
        currentList: (state) => state.values,
        updateList: (_, values) => _State(values),
        equals: listEquals,
        duration: const Duration(milliseconds: 5),
      );
    }

    schedule();
    current = const [3, 4];
    schedule();

    await tester.pump(const Duration(milliseconds: 6));
    tester.binding.scheduleFrame();
    await tester.pump();

    expect(notifier.value.values, [3, 4]);
  });
}
