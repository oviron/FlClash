import 'dart:async';

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
  Timer? _connectionsPoll;
  final Set<String> _seenIds = <String>{};

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
        _connectionsPoll ??= Timer.periodic(
          const Duration(seconds: 1),
          (_) => _pollConnections(),
        );
      } else {
        _connectionsPoll?.cancel();
        _connectionsPoll = null;
        _seenIds.clear();
      }
    }, fireImmediately: true);
  }

  Future<void> _pollConnections() async {
    final trackers = await coreController.getConnections();
    for (final t in trackers) {
      if (_seenIds.add(t.id)) {
        ref.read(requestsProvider.notifier).addRequest(t);
      }
    }
  }

  @override
  Future<void> dispose() async {
    coreEventManager.removeListener(this);
    _connectionsPoll?.cancel();
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

  // Health-check probes (URLTest / Fallback groups against generate_204)
  // storm the screen during network handovers when many proxies time out
  // or get aborted by the OS dropping the previous interface. The failures
  // are routine: still recorded in the Logs view for debugging, but not
  // worth a snackbar each.
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
