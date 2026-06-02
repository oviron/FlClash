import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// Drives VPN-route bookkeeping (local IP / check-ip) on connectivity changes.
// The network-rules snapshot is no longer produced here: the resident service
// computes it natively and pushes it via NetworkRulesBridge.
class ConnectivityManager extends StatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;

  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    required this.child,
  });

  @override
  State<ConnectivityManager> createState() => _ConnectivityManagerState();
}

class _ConnectivityManagerState extends State<ConnectivityManager> {
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((results) {
      widget.onConnectivityChanged?.call(results);
    });
  }

  @override
  void dispose() {
    unawaited(subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
