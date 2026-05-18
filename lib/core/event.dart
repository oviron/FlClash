import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

abstract mixin class CoreEventListener {
  void onLog(Log log) {}

  void onCrash(String message) {}

  void onConnections(List<TrackerInfo> trackers) {}
}

class CoreEventManager {
  final _controller = StreamController<CoreEvent>();
  late final StreamSubscription<CoreEvent> _subscription;

  CoreEventManager._() {
    _subscription = _controller.stream.listen((event) {
      for (final CoreEventListener listener in _listeners) {
        switch (event.type) {
          case CoreEventType.log:
            listener.onLog(Log.fromJson(event.data));
            break;
          case CoreEventType.crash:
            listener.onCrash(event.data);
            break;
          case CoreEventType.connections:
            final raw = event.data as Map<String, dynamic>;
            final connections = raw['connections'];
            if (connections is! List) break;
            listener.onConnections(
              connections
                  .whereType<Map<String, dynamic>>()
                  .map(TrackerInfo.fromJson)
                  .toList(),
            );
            break;
        }
      }
    });
  }

  static final CoreEventManager instance = CoreEventManager._();

  final ObserverList<CoreEventListener> _listeners =
      ObserverList<CoreEventListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void sendEvent(CoreEvent event) {
    _controller.add(event);
  }

  void addListener(CoreEventListener listener) {
    _listeners.add(listener);
  }

  void removeListener(CoreEventListener listener) {
    _listeners.remove(listener);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    _listeners.clear();
    await _controller.close();
  }
}

final coreEventManager = CoreEventManager.instance;
