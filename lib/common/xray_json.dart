import 'dart:convert';

import 'package:fl_clash/common/yaml.dart';

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

typedef XrayGroup = ({String remark, List<Map<String, dynamic>> proxies});

List<XrayGroup> parseXrayJsonGroups(
  String text, {
  String fingerprint = 'upstream',
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } catch (_) {
    return [];
  }
  if (decoded is! List) return [];

  final out = <XrayGroup>[];
  final usedNames = <String>{};
  for (final profile in decoded) {
    if (profile is! Map) continue;
    final remarks = '${profile['remarks'] ?? ''}';
    final label = remarks.isNotEmpty ? remarks : 'node';
    final obs = profile['outbounds'];
    if (obs is! List) continue;
    final proxies = <Map<String, dynamic>>[];
    var idx = 1;
    for (final ob in obs) {
      if (ob is! Map) continue;
      final proxy = _convertOutbound(ob, fingerprint);
      if (proxy == null) continue;
      var name = '$label ${idx.toString().padLeft(2, '0')}';
      while (usedNames.contains(name)) {
        idx++;
        name = '$label ${idx.toString().padLeft(2, '0')}';
      }
      usedNames.add(name);
      proxies.add({'name': name, ...proxy});
      idx++;
    }
    if (proxies.isNotEmpty) out.add((remark: label, proxies: proxies));
  }
  return out;
}

// slug, not the human label, drives filter: so emoji/Cyrillic/| never reach a regex
typedef RemarkGroup = ({String label, String slug, int count});

// <key>-rNN-MM names let a type:file provider be sliced per remark via filter;
// a provider group cannot name internal nodes
typedef SluggedXray = ({
  List<Map<String, dynamic>> proxies,
  List<RemarkGroup> remarks,
});

SluggedXray slugXrayGroups(
  String text,
  String key, {
  String fingerprint = 'upstream',
}) {
  final groups = parseXrayJsonGroups(text, fingerprint: fingerprint);
  final proxies = <Map<String, dynamic>>[];
  final remarks = <RemarkGroup>[];
  for (var i = 0; i < groups.length; i++) {
    final slug = '$key-r${(i + 1).toString().padLeft(2, '0')}';
    final g = groups[i];
    var n = 0;
    for (final p in g.proxies) {
      n++;
      proxies.add({...p, 'name': '$slug-${n.toString().padLeft(2, '0')}'});
    }
    remarks.add((label: g.remark, slug: slug, count: g.proxies.length));
  }
  return (proxies: proxies, remarks: remarks);
}

