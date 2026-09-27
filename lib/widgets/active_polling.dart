import 'dart:async';

import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/widgets.dart';

// Polls on a timer while the app is in the foreground. A timer, not a
// post-frame callback: a poll that changes nothing draws no frame, and a chain
// waiting on one stalls. At most one poll runs at a time.
mixin ActivePollingMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _timer;
  bool _isForeground = true;
  bool _isPolling = false;
  bool _isRunning = false;

  Duration get pollInterval;

  Future<void> poll();

  bool get _canPoll => mounted && _isForeground;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _isForeground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
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
    if (!_isRunning) unawaited(_run());
  }

  void _stop() {
    _isPolling = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _run() async {
    _isRunning = true;
    try {
      await poll();
    } catch (e) {
      commonPrint.log(
        '$runtimeType poll failed: $e',
        logLevel: LogLevel.warning,
      );
    } finally {
      _isRunning = false;
      if (_isPolling && _canPoll) _timer = Timer(pollInterval, _tick);
    }
  }

  void _tick() {
    _timer = null;
    if (_isPolling && _canPoll) unawaited(_run());
  }
}
