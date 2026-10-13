import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/active_polling.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  bool _isBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(checkIpProvider, (prev, next) {
      if (prev != next && next.a && next.c) {
        ref.read(networkDetectionProvider.notifier).startCheck();
      }
    });
    ref.listenManual(configProvider, (prev, next) {
      if (prev != next) {
        appController.savePreferencesDebounce();
      }
    });
    ref.listenManual(needUpdateGroupsProvider, (prev, next) {
      if (prev != next) {
        appController.updateGroupsDebounce();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    if (state == AppLifecycleState.paused) {
      _isBackground = true;
    }
    if (state == AppLifecycleState.resumed) {
      final wasBackground = _isBackground;
      _isBackground = false;
      // One-way on purpose: gating the repair on isStartProvider made a wrong
      // value self-confirming, but letting the pull also stop things made it
      // race an in-flight start. Stops come from the service push.
      unawaited(appController.syncRunStateUp());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (wasBackground) {
          appController.clearDelay();
        }
        appController.tryCheckIp();
        if (system.isAndroid) {
          appController.tryStartCore();
          // Pick up a location grant/revoke made in system Settings while we
          // were backgrounded, so the network-rules banner never lies.
          ref.read(locationPermissionProvider.notifier).refresh();
        }
      });
    } else {
      globalState.stopUpdateTasks();
    }
  }

  @override
  void didChangePlatformBrightness() {
    appController.updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return _GroupsPolling(child: widget.child);
  }
}

// Url-test groups re-pick inside the core on every health check. Re-reading
// them while a screen shows the pick keeps the app on the node really in use.
class _GroupsPolling extends ConsumerStatefulWidget {
  final Widget child;

  const _GroupsPolling({required this.child});

  @override
  ConsumerState<_GroupsPolling> createState() => _GroupsPollingState();
}

class _GroupsPollingState extends ConsumerState<_GroupsPolling>
    with WidgetsBindingObserver, ActivePollingMixin<_GroupsPolling> {
  static const _pages = {PageLabel.dashboard, PageLabel.proxies};

  @override
  Duration get pollInterval => const Duration(seconds: 3);

  @override
  Future<void> poll() async {
    if (!_pages.contains(ref.read(currentPageLabelProvider))) return;
    if (!ref.read(isStartProvider) || globalState.delayTests > 0) return;
    await appController.updateGroups();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppEnvManager extends StatelessWidget {
  final Widget child;

  const AppEnvManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      if (globalState.isPre) {
        return Banner(
          message: 'DEBUG',
          location: BannerLocation.topEnd,
          child: child,
        );
      }
    }
    if (globalState.isPre) {
      return Banner(
        message: 'PRE',
        location: BannerLocation.topEnd,
        child: child,
      );
    }
    return child;
  }
}
