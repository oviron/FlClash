import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/network_rules/probe.dart';
import 'package:flutter/material.dart';

class ConnectivityManager extends StatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;

  /// Fired with a fully-resolved [NetworkSnapshot] (type + sanitized SSID)
  /// once on mount and on every connectivity change. The Network Rules
  /// engine listens here.
  final void Function(NetworkSnapshot snapshot)? onNetworkSnapshot;

  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    this.onNetworkSnapshot,
    required this.child,
  });

  @override
  State<ConnectivityManager> createState() => _ConnectivityManagerState();
}

class _ConnectivityManagerState extends State<ConnectivityManager> {
  late StreamSubscription subscription;
  final NetworkProbe _probe = const NetworkProbe();

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((results) async {
      if (widget.onConnectivityChanged != null) {
        widget.onConnectivityChanged!(results);
      }
      await _emitSnapshot();
    });
    // Fire once on mount so the engine has an initial snapshot to work from.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emitSnapshot();
    });
  }

  Future<void> _emitSnapshot() async {
    final callback = widget.onNetworkSnapshot;
    if (callback == null) return;
    final snap = await _probe.read();
    if (!mounted) return;
    callback(snap);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
