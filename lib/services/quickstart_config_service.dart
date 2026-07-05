import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/common/xray_json.dart';
import 'package:fl_clash/services/routing_model.dart';

/// The kind of artifact a user pasted, decided without any network call.
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

/// The full-tunnel exit group every quick-start profile routes through.
const quickStartExitGroup = 'PROXY';

/// Wrap parsed proxies into the node envelope: inline `proxies:` and a single
/// url-test [quickStartExitGroup] group that auto-picks the fastest node. Routing
/// is NOT assembled here; [applyQuickStartRouting] adds it through the shared
/// writer. Intentionally emits no `dns:` block so the app's hardened model
/// defaults apply (see docs/onboarding.md).
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

/// Applies the full-tunnel routing overlay onto an encoded [envelopeYaml] through
/// the same [RoutingModel] writer that powers the edit path (docs II.9): one
/// mechanism, no separate assembly, so paste-and-go and edit never drift.
String applyQuickStartRouting(String envelopeYaml) => const RoutingModel(
  exitGroup: quickStartExitGroup,
  lists: [],
  scenarios: [],
  apps: [],
  defaultRoute: toVpn,
).toYaml(envelopeYaml);

/// Converts a non-clash artifact (share link, base64 v2ray list, xray-JSON) into
/// hardened quick-start config bytes, or null when it yields no proxies. One
/// owner for the import switch, shared by first-run paste and refresh conversion.
Future<Uint8List?> artifactToConfigBytes(String text, ArtifactKind kind) async {
  final proxies = switch (kind) {
    ArtifactKind.shareLink => [
      parseShareLink(text.trim()),
    ].whereType<Map<String, dynamic>>().toList(),
    ArtifactKind.base64List => parseSubscriptionContent(text).proxies,
    ArtifactKind.xrayJson => parseXrayJson(text),
    _ => <Map<String, dynamic>>[],
  };
  if (proxies.isEmpty) return null;
  final envelope = await encodeYamlTask(synthesizeConfig(proxies));
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
