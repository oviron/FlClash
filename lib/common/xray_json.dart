import 'dart:convert';

import 'package:fl_clash/common/yaml.dart';

/// xray-JSON subscription (list of `{remarks, outbounds}`, the Happ format) ->
/// mihomo vless dicts. `prefix`+`buckets` -> `<prefix>-<bucket>-NN`; `skip` drops
/// profiles; `dropUnmatched` drops unbucketed remarks; `fingerprint` random|upstream.
List<Map<String, dynamic>> parseXrayJson(
  String text, {
  String? prefix,
  Map<String, List<String>>? buckets,
  String fingerprint = 'upstream',
  bool dropUnmatched = false,
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } catch (_) {
    return [];
  }
  if (decoded is! List) return [];

  final out = <Map<String, dynamic>>[];
  final counters = <String, int>{};
  final skipNeedles = buckets?['skip'] ?? const <String>[];

  for (final profile in decoded) {
    if (profile is! Map) continue;
    final remarks = '${profile['remarks'] ?? ''}';
    if (skipNeedles.any(remarks.contains)) continue;
    final bucket = _bucketFor(remarks, buckets, dropUnmatched);
    if (bucket == null) continue;
    final obs = profile['outbounds'];
    if (obs is! List) continue;
    for (final ob in obs) {
      if (ob is! Map) continue;
      final proxy = _convertOutbound(ob, fingerprint);
      if (proxy == null) continue;
      final String name;
      if (prefix != null) {
        final n = (counters[bucket] ?? 0) + 1;
        counters[bucket] = n;
        name = '$prefix-$bucket-${n.toString().padLeft(2, '0')}';
      } else {
        name = remarks.isNotEmpty ? remarks : 'node';
      }
      out.add({'name': name, ...proxy});
    }
  }
  return out;
}

String? _bucketFor(
  String remarks,
  Map<String, List<String>>? buckets,
  bool dropUnmatched,
) {
  if (buckets != null) {
    for (final entry in buckets.entries) {
      if (entry.key == 'skip') continue;
      if (entry.value.any(remarks.contains)) return entry.key;
    }
  }
  return dropUnmatched ? null : 'main';
}

Map<String, dynamic>? _convertOutbound(
  Map<dynamic, dynamic> ob,
  String fingerprint,
) {
  if (ob['protocol'] != 'vless') return null;
  final tag = ob['tag'];
  if (tag == 'direct' || tag == 'block' || tag == 'loopback') return null;

  final settings = ob['settings'];
  if (settings is! Map) return null;
  final vnext = settings['vnext'];
  if (vnext is! List || vnext.isEmpty) return null;
  final server = vnext.first;
  if (server is! Map) return null;
  final users = server['users'];
  if (users is! List || users.isEmpty) return null;
  final user = users.first;
  if (user is! Map) return null;

  final port = asInt(server['port']);
  if (port == null || port == 0) return null;

  final stream = ob['streamSettings'] is Map
      ? ob['streamSettings'] as Map
      : const {};
  var network = '${stream['network'] ?? 'tcp'}';
  if (network == 'raw') network = 'tcp'; // xray >=24 renamed tcp->raw

  final proxy = <String, dynamic>{
    'type': 'vless',
    'server': '${server['address'] ?? ''}',
    'port': port,
    'uuid': '${user['id'] ?? ''}',
    'packet-encoding': 'xudp',
    'udp': true,
    'tls': true,
    'network': network,
    'client-fingerprint': 'random',
  };

  final flow = '${user['flow'] ?? ''}';
  if (flow.isNotEmpty && network == 'tcp') proxy['flow'] = flow;
  if (network == 'xhttp') proxy['alpn'] = ['h2'];

  final security = stream['security'];
  if (security == 'reality') {
    final rs = stream['realitySettings'] is Map
        ? stream['realitySettings'] as Map
        : const {};
    final publicKey = '${rs['publicKey'] ?? ''}';
    if (publicKey.isEmpty) return null; // a reality node with no key is dead
    proxy['servername'] = '${rs['serverName'] ?? ''}';
    proxy['reality-opts'] = {
      'public-key': publicKey,
      'short-id': '${rs['shortId'] ?? ''}',
    };
    final fp = '${rs['fingerprint'] ?? ''}';
    if (fingerprint == 'upstream' && fp.isNotEmpty) {
      proxy['client-fingerprint'] = fp;
    }
  } else if (security == 'tls') {
    final tls = stream['tlsSettings'] is Map
        ? stream['tlsSettings'] as Map
        : const {};
    proxy['servername'] = '${tls['serverName'] ?? ''}';
    final fp = '${tls['fingerprint'] ?? ''}';
    if (fingerprint == 'upstream' && fp.isNotEmpty) {
      proxy['client-fingerprint'] = fp;
    }
  }

  if (network == 'xhttp') {
    final x = stream['xhttpSettings'] is Map
        ? stream['xhttpSettings'] as Map
        : const {};
    final opts = <String, dynamic>{
      'path': '${x['path'] ?? '/'}',
      'mode': '${x['mode'] ?? 'auto'}',
    };
    if (x.containsKey('xPaddingBytes')) {
      opts['x-padding-bytes'] = '${x['xPaddingBytes']}';
    }
    if (x.containsKey('scMaxEachPostBytes')) {
      opts['sc-max-each-post-bytes'] = x['scMaxEachPostBytes'];
    }
    final reuse = x['reuseSettings'];
    if (reuse is Map) {
      opts['reuse-settings'] = {
        'max-concurrency': '${reuse['maxConcurrency'] ?? ''}',
        'max-connections': reuse['maxConnections'] ?? 0,
        'c-max-reuse-times': reuse['cMaxReuseTimes'] ?? 0,
        'h-max-request-times': '${reuse['hMaxRequestTimes'] ?? ''}',
        'h-max-reusable-secs': '${reuse['hMaxReusableSecs'] ?? ''}',
        'h-keep-alive-period': reuse['hKeepAlivePeriod'] ?? 0,
      };
    }
    proxy['xhttp-opts'] = opts;
  }

  return proxy;
}
