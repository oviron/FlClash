import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:fl_clash/ingest/synthesize.dart';
import 'package:fl_clash/services/routing_model.dart';

// The kind of artifact a user pasted, decided without any network call.
enum ArtifactKind {
  clashYaml,
  subscriptionUrl,
  shareLink,
  base64List,
  xrayJson,
  unknown,
}

ArtifactKind classifyArtifact(String text) {
  final t = text.trim();
  if (t.isEmpty) return ArtifactKind.unknown;

  final schemeIdx = t.indexOf('://');
  if (schemeIdx > 0) {
    final scheme = t.substring(0, schemeIdx).toLowerCase();
    if (shareLinkSchemes.contains(scheme)) return ArtifactKind.shareLink;
    if (scheme == 'http' || scheme == 'https') {
      return ArtifactKind.subscriptionUrl;
    }
  }

  if (RegExp(r'(^|\n)\s*proxies\s*:').hasMatch(t) ||
      t.contains('proxy-groups:')) {
    return ArtifactKind.clashYaml;
  }

  // xray-JSON (Happ subscription): a top-level list of profiles carrying
  // `outbounds`. Distinct from clash-YAML (a `proxies` map) and SIP008.
  if (t.startsWith('[')) {
    try {
      final j = jsonDecode(t);
      if (j is List && j.any((e) => e is Map && e.containsKey('outbounds'))) {
        return ArtifactKind.xrayJson;
      }
    } catch (_) {}
  }

  final decoded = decodeBase64Text(t);
  if (decoded != null &&
      shareLinkSchemes.any((s) => decoded.contains('$s://'))) {
    return ArtifactKind.base64List;
  }

  return ArtifactKind.unknown;
}

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
