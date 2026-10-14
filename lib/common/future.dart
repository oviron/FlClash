import 'dart:async';

extension FutureExt<T> on Future<T> {
  Future<T> withTimeout({
    Duration? timeout,
    String? tag,
    FutureOr<T> Function()? onTimeout,
  }) {
    final realTimeout = timeout ?? const Duration(minutes: 3);
    return this.timeout(
      realTimeout,
      onTimeout: () async {
        if (onTimeout != null) {
          return onTimeout();
        } else {
          throw TimeoutException('${tag ?? runtimeType} timeout');
        }
      },
    );
  }
}

extension CompleterExt<T> on Completer<T> {
  void safeCompleter(T value) {
    if (isCompleted) {
      return;
    }
    complete(value);
  }
}

// Runs tasks one at a time in call order, so overlapping awaits cannot reorder them.
// A task queued from inside a running one runs inline instead of waiting for itself;
// a timer it left behind inherits its zone, so the zone names the task, not the queue.
class SerialQueue {
  final Object _zoneKey = Object();
  Future<void> _tail = Future.value();
  Object? _running;

  Future<T> run<T>(Future<T> Function() task) {
    final caller = Zone.current[_zoneKey];
    if (caller != null && identical(caller, _running)) return task();
    final result = _tail.then((_) {
      final token = Object();
      _running = token;
      return runZoned(task, zoneValues: {_zoneKey: token}).whenComplete(() {
        if (identical(_running, token)) _running = null;
      });
    });
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}

// Closed until opened once; work queued behind it runs after, in call order.
class Gate {
  final _opened = Completer<void>();

  bool get isOpen => _opened.isCompleted;

  Future<T> after<T>(Future<T> Function() task) =>
      _opened.future.then((_) => task());

  void open() => _opened.safeCompleter(null);
}
