import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:fl_clash/ingest/synthesize.dart';
import 'package:fl_clash/services/routing_model.dart';

// Subscription display name + provider key, derived without a second fetch:
// profile-title (plain or `base64:`) -> Content-Disposition filename -> URL host
// -> 'sub'. Also the per-remark slug prefix, so it must be key-safe; normalized
// per candidate so a title with no letter/digit (emoji, separator) falls through
// instead of collapsing everything to 'sub'.
String deriveSubscriptionName({
  String? profileTitle,
  String? dispositionFilename,
  required String url,
}) {
  final candidates = [
    _decodeProfileTitle(profileTitle),
    dispositionFilename,
    Uri.tryParse(url)?.host,
  ];
  for (final raw in candidates) {
    final key = normalizeSubKey(raw ?? '');
    if (key != null) return key;
  }
  return 'sub';
}

String? _decodeProfileTitle(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (!v.startsWith('base64:')) return v;
  try {
    return utf8.decode(base64.decode(base64.normalize(v.substring(7).trim())));
  } catch (_) {
    return null; // malformed base64: marker -> fall through to filename/host
  }
}

// Case-preserving key: letters/digits kept, every other run -> '-', edge '-'
// trimmed; null when nothing usable remains. Distinct from _slug (lowercases);
// RegExp.escape at xray_json covers residual punctuation in the slug filter.
String? normalizeSubKey(String raw) {
  final s = raw
      .trim()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return s.isEmpty ? null : s;
}

// Full-tunnel routing overlay via the same RoutingModel writer as the edit path
// (docs II.9), so paste-and-go and edit never drift.
String applyQuickStartRouting(String envelopeYaml) => const RoutingModel(
  exitGroup: quickStartExitGroup,
  lists: [],
  scenarios: [],
  apps: [],
  defaultRoute: toVpn,
).toYaml(envelopeYaml);

// Converts a non-clash artifact to hardened config bytes, or null when it yields
// no proxies. One owner for the import switch: normalize decides the format,
// synthesize builds the envelope.
Future<Uint8List?> artifactToConfigBytes(String text) async {
  final normalized = normalize(text);
  if (normalized.proxies.isEmpty) return null;
  final envelope = await encodeYamlTask(synthesize(normalized));
  return Uint8List.fromList(utf8.encode(applyQuickStartRouting(envelope)));
}
