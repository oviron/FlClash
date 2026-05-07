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

/// If the assembled YAML config exposes any local inbound listener
/// (mixed-port, port, socks-port) without its own `authentication:` block,
/// inject a per-device random credential. The password is generated once
/// and persisted in shared preferences; subsequent runs reuse it so external
/// tools that pinned the value keep working. User-supplied authentication
/// is preserved untouched.
///
/// Closes the class of side-channel attacks where any app on the device
/// (including those outside our per-app whitelist) could connect to
/// 127.0.0.1:7890 as an unauthenticated SOCKS5/HTTP proxy and probe the
/// VPN exit IP.
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
