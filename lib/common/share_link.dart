import 'dart:convert';

import 'package:fl_clash/common/yaml.dart';

/// Single-proxy share-link schemes we recognize. Parsing is implemented for
/// vless/vmess/ss/trojan; the rest are recognized (so the artifact classifies
/// as a share link) but parse to null, surfacing the honest "no servers" state.
const shareLinkSchemes = [
  'vless',
  'vmess',
  'ss',
  'ssr',
  'trojan',
  'hysteria2',
  'hy2',
  'tuic',
  'anytls',
];

/// Decode a base64 string (standard or url-safe, padding optional) to UTF-8
/// text. Returns null if the input is not valid base64 / not UTF-8.
String? decodeBase64Text(String input) {
  var s = input
      .replaceAll('-', '+')
      .replaceAll('_', '/')
      .replaceAll(RegExp(r'\s'), '');
  if (s.isEmpty) return null;
  final pad = s.length % 4;
  if (pad > 0) s += '=' * (4 - pad);
  try {
    return utf8.decode(base64.decode(s));
  } catch (_) {
    return null;
  }
}

/// Parse a single share link into a clash/mihomo proxy map, or null if the
/// scheme is unsupported or the link is malformed. vless reality maps
/// pbk/sid/fp/sni/flow to the mihomo schema (see docs/onboarding.md).
Map<String, dynamic>? parseShareLink(String raw) {
  final text = raw.trim();
  final schemeIdx = text.indexOf('://');
  if (schemeIdx <= 0) return null;
  final scheme = text.substring(0, schemeIdx).toLowerCase();
  try {
    switch (scheme) {
      case 'vless':
        return _parseVless(text);
      case 'vmess':
        return _parseVmess(text);
      case 'ss':
        return _parseSs(text);
      case 'trojan':
        return _parseTrojan(text);
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

/// Decode a v2ray subscription body (a base64 blob, or a plain newline list of
/// share links) into clash proxy maps. `skipped` counts links whose scheme is
/// recognized but not parseable (e.g. hy2/tuic), so the loss is not silent.
({List<Map<String, dynamic>> proxies, int skipped}) parseSubscriptionContent(
  String body,
) {
  final decoded = decodeBase64Text(body.trim());
  final text = (decoded != null && decoded.contains('://')) ? decoded : body;
  final out = <Map<String, dynamic>>[];
  var skipped = 0;
  for (final line in text.split(RegExp(r'[\r\n]+'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final proxy = parseShareLink(trimmed);
    if (proxy != null) {
      out.add(proxy);
    } else if (_isRecognizedScheme(trimmed)) {
      skipped++;
    }
  }
  return (proxies: out, skipped: skipped);
}

bool _isRecognizedScheme(String link) {
  final idx = link.indexOf('://');
  return idx > 0 &&
      shareLinkSchemes.contains(link.substring(0, idx).toLowerCase());
}

String _nameFromFragment(Uri uri) {
  if (uri.fragment.isEmpty) return '';
  try {
    return Uri.decodeComponent(uri.fragment);
  } catch (_) {
    return uri.fragment;
  }
}

String _network(String? type) {
  switch (type) {
    case 'ws':
    case 'grpc':
    case 'h2':
    case 'http':
      return type!;
    default:
      return 'tcp';
  }
}

void _applyTransport(
  Map<String, dynamic> proxy,
  String network,
  Map<String, String> q,
) {
  if (network == 'ws') {
    proxy['ws-opts'] = {
      'path': q['path']?.isNotEmpty == true ? q['path'] : '/',
      'headers': {'Host': q['host'] ?? q['sni'] ?? ''},
    };
  } else if (network == 'grpc') {
    proxy['grpc-opts'] = {'grpc-service-name': q['serviceName'] ?? ''};
  }
}

Map<String, dynamic>? _parseVless(String text) {
  final uri = Uri.parse(text);
  final server = uri.host;
  final port = uri.port;
  if (server.isEmpty || port == 0 || uri.userInfo.isEmpty) return null;
  final q = uri.queryParameters;
  final security = q['security'] ?? 'none';
  final network = _network(q['type']);
  final proxy = <String, dynamic>{
    'name': _nameFromFragment(uri),
    'type': 'vless',
    'server': server,
    'port': port,
    'uuid': uri.userInfo,
    'network': network,
    'udp': true,
    'tls': security == 'tls' || security == 'reality' || security == 'xtls',
  };
  if ((q['sni'] ?? '').isNotEmpty) proxy['servername'] = q['sni'];
  if ((q['fp'] ?? '').isNotEmpty) proxy['client-fingerprint'] = q['fp'];
  if ((q['flow'] ?? '').isNotEmpty) proxy['flow'] = q['flow'];
  if (security == 'reality') {
    final reality = <String, dynamic>{'public-key': q['pbk'] ?? ''};
    if ((q['sid'] ?? '').isNotEmpty) reality['short-id'] = q['sid'];
    proxy['reality-opts'] = reality;
  }
  _applyTransport(proxy, network, q);
  return proxy;
}

Map<String, dynamic>? _parseVmess(String text) {
  final decoded = decodeBase64Text(text.substring('vmess://'.length));
  if (decoded == null) return null;
  final json = jsonDecode(decoded) as Map<String, dynamic>;
  final server = '${json['add'] ?? ''}';
  final port = asInt(json['port']);
  if (server.isEmpty || port == null || port == 0) return null;
  final network = _network('${json['net']}');
  final proxy = <String, dynamic>{
    'name': '${json['ps'] ?? ''}',
    'type': 'vmess',
    'server': server,
    'port': port,
    'uuid': '${json['id'] ?? ''}',
    'alterId': asInt(json['aid']) ?? 0,
    'cipher': '${json['scy'] ?? 'auto'}',
    'network': network,
    'udp': true,
    'tls': '${json['tls'] ?? ''}' == 'tls',
  };
  final sni = '${json['sni'] ?? json['host'] ?? ''}';
  if (sni.isNotEmpty) proxy['servername'] = sni;
  _applyTransport(proxy, network, {
    'path': '${json['path'] ?? ''}',
    'host': '${json['host'] ?? ''}',
  });
  return proxy;
}

Map<String, dynamic>? _parseSs(String text) {
  var rest = text.substring('ss://'.length);
  var name = '';
  final hashIdx = rest.indexOf('#');
  if (hashIdx >= 0) {
    final frag = rest.substring(hashIdx + 1);
    name = Uri.decodeComponent(frag);
    rest = rest.substring(0, hashIdx);
  }
  final qIdx = rest.indexOf('?');
  String? pluginParam;
  if (qIdx >= 0) {
    pluginParam = Uri.splitQueryString(rest.substring(qIdx + 1))['plugin'];
    rest = rest.substring(0, qIdx);
  }

  String method;
  String password;
  String hostPort;
  if (rest.contains('@')) {
    final atIdx = rest.lastIndexOf('@');
    final userInfo = rest.substring(0, atIdx);
    hostPort = rest.substring(atIdx + 1);
    final creds = decodeBase64Text(userInfo) ?? Uri.decodeComponent(userInfo);
    final ci = creds.indexOf(':');
    if (ci < 0) return null;
    method = creds.substring(0, ci);
    password = creds.substring(ci + 1);
  } else {
    final creds = decodeBase64Text(rest);
    if (creds == null || !creds.contains('@')) return null;
    final atIdx = creds.lastIndexOf('@');
    final mp = creds.substring(0, atIdx);
    hostPort = creds.substring(atIdx + 1);
    final ci = mp.indexOf(':');
    if (ci < 0) return null;
    method = mp.substring(0, ci);
    password = mp.substring(ci + 1);
  }
  final colon = hostPort.lastIndexOf(':');
  if (colon < 0) return null;
  final server = hostPort.substring(0, colon);
  final port = int.tryParse(hostPort.substring(colon + 1));
  if (server.isEmpty || port == null || port == 0) return null;
  final proxy = <String, dynamic>{
    'name': name,
    'type': 'ss',
    'server': server,
    'port': port,
    'cipher': method,
    'password': password,
    'udp': true,
  };
  if (pluginParam != null && pluginParam.isNotEmpty) {
    final plugin = _ssPlugin(pluginParam);
    if (plugin == null) return null; // unsupported plugin -> honest no-node
    proxy.addAll(plugin);
  }
  return proxy;
}

/// Maps a SIP002 `plugin=` spec (`name;k=v;flag;...`) to mihomo `plugin` +
/// `plugin-opts`; null for a plugin mihomo has no clash mapping for.
Map<String, dynamic>? _ssPlugin(String param) {
  final parts = param.split(';');
  final opts = <String, String>{};
  for (final p in parts.skip(1)) {
    final eq = p.indexOf('=');
    if (eq < 0) {
      opts[p] = '';
    } else {
      opts[p.substring(0, eq)] = p.substring(eq + 1);
    }
  }
  switch (parts.first) {
    case 'obfs-local':
    case 'simple-obfs':
      return {
        'plugin': 'obfs',
        'plugin-opts': {
          'mode': opts['obfs'] ?? 'http',
          if ((opts['obfs-host'] ?? '').isNotEmpty) 'host': opts['obfs-host'],
        },
      };
    case 'v2ray-plugin':
      return {
        'plugin': 'v2ray-plugin',
        'plugin-opts': {
          'mode': opts['mode'] ?? 'websocket',
          if ((opts['host'] ?? '').isNotEmpty) 'host': opts['host'],
          if ((opts['path'] ?? '').isNotEmpty) 'path': opts['path'],
          if (opts.containsKey('tls')) 'tls': true,
        },
      };
    default:
      return null;
  }
}

Map<String, dynamic>? _parseTrojan(String text) {
  final uri = Uri.parse(text);
  final server = uri.host;
  final port = uri.port;
  if (server.isEmpty || port == 0 || uri.userInfo.isEmpty) return null;
  final q = uri.queryParameters;
  final network = _network(q['type']);
  final proxy = <String, dynamic>{
    'name': _nameFromFragment(uri),
    'type': 'trojan',
    'server': server,
    'port': port,
    'password': Uri.decodeComponent(uri.userInfo),
    'udp': true,
  };
  if ((q['sni'] ?? '').isNotEmpty) proxy['sni'] = q['sni'];
  if ((q['fp'] ?? '').isNotEmpty) proxy['client-fingerprint'] = q['fp'];
  if (network != 'tcp') proxy['network'] = network;
  _applyTransport(proxy, network, q);
  return proxy;
}
