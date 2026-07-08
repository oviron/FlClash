import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/yaml.dart';

// sing-box config -> clash proxies (mainstream outbound types only). Returns
// null when the input has no `outbounds` array, so the normalizer's try-parse
// falls through. selector/urltest/direct/block and unknown types are skipped.
List<Map<String, dynamic>>? parseSingbox(Object? json) {
  if (json is! Map) return null;
  final outbounds = json['outbounds'];
  if (outbounds is! List) return null;

  final out = <Map<String, dynamic>>[];
  for (final ob in outbounds) {
    if (ob is! Map) continue;
    final proxy = _convertOutbound(ob);
    if (proxy != null) out.add(proxy);
  }
  return out;
}

Map<String, dynamic>? _convertOutbound(Map<dynamic, dynamic> ob) {
  final type = '${ob['type'] ?? ''}';
  final server = '${ob['server'] ?? ''}';
  final port = asInt(ob['server_port']);
  if (server.isEmpty || port == null || port == 0) return null;

  final name = '${ob['tag'] ?? server}';
  final network = _transportNetwork(ob['transport']);

  switch (type) {
    case 'shadowsocks':
      final method = '${ob['method'] ?? ''}';
      if (method.isEmpty) return null;
      final proxy = <String, dynamic>{
        'name': name,
        'type': 'ss',
        'server': server,
        'port': port,
        'cipher': method,
        'password': '${ob['password'] ?? ''}',
        'udp': true,
      };
      final plugin = '${ob['plugin'] ?? ''}';
      if (plugin.isNotEmpty) {
        final opts = '${ob['plugin_opts'] ?? ''}';
        final mapped = ssPlugin(opts.isEmpty ? plugin : '$plugin;$opts');
        if (mapped == null) return null;
        proxy.addAll(mapped);
      }
      return proxy;

    case 'vless':
      final proxy = <String, dynamic>{
        'name': name,
        'type': 'vless',
        'server': server,
        'port': port,
        'uuid': '${ob['uuid'] ?? ''}',
        'network': network,
        'udp': true,
      };
      final flow = '${ob['flow'] ?? ''}';
      if (flow.isNotEmpty && network == 'tcp') proxy['flow'] = flow;
      _applyTls(proxy, ob['tls']);
      _applyTransport(proxy, network, ob['transport']);
      return proxy;

    case 'vmess':
      final proxy = <String, dynamic>{
        'name': name,
        'type': 'vmess',
        'server': server,
        'port': port,
        'uuid': '${ob['uuid'] ?? ''}',
        'alterId': asInt(ob['alter_id']) ?? 0,
        'cipher': '${ob['security'] ?? 'auto'}',
        'network': network,
        'udp': true,
      };
      _applyTls(proxy, ob['tls']);
      _applyTransport(proxy, network, ob['transport']);
      return proxy;

    case 'trojan':
      final proxy = <String, dynamic>{
        'name': name,
        'type': 'trojan',
        'server': server,
        'port': port,
        'password': '${ob['password'] ?? ''}',
        'udp': true,
      };
      if (network != 'tcp') proxy['network'] = network;
      _applyTrojanTls(proxy, ob['tls']);
      _applyTransport(proxy, network, ob['transport']);
      return proxy;

    case 'hysteria2':
      final proxy = <String, dynamic>{
        'name': name,
        'type': 'hysteria2',
        'server': server,
        'port': port,
        'password': '${ob['password'] ?? ob['up_password'] ?? ''}',
        'udp': true,
      };
      _applyHysteriaTls(proxy, ob['tls']);
      return proxy;

    default:
      return null; // selector / urltest / direct / block / unknown
  }
}

String _transportNetwork(Object? transport) {
  if (transport is! Map) return 'tcp';
  final t = '${transport['type'] ?? ''}';
  switch (t) {
    case 'ws':
    case 'grpc':
    case 'http':
    case 'httpupgrade':
      return t;
    default:
      return 'tcp';
  }
}

// vless/vmess TLS: sets tls + servername, reality-opts, alpn, client-fingerprint.
void _applyTls(Map<String, dynamic> proxy, Object? tls) {
  if (tls is! Map || tls['enabled'] != true) {
    proxy['tls'] = false;
    return;
  }
  proxy['tls'] = true;
  final sni = '${tls['server_name'] ?? ''}';
  if (sni.isNotEmpty) proxy['servername'] = sni;
  final alpn = tls['alpn'];
  if (alpn is List && alpn.isNotEmpty) {
    proxy['alpn'] = [for (final a in alpn) '$a'];
  }
  final reality = tls['reality'];
  if (reality is Map && reality['enabled'] == true) {
    final pbk = '${reality['public_key'] ?? ''}';
    if (pbk.isNotEmpty) {
      proxy['reality-opts'] = {
        'public-key': pbk,
        if ('${reality['short_id'] ?? ''}'.isNotEmpty)
          'short-id': '${reality['short_id']}',
      };
    }
  }
  final utls = tls['utls'];
  if (utls is Map && '${utls['fingerprint'] ?? ''}'.isNotEmpty) {
    proxy['client-fingerprint'] = '${utls['fingerprint']}';
  }
}

// trojan uses `sni` (not servername); no reality.
void _applyTrojanTls(Map<String, dynamic> proxy, Object? tls) {
  if (tls is! Map || tls['enabled'] != true) return;
  final sni = '${tls['server_name'] ?? ''}';
  if (sni.isNotEmpty) proxy['sni'] = sni;
  final alpn = tls['alpn'];
  if (alpn is List && alpn.isNotEmpty) {
    proxy['alpn'] = [for (final a in alpn) '$a'];
  }
}

void _applyHysteriaTls(Map<String, dynamic> proxy, Object? tls) {
  if (tls is! Map) return;
  final sni = '${tls['server_name'] ?? ''}';
  if (sni.isNotEmpty) proxy['sni'] = sni;
  final alpn = tls['alpn'];
  if (alpn is List && alpn.isNotEmpty) {
    proxy['alpn'] = [for (final a in alpn) '$a'];
  }
}

void _applyTransport(Map<String, dynamic> proxy, String network, Object? t) {
  if (t is! Map) return;
  if (network == 'ws' || network == 'httpupgrade') {
    final ws = <String, dynamic>{'path': '${t['path'] ?? '/'}'};
    final headers = t['headers'];
    if (headers is Map && headers.isNotEmpty) {
      ws['headers'] = {for (final e in headers.entries) '${e.key}': '${e.value}'};
    }
    proxy['ws-opts'] = ws;
  } else if (network == 'grpc') {
    proxy['grpc-opts'] = {'grpc-service-name': '${t['service_name'] ?? ''}'};
  }
}
