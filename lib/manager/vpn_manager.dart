import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/manager/effects/vpn_reestablish_effect.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  // VpnOptions (per-app ACL, TUN, ipv6…) are baked into the VpnService at
  // establish and can't be hot-reloaded — applying them means re-establishing
  // the tunnel, which drops live connections. Debounce to batch edit bursts.
  static const _window = Duration(seconds: 2);

  Timer? _debounce;
  bool _reestablishing = false;
  bool _forceReestablish = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(vpnStateProvider, (prev, next) {
      if (prev != next) _schedule();
    });
    ref.listenManual(byeDpiSettingsProvider.select((state) => state.enabled), (
      prev,
      next,
    ) {
      if (shouldReestablishVpnForByeDpiToggle(
        isStarted: ref.read(isStartProvider),
        previousEnabled: prev,
        nextEnabled: next,
      )) {
        _schedule(force: true);
      }
    });
  }

  void _schedule({bool force = false}) {
    if (!ref.read(isStartProvider)) return;
    _forceReestablish |= force;
    _debounce?.cancel();
    _debounce = Timer(_window, _reestablish);
  }

  bool get _dirty => shouldRunVpnReestablish(
    isStarted: ref.read(isStartProvider),
    forceReestablish: _forceReestablish,
    currentVpnState: ref.read(vpnStateProvider),
    lastVpnState: globalState.lastVpnState,
    isReestablishing: false,
  );

  Future<void> _reestablish() async {
    if (_reestablishing || !_dirty) return;
    _reestablishing = true;
    _forceReestablish = false;
    try {
      globalState.showNotifier(appLocalizations.vpnConfigChangeDetected);
      await globalState.handleStop();
      await appController.updateStatus(true);
    } finally {
      _reestablishing = false;
    }
    // A change that landed mid-reconnect leaves us dirty — apply it next.
    if (_dirty) _schedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