// No clean single-provider parent -> inject nothing (never drop sibling members).
void injectRemarkGroups(
  Map<String, dynamic> config,
  String key,
  List<RemarkGroup> remarks,
) {
  if (remarks.isEmpty) return;
  final pg = (config['proxy-groups'] as List?)
      ?.whereType<Map<dynamic, dynamic>>()
      .toList();
  if (pg == null) return;
  bool isCleanParent(Map<dynamic, dynamic> g) {
    final use = (g['use'] as List?)?.map((e) => '$e').toList() ?? const [];
    return use.length == 1 && use.first == key && g['filter'] == null;
  }

  final parents = pg.where(isCleanParent).toList();
  if (parents.isEmpty) return;
  final p0 = parents.first;
  final used = pg.map((g) => '${g['name']}').toSet();
  final specs = <Map<String, dynamic>>[];
  final displays = <String>[];
  for (final r in remarks) {
    if (r.count == 0) continue;
    final base = r.label.trim().isEmpty ? key : r.label.trim();
    var name = base;
    var dup = 2;
    while (used.contains(name)) {
      name = '$base ($dup)';
      dup++;
    }
    used.add(name);
    displays.add(name);
    specs.add({
      'name': name,
      'type': 'url-test',
      'use': [key],
      'filter': '^${RegExp.escape(r.slug)}-',
      'url': p0['url'] ?? 'http://cp.cloudflare.com/generate_204',
      'interval': p0['interval'] ?? 300,
      'tolerance': p0['tolerance'] ?? 50,
      if (p0['lazy'] == true) 'lazy': true,
    });
  }
  if (displays.isEmpty) return;
  for (final parent in parents) {
    parent['type'] = 'select';
    parent['proxies'] = List<String>.from(displays);
    parent
      ..remove('use')
      ..remove('filter')
      ..remove('url')
      ..remove('interval')
      ..remove('tolerance')
      ..remove('lazy');
  }
  // Reassign (not addAll): a getProfile list may be fixed-length. Parents were
  // mutated in place, so they carry over as the same references.
  config['proxy-groups'] = [...(config['proxy-groups'] as List), ...specs];
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
  final tag = ob['tag'];
  if (tag == 'direct' || tag == 'block' || tag == 'loopback') return null;

  final stream = ob['streamSettings'] is Map
      ? ob['streamSettings'] as Map
      : const {};
  final protocol = ob['protocol'];
  if (protocol == 'hysteria') return _convertHysteria2(ob, stream);
  if (protocol != 'vless') return null;

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

  var network = '${stream['network'] ?? 'tcp'}';
  if (network == 'raw') network = 'tcp'; // xray >=24 renamed tcp->raw

  final security = '${stream['security'] ?? ''}';
  final tls = security == 'reality' || security == 'tls';

  final proxy = <String, dynamic>{
    'type': 'vless',
    'server': '${server['address'] ?? ''}',
    'port': port,
    'uuid': '${user['id'] ?? ''}',
    'packet-encoding': 'xudp',
    'udp': true,
    'tls': tls,
    'network': network,
    'client-fingerprint': 'random',
  };

  final encryption = '${user['encryption'] ?? ''}';
  if (encryption.isNotEmpty && encryption != 'none') {
    proxy['encryption'] = encryption; // VLESS post-quantum (ML-KEM) etc.
  }

  final flow = '${user['flow'] ?? ''}';
  if (flow.isNotEmpty && network == 'tcp') proxy['flow'] = flow;

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
    final tlsSettings = stream['tlsSettings'] is Map
        ? stream['tlsSettings'] as Map
        : const {};
    proxy['servername'] = '${tlsSettings['serverName'] ?? ''}';
    final alpn = tlsSettings['alpn'];
    if (alpn is List && alpn.isNotEmpty) {
      proxy['alpn'] = [for (final a in alpn) '$a'];
    }
    final fp = '${tlsSettings['fingerprint'] ?? ''}';
    if (fingerprint == 'upstream' && fp.isNotEmpty) {
      proxy['client-fingerprint'] = fp;
    }
  }

  if (network == 'grpc') {
    final g = stream['grpcSettings'] is Map
        ? stream['grpcSettings'] as Map
        : const {};
    proxy['grpc-opts'] = {'grpc-service-name': '${g['serviceName'] ?? ''}'};
  } else if (network == 'ws') {
    final ws = stream['wsSettings'] is Map
        ? stream['wsSettings'] as Map
        : const {};
    final wsOpts = <String, dynamic>{'path': '${ws['path'] ?? '/'}'};
    final host = '${ws['host'] ?? ''}';
    if (host.isNotEmpty) wsOpts['headers'] = {'Host': host};
    proxy['ws-opts'] = wsOpts;
  } else if (network == 'xhttp') {
    // xhttp is HTTP-framed; h2 alpn only makes sense under a TLS/REALITY layer.
    if (tls && !proxy.containsKey('alpn')) proxy['alpn'] = ['h2'];
    proxy['xhttp-opts'] = _xhttpOpts(stream);
  }

  return proxy;
}

Map<String, dynamic> _xhttpOpts(Map<dynamic, dynamic> stream) {
  final x = stream['xhttpSettings'] is Map
      ? stream['xhttpSettings'] as Map
      : const {};
  final opts = <String, dynamic>{
    'path': '${x['path'] ?? '/'}',
    'mode': '${x['mode'] ?? 'auto'}',
  };
  final host = '${x['host'] ?? ''}';
  if (host.isNotEmpty) opts['host'] = host;
  if (x.containsKey('xPaddingBytes')) {
    opts['x-padding-bytes'] = '${x['xPaddingBytes']}';
  }
  if (x.containsKey('scMaxEachPostBytes')) {
    opts['sc-max-each-post-bytes'] = x['scMaxEachPostBytes'];
  }
  // xray >=25 nests mux under extra.xmux; older feeds used reuseSettings.
  final extra = x['extra'];
  final reuse = x['reuseSettings'] ?? (extra is Map ? extra['xmux'] : null);
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
  return opts;
}

Map<String, dynamic>? _convertHysteria2(
  Map<dynamic, dynamic> ob,
  Map<dynamic, dynamic> stream,
) {
  final hy = stream['hysteriaSettings'] is Map
      ? stream['hysteriaSettings'] as Map
      : const {};
  final settings = ob['settings'] is Map ? ob['settings'] as Map : const {};
  final version = asInt(hy['version']) ?? asInt(settings['version']);
  if (version != 2) return null; // only hysteria2 maps cleanly to mihomo
  final address = '${settings['address'] ?? ''}';
  final port = asInt(settings['port']);
  if (address.isEmpty || port == null || port == 0) return null;
  final password = '${hy['auth'] ?? ''}';
  if (password.isEmpty) return null;

  final proxy = <String, dynamic>{
    'type': 'hysteria2',
    'server': address,
    'port': port,
    'password': password,
    'udp': true,
  };
  final tlsSettings = stream['tlsSettings'] is Map
      ? stream['tlsSettings'] as Map
      : const {};
  final sni = '${tlsSettings['serverName'] ?? ''}';
  if (sni.isNotEmpty) proxy['sni'] = sni;
  final alpn = tlsSettings['alpn'];
  if (alpn is List && alpn.isNotEmpty) {
    proxy['alpn'] = [for (final a in alpn) '$a'];
  }
  return proxy;
}
