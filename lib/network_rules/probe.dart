// Network Rules v1: live network probe.
//
// Asks connectivity_plus what kind of link the device is on right now and,
// for Wi-Fi, asks network_info_plus for the SSID. The two raw signals are
// massaged into a [NetworkSnapshot] that the engine can match against.
//
// Sanitization rules for the SSID, learned the hard way from the Android API:
//   * `null` => null
//   * the literal string `<unknown ssid>` (returned when ACCESS_FINE_LOCATION
//     was denied or location services are off) => null
//   * empty after trim => null
//   * surrounding double quotes (Android wraps SSIDs as `"home"`) => stripped
//   * any whitespace at the edges => trimmed
//
// Failures from getWifiName (permission throws, plugin errors) are caught
// and degraded to `ssid=null` so a probe call never crashes the caller.

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
