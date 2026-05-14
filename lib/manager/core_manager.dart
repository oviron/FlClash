import 'dart:async';
import 'dart:collection';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreManager extends ConsumerStatefulWidget {
  final Widget child;

  const CoreManager({super.key, required this.child});

  @override
  ConsumerState<CoreManager> createState() => _CoreContainerState();
}

class _CoreContainerState extends ConsumerState<CoreManager>
    with CoreEventListener {
  static const _seenIdsCapacity = 10000;
  final LinkedHashSet<String> _seenIds = LinkedHashSet<String>();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    coreEventManager.addListener(this);
    ref.listenManual(
      currentSetupStateProvider.select((state) => state?.profileId),
      (prev, next) {
        if (prev != next) appController.fullSetup();
      },
    );
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) appController.updateConfigDebounce();
    });
    ref.listenManual(appSettingProvider.select((state) => state.openLogs), (
      prev,
      next,
    ) {
      next ? coreController.startLog() : coreController.stopLog();
    }, fireImmediately: true);
    ref.listenManual(coreStatusProvider, (prev, next) {
      if (next == CoreStatus.connected) {
        coreController.subscribeConnections();
      } else {
        coreController.unsubscribeConnections();
        _seenIds.clear();
      }
    }, fireImmediately: true);
  }

  @override
  void onConnections(List<TrackerInfo> trackers) {
    final requests = ref.read(requestsProvider.notifier);
    for (final t in trackers) {
      if (_seenIds.add(t.id)) {
        requests.addRequest(t);
        if (_seenIds.length > _seenIdsCapacity) {
          _seenIds.remove(_seenIds.first);
        }
      }
    }
    super.onConnections(trackers);
  }

  @override
  Future<void> dispose() async {
    coreEventManager.removeListener(this);
    unawaited(coreController.unsubscribeConnections());
    super.dispose();
  }

  @override
  void onLog(Log log) {
    ref.read(logsProvider.notifier).addLog(log);
    if (log.logLevel == LogLevel.error && !_isProbeNoise(log.payload)) {
      globalState.showNotifier(log.payload);
    }
    super.onLog(log);
  }

  // URLTest/Fallback probes storm during handovers; suppress snackbar but
  // keep them in the Logs view.
  bool _isProbeNoise(String payload) {
    return payload.contains('generate_204') ||
        payload.contains('failed to get the second response');
  }

  @override
  Future<void> onCrash(String message) async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      context.showNotifier(message);
    }
    await coreController.shutdown(false);
    super.onCrash(message);
  }
}
