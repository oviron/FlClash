import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/yaml.dart';

// SIP008 online-config document -> ss proxies. Returns null when the input is
// not a SIP008 shape (no `servers` array), so the normalizer's try-parse can
// fall through to the next format.
List<Map<String, dynamic>>? parseSip008(Object? json) {
  if (json is! Map) return null;
  final servers = json['servers'];
  if (servers is! List) return null;

  final out = <Map<String, dynamic>>[];
  for (final s in servers) {
    if (s is! Map) continue;
    final server = '${s['server'] ?? ''}';
    final port = asInt(s['server_port']);
    final method = '${s['method'] ?? ''}';
    if (server.isEmpty || port == null || port == 0 || method.isEmpty) continue;

    final name = '${s['remarks'] ?? s['remark'] ?? server}';
    final proxy = <String, dynamic>{
      'name': name.isEmpty ? server : name,
      'type': 'ss',
      'server': server,
      'port': port,
      'cipher': method,
      'password': '${s['password'] ?? ''}',
      'udp': true,
    };

    final plugin = '${s['plugin'] ?? ''}';
    if (plugin.isNotEmpty) {
      final opts = '${s['plugin_opts'] ?? ''}';
      final mapped = ssPlugin(opts.isEmpty ? plugin : '$plugin;$opts');
      if (mapped == null) continue; // unsupported plugin -> honest no-node
      proxy.addAll(mapped);
    }
    out.add(proxy);
  }
  return out;
}
