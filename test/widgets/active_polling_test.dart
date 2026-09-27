import 'package:fl_clash/widgets/active_polling.dart';
import 'package:fl_clash/widgets/inherited.dart';
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

  Widget host({bool isActive = true, Future<void> Function()? poll}) =>
      PageActivityScope(isActive: isActive, child: _Poller(poll ?? onPoll));

  // binding.delayed advances time without drawing a frame.
  Future<void> wait(WidgetTester tester, int intervals) =>
      tester.binding.delayed(_interval * intervals);

  testWidgets('keeps polling when nothing redraws the page', (tester) async {
    await tester.pumpWidget(host());
    expect(polls, 1);
    await wait(tester, 4);
    expect(polls, 5);
  });

  testWidgets('polls only while its tab is the visible one', (tester) async {
    await tester.pumpWidget(host(isActive: false));
    await wait(tester, 4);
    expect(polls, 0);

    await tester.pumpWidget(host());
    await wait(tester, 2);
    expect(polls, 3);

    await tester.pumpWidget(host(isActive: false));
    await wait(tester, 4);
    expect(polls, 3);
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
