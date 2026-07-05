import 'dart:math';

import 'preferences.dart';

/// The Happ client identity a panel needs to serve its xray-JSON subscription:
/// this UA (some panels gate the format on it) plus a stable device id header.
const happUserAgent = 'Happ/3.6.0';
const happHwidHeader = 'x-hwid';

/// RFC 4122 v4 UUID from 16 secure-random bytes; the device id Happ invents
/// per install; a panel counts it as one device slot.
String generateHwid() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // version 4
  b[8] = (b[8] & 0x3f) | 0x80; // variant 10xx
  final h = [
    for (var i = 0; i < 16; i++) b[i].toRadixString(16).padLeft(2, '0'),
  ].join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

Future<String> ensureHwid() async {
  final existing = await preferences.getHwid();
  if (existing != null && existing.isNotEmpty) return existing;
  final id = generateHwid();
  await preferences.setHwid(id);
  return id;
}

/// Headers that make FlClash look like Happ to a panel: the Happ UA plus the
/// app's device id. Entries already in [base] win, so a panel spec can pin its
/// own UA/x-hwid without being clobbered.
Future<Map<String, String>> happHeaders({Map<String, String>? base}) async {
  final headers = {...?base};
  headers.putIfAbsent('User-Agent', () => happUserAgent);
  if (!headers.containsKey(happHwidHeader)) {
    headers[happHwidHeader] = await ensureHwid();
  }
  return headers;
}
