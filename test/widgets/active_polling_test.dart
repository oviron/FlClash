import 'dart:async';

import 'package:fl_clash/widgets/active_polling.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _interval = Duration(milliseconds: 50);

class _Poller extends StatefulWidget {
  const _Poller(this.onPoll);

  final Future<void> Function() onPoll;

  @override
  State<_Poller> createState() => _PollerState();
}

class _PollerState extends State<_Poller>
    with WidgetsBindingObserver, ActivePollingMixin<_Poller> {
  @override
  Duration get pollInterval => _interval;

  @override
  Future<void> poll() => widget.onPoll();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late int polls;

  Future<void> onPoll() async => polls++;

  setUp(() => polls = 0);

  Widget host({Future<void> Function()? poll}) => _Poller(poll ?? onPoll);

  // binding.delayed advances time without drawing a frame.
  Future<void> wait(WidgetTester tester, int intervals) =>
      tester.binding.delayed(_interval * intervals);

  testWidgets('keeps polling when nothing redraws the page', (tester) async {
    await tester.pumpWidget(host());
    expect(polls, 1);
    await wait(tester, 4);
    expect(polls, 5);
  });

  testWidgets('a pause and resume during a poll runs no second poll', (
    tester,
  ) async {
    var running = 0;
    var overlapped = false;
    final pending = <Completer<void>>[];
    await tester.pumpWidget(
      host(
        poll: () async {
          polls++;
          running++;
          overlapped |= running > 1;
          final done = Completer<void>();
          pending.add(done);
          await done.future;
          running--;
        },
      ),
    );
    expect(polls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await wait(tester, 2);
    expect(polls, 1);

    pending.removeAt(0).complete();
    await wait(tester, 1);
    expect(polls, 2);
    expect(overlapped, isFalse);
  });

  testWidgets('pauses in the background and resumes', (tester) async {
    await tester.pumpWidget(host());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await wait(tester, 4);
    expect(polls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await wait(tester, 1);
    expect(polls, 3);
  });

  testWidgets('a failed poll does not end the polling', (tester) async {
    await tester.pumpWidget(
      host(
        poll: () async {
          polls++;
          throw StateError('core not ready');
        },
      ),
    );
    await wait(tester, 2);
    expect(polls, 3);
  });

  testWidgets('stops when the page is gone', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpWidget(const SizedBox());
    await wait(tester, 4);
    expect(polls, 1);
  });
}
