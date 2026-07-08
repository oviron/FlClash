import 'dart:convert';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/ingest/sip008.dart';
import 'package:fl_clash/ingest/singbox.dart';
import 'package:fl_clash/ingest/xray.dart';

// The single conversion result every content format collapses to. `groups` is
// non-null only for grouped xray-JSON (one url-test group per remark-profile);
// every flat source leaves it null. `skipped` counts recognized-but-unparseable
// share links so a partial loss is never silent.
typedef Normalized = ({
  List<Map<String, dynamic>> proxies,
  List<XrayGroup>? groups,
  int skipped,
});

const Normalized _empty = (
  proxies: <Map<String, dynamic>>[],
  groups: null,
  skipped: 0,
);

// Pure content -> proxies, tried cheap/structural-first, never throwing and
// never fetching. http(s) URLs and raw clash docs are the caller's fetch and
// passthrough boundary and deliberately fall through to empty here.
Normalized normalize(String text, {int depth = 0}) {
  final t = text.trim();
  if (t.isEmpty || depth > 3) return _empty;

  // 1. Share link, or a newline list of them.
  final schemeIdx = t.indexOf('://');
  if (schemeIdx > 0) {
    final scheme = t.substring(0, schemeIdx).toLowerCase();
    if (shareLinkSchemes.contains(scheme)) {
      final res = parseSubscriptionContent(t);
      if (res.proxies.isNotEmpty || res.skipped > 0) {
        return (proxies: res.proxies, groups: null, skipped: res.skipped);
      }
    }
  }

  // 2. JSON: xray array (grouped), xray object, SIP008, sing-box.
  final json = _tryJson(t);
  if (json != null) {
    final fromJson = _fromJson(json, t);
    if (fromJson != null) return fromJson;
  }

  // 3. base64 layer -> recurse on the decoded payload.
  final decoded = decodeBase64Text(t);
  if (decoded != null) {
    final d = decoded.trim();
    if (d != t &&
        (d.contains('://') || d.startsWith('{') || d.startsWith('['))) {
      return normalize(decoded, depth: depth + 1);
    }
  }

  return _empty;
}

// Boundary predicates the pipeline uses around the pure normalizer: an http(s)
// URL is fetched first, a clash document is passed through unchanged, and
// anything normalize can turn into proxies is ingestable.
bool isSubscriptionUrl(String text) {
  final t = text.trim();
  final i = t.indexOf('://');
  if (i <= 0) return false;
  final scheme = t.substring(0, i).toLowerCase();
  return (scheme == 'http' || scheme == 'https') && !t.contains('\n');
}

bool isClashDocument(String text) {
  final t = text.trim();
  return RegExp(r'(^|\n)\s*proxies\s*:').hasMatch(t) ||
      t.contains('proxy-groups:');
}

bool isIngestable(String text) =>
    isSubscriptionUrl(text) ||
    isClashDocument(text) ||
    normalize(text).proxies.isNotEmpty;

Object? _tryJson(String t) {
  if (!(t.startsWith('{') || t.startsWith('['))) return null;
  try {
    return jsonDecode(t);
  } catch (_) {
    return null;
  }
}

Normalized? _fromJson(Object json, String rawText) {
  if (json is List) {
    final groups = parseXrayJsonGroups(rawText);
    if (groups.isEmpty) return null;
    return (
      proxies: [for (final g in groups) ...g.proxies],
      groups: groups,
      skipped: 0,
    );
  }
  if (json is! Map) return null;

  final outbounds = json['outbounds'];
  if (outbounds is List) {
    if (_isXrayOutbounds(outbounds)) {
      // v2rayN single-config object: wrap its outbounds as one unnamed profile
      // so the shared xray walk converts them (flat, no grouping).
      final proxies = parseXrayJson(
        jsonEncode([
          {'remarks': '', 'outbounds': outbounds},
        ]),
      );
      return proxies.isEmpty
          ? null
          : (proxies: proxies, groups: null, skipped: 0);
    }
    final proxies = parseSingbox(json);
    return (proxies == null || proxies.isEmpty)
        ? null
        : (proxies: proxies, groups: null, skipped: 0);
  }

  if (json['servers'] is List) {
    final proxies = parseSip008(json);
    return (proxies == null || proxies.isEmpty)
        ? null
        : (proxies: proxies, groups: null, skipped: 0);
  }
  return null;
}

// xray outbounds carry protocol + settings/streamSettings; sing-box outbounds
// carry type + server_port. Sniff the first proxy-shaped element to pick.
bool _isXrayOutbounds(List<dynamic> outbounds) {
  for (final ob in outbounds) {
    if (ob is! Map) continue;
    if (ob.containsKey('protocol') &&
        (ob.containsKey('settings') || ob.containsKey('streamSettings'))) {
      return true;
    }
    if (ob.containsKey('type') && ob.containsKey('server_port')) return false;
  }
  return false;
}
