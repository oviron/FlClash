// Android quirks the SSID returns: `<unknown ssid>` stub when location is
// missing, and the value is double-quote-wrapped. Strip both before match.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'model.dart';

class NetworkProbe {
  const NetworkProbe();

  Future<NetworkSnapshot> read() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.wifi)) {
      final ssid = await _readWifiSsid();
      return NetworkSnapshot.wifi(ssid: ssid);
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return const NetworkSnapshot.cellular();
    }
    return const NetworkSnapshot.none();
  }

  Future<String?> _readWifiSsid() async {
    String? raw;
    try {
      raw = await NetworkInfo().getWifiName();
    } catch (_) {
      return null;
    }
    return _sanitizeSsid(raw);
  }

  /// Visible for testing. See file-level docstring for the rules.
  static String? sanitizeSsid(String? raw) => _sanitizeSsid(raw);
}

String? _sanitizeSsid(String? raw) {
  if (raw == null) return null;
  if (raw == '<unknown ssid>') return null;
  var value = raw;
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    value = value.substring(1, value.length - 1);
  }
  value = value.trim();
  if (value.isEmpty) return null;
  return value;
}
