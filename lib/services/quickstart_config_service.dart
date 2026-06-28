import 'package:fl_clash/common/share_link.dart';

/// The kind of artifact a user pasted, decided without any network call.
enum ArtifactKind { clashYaml, subscriptionUrl, shareLink, base64List, unknown }

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

  final decoded = decodeBase64Text(t);
  if (decoded != null &&
      shareLinkSchemes.any((s) => decoded.contains('$s://'))) {
    return ArtifactKind.base64List;
  }

  return ArtifactKind.unknown;
}

/// Wrap parsed proxies into a complete, self-contained mihomo config: inline
/// `proxies:`, a single url-test `PROXY` group that auto-picks the fastest
/// node, and a full-tunnel `MATCH,PROXY` rule. Intentionally emits no `dns:`
/// block so the app's hardened model defaults apply (see docs/onboarding.md).
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
        'name': 'PROXY',
        'type': 'url-test',
        'proxies': names,
        'url': 'http://cp.cloudflare.com/generate_204',
        'interval': 300,
        'tolerance': 50,
      },
    ],
    'rules': ['MATCH,PROXY'],
  };
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
