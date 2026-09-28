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
// A task queued from inside a running one runs inline instead of waiting for itself.
class SerialQueue {
  final Object _zoneKey = Object();
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() task) {
    if (Zone.current[_zoneKey] == true) return task();
    final result = _tail.then(
      (_) => runZoned(task, zoneValues: {_zoneKey: true}),
    );
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
