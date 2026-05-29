import 'dart:async';

import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Applies ByeDPI changes to the live engines without a manual restart: core =
// mihomo config reload (proxy/rules/sniffer), engine = byedpi runtime restart
// (port/args/--hosts). VPN re-establish (per-app ACL) is VpnManager's job.
class ByeDpiReconciler extends ConsumerStatefulWidget {
  final Widget child;

  const ByeDpiReconciler({super.key, required this.child});

  @override
  ConsumerState<ByeDpiReconciler> createState() => _ByeDpiReconcilerState();
}

class _ByeDpiReconcilerState extends ConsumerState<ByeDpiReconciler> {
  static const _window = Duration(milliseconds: 400);

  Timer? _debounce;
  bool _pendingCore = false;
  bool _pendingEngine = false;
  bool _flushing = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(byeDpiSettingsProvider, _onSettings);
    ref.listenManual(byeDpiCoreRevisionProvider, (prev, next) {
      if (prev != next) _request(core: true, engine: false);
    });
    ref.listenManual(byeDpiEngineRevisionProvider, (prev, next) {
      if (prev != next) _request(core: false, engine: true);
    });
  }

  void _onSettings(ByeDpiSettings? prev, ByeDpiSettings next) {
    if (prev == null) return;
    final core =
        prev.enabled != next.enabled ||
        prev.mode != next.mode ||
        prev.fallbackEnabled != next.fallbackEnabled ||
        prev.fallbackGroup != next.fallbackGroup ||
        prev.port != next.port;
    final engine =
        prev.enabled != next.enabled ||
        prev.port != next.port ||
        prev.preset != next.preset ||
        prev.cliArgs != next.cliArgs;
    if (core || engine) _request(core: core, engine: engine);
  }

  void _request({required bool core, required bool engine}) {
    // setupState reads host-list/exclude from disk and isn't reactive to file
    // writes — drop it so the next apply (live or on VPN start) reads fresh.
    if (core) ref.invalidate(setupStateProvider);
    if (!appController.isStart) return;
    _pendingCore |= core;
    _pendingEngine |= engine;
    _debounce?.cancel();
    _debounce = Timer(_window, _flush);
  }

  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;
    final core = _pendingCore;
    final engine = _pendingEngine;
    _pendingCore = false;
    _pendingEngine = false;
    try {
      // Engine before core: a port change must have byedpi listening on the new
      // port before mihomo routes there.
      if (engine) await service?.restartByeDpi();
      if (core) appController.applyProfileDebounce(silence: true);
    } finally {
      _flushing = false;
    }
    // Flags raised mid-flush (e.g. during the engine restart) — apply them next.
    if (_pendingCore || _pendingEngine) _debounce = Timer(_window, _flush);
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
