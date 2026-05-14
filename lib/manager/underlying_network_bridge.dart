import 'dart:async';

import 'package:flutter/services.dart';

// Push channel for underlying Wi-Fi/cellular flips that connectivity_plus
// misses when the VPN is the default network.
class UnderlyingNetworkBridge {
  UnderlyingNetworkBridge._() {
    _channel.setMethodCallHandler(_onCall);
  }

  static final UnderlyingNetworkBridge instance = UnderlyingNetworkBridge._();

  static const _channel = MethodChannel(
    'com.follow.clash/underlying_network',
  );

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  Future<dynamic> _onCall(MethodCall call) async {
    if (call.method == 'underlyingChanged') {
      final reason = call.arguments is String
          ? call.arguments as String
          : 'unknown';
      _controller.add(reason);
    }
    return null;
  }
}
