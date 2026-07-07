import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/common/xray_json.dart';
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

const quickStartExitGroup = 'PROXY';

// Node envelope only (inline proxies + one auto-fastest PROXY group); routing is
// added by applyQuickStartRouting. No dns block, so hardened DNS defaults apply.
Map<String, dynamic> synthesizeConfig(List<Map<String, dynamic>> proxies) {
  if (proxies.isEmpty) {
    throw ArgumentError('cannot synthesize a config without proxies');
  }
  final named = _ensureUniqueNames(proxies);
  final names = named.map((p) => p['name'] as String).toList();
  return {
    'proxies': named,
    'proxy-groups': [
      {
        'name': quickStartExitGroup,
        'type': 'url-test',
        'proxies': names,
        'url': 'http://cp.cloudflare.com/generate_204',
        'interval': 300,
        'tolerance': 50,
      },
    ],
  };
}

// Happ layout: inline proxies, one url-test group per remark, and a PROXY select
// over them so the user picks a profile (Main / Anti-block / ...) as in Happ.
Map<String, dynamic> synthesizeGroupedConfig(List<XrayGroup> groups) {
  if (groups.isEmpty) {
    throw ArgumentError('cannot synthesize a config without proxies');
  }
  final proxies = <Map<String, dynamic>>[];
  final specs = <Map<String, dynamic>>[];
  final groupNames = <String>[];
  final used = <String>{};
  for (final g in groups) {
    var name = g.remark.trim().isEmpty ? 'Group' : g.remark.trim();
    final base = name;
    var n = 2;
    while (used.contains(name)) {
      name = '$base ($n)';
      n++;
    }
    used.add(name);
    proxies.addAll(g.proxies);
    groupNames.add(name);
    specs.add({
      'name': name,
      'type': 'url-test',
      'proxies': g.proxies.map((p) => p['name'] as String).toList(),
      'url': 'http://cp.cloudflare.com/generate_204',
      'interval': 300,
      'tolerance': 50,
    });
  }
  return {
    'proxies': proxies,
    'proxy-groups': [
      {'name': quickStartExitGroup, 'type': 'select', 'proxies': groupNames},
      ...specs,
    ],
  };
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

// Converts a non-clash artifact (share link, base64 list, xray-JSON) to hardened
// config bytes, or null when it yields no proxies. One owner for the import switch.
Future<Uint8List?> artifactToConfigBytes(String text, ArtifactKind kind) async {
  final Map<String, dynamic> config;
  if (kind == ArtifactKind.xrayJson) {
    // Keep the panel's profile structure (Happ layout: group per remark-profile).
    final groups = parseXrayJsonGroups(text);
    if (groups.isEmpty) return null;
    config = synthesizeGroupedConfig(groups);
  } else {
    final proxies = switch (kind) {
      ArtifactKind.shareLink => [
        parseShareLink(text.trim()),
      ].whereType<Map<String, dynamic>>().toList(),
      ArtifactKind.base64List => parseSubscriptionContent(text).proxies,
      _ => <Map<String, dynamic>>[],
    };
    if (proxies.isEmpty) return null;
    config = synthesizeConfig(proxies);
  }
  final envelope = await encodeYamlTask(config);
  return Uint8List.fromList(utf8.encode(applyQuickStartRouting(envelope)));
}

List<Map<String, dynamic>> _ensureUniqueNames(
  List<Map<String, dynamic>> proxies,
) {
  final used = <String>{};
  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < proxies.length; i++) {
    var base = (proxies[i]['name'] as String?)?.trim() ?? '';
    if (base.isEmpty) base = 'node-${i + 1}';
    var unique = base;
    var n = 2;
    while (used.contains(unique)) {
      unique = '$base-${n++}';
    }
    used.add(unique);
    out.add({...proxies[i], 'name': unique});
  }
  return out;
}
