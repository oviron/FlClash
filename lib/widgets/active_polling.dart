import 'dart:async';

import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/widgets.dart';

// Polls on a timer while the app is in the foreground and the page is the
// visible tab. A timer, not a post-frame callback: a poll that changes
// nothing draws no frame, and a chain waiting on one stalls.
mixin ActivePollingMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _timer;
  bool _isForeground = true;
  bool _isPageActive = true;
  bool _isPolling = false;
  int _generation = 0;

  Duration get pollInterval;

  Future<void> poll();

  bool get _canPoll => mounted && _isForeground && _isPageActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _isForeground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPageActive = PageActivityScope.isActiveOf(context);
    if (isPageActive == _isPageActive) return;
    _isPageActive = isPageActive;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isForeground = state == AppLifecycleState.resumed;
    if (isForeground == _isForeground) return;
    _isForeground = isForeground;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  void _sync() => _canPoll ? _start() : _stop();

  void _start() {
    if (_isPolling) return;
    _isPolling = true;
    unawaited(_run(++_generation));
  }

  void _stop() {
    _isPolling = false;
    _generation++;
    _timer?.cancel();
    _timer = null;
  }

  bool _isCurrent(int generation) =>
      _isPolling && generation == _generation && _canPoll;

  Future<void> _run(int generation) async {
    try {
      await poll();
    } catch (e) {
      commonPrint.log(
        '$runtimeType poll failed: $e',
        logLevel: LogLevel.warning,
      );
    } finally {
      if (_isCurrent(generation)) {
        _timer = Timer(pollInterval, () {
          if (_isCurrent(generation)) unawaited(_run(generation));
        });
      }
    }
  }
}
