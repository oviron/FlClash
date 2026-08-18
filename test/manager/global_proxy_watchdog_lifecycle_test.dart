import 'package:fl_clash/manager/global_proxy_watchdog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('watchdog probe timer follows the app lifecycle', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GlobalProxyWatchdogManager(child: SizedBox())),
    );
    final state =
        tester.state(find.byType(GlobalProxyWatchdogManager)) as dynamic;

    expect(state.isTicking, isTrue, reason: 'ticks while resumed');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(
      state.isTicking,
      isFalse,
      reason: 'a backgrounded app must not probe the network every 30s',
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(state.isTicking, isTrue, reason: 'resumes with the app');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(state.isTicking, isFalse);

    // Unmount so no periodic timer leaks out of the test.
    await tester.pumpWidget(const SizedBox());
  });
}
