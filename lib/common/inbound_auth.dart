import 'dart:math';

import 'preferences.dart';

const _kInboundAuthUser = 'fl-clash';
const _kInboundAuthAlphabet =
    'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz0123456789';
const _kInboundAuthLength = 24;

String _generateInboundPassword() {
  final r = Random.secure();
  final buf = StringBuffer();
  for (var i = 0; i < _kInboundAuthLength; i++) {
    buf.write(_kInboundAuthAlphabet[r.nextInt(_kInboundAuthAlphabet.length)]);
  }
  return buf.toString();
}

Future<String> _ensureInboundPassword() async {
  final existing = await preferences.getInboundAuth();
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }
  final pwd = _generateInboundPassword();
  await preferences.setInboundAuth(pwd);
  return pwd;
}

// Closes a side-channel: an unauthenticated local SOCKS5/HTTP inbound is
// reachable from any app on the device, even those outside the per-app
// whitelist, and would leak the VPN exit IP.
Future<void> ensureInboundAuth(Map<String, dynamic> config) async {
  final hasInbound =
      ((config['mixed-port'] as num?)?.toInt() ?? 0) > 0 ||
      ((config['port'] as num?)?.toInt() ?? 0) > 0 ||
      ((config['socks-port'] as num?)?.toInt() ?? 0) > 0;
  if (!hasInbound) return;

  final existing = config['authentication'];
  if (existing is Iterable && existing.isNotEmpty) return;

  final pwd = await _ensureInboundPassword();
  config['authentication'] = ['$_kInboundAuthUser:$pwd'];
}
