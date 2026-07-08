import 'package:fl_clash/ingest/normalize.dart';

const quickStartExitGroup = 'PROXY';

const _healthUrl = 'http://cp.cloudflare.com/generate_204';

// The one url-test group literal (was copied four times across the codebase).
Map<String, dynamic> urlTestGroup(String name, List<String> proxies) => {
  'name': name,
  'type': 'url-test',
  'proxies': proxies,
  'url': _healthUrl,
  'interval': 300,
  'tolerance': 50,
};

// Node envelope only (inline proxies + exit group); routing is layered on by
// applyQuickStartRouting. Flat is the one-bucket case of grouped: a single
// url-test PROXY. Grouped keeps the Happ layout (a PROXY select over one
// url-test group per remark-profile) so the user picks a profile as in Happ.
Map<String, dynamic> synthesize(Normalized n) {
  final groups = n.groups;
  if (groups != null && groups.isNotEmpty) return _grouped(groups);
  if (n.proxies.isEmpty) {
    throw ArgumentError('cannot synthesize a config without proxies');
  }
  final named = _ensureUniqueNames(n.proxies);
  final names = named.map((p) => p['name'] as String).toList();
  return {
    'proxies': named,
    'proxy-groups': [urlTestGroup(quickStartExitGroup, names)],
  };
}

Map<String, dynamic> _grouped(
  List<({String remark, List<Map<String, dynamic>> proxies})> groups,
) {
  final proxies = <Map<String, dynamic>>[];
  final specs = <Map<String, dynamic>>[];
  final groupNames = <String>[];
  // Reserve the exit-group name so a remark named 'PROXY' can't collide with it.
  final used = <String>{quickStartExitGroup};
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
    specs.add(
      urlTestGroup(name, g.proxies.map((p) => p['name'] as String).toList()),
    );
  }
  return {
    'proxies': proxies,
    'proxy-groups': [
      {'name': quickStartExitGroup, 'type': 'select', 'proxies': groupNames},
      ...specs,
    ],
  };
}

List<Map<String, dynamic>> _ensureUniqueNames(
  List<Map<String, dynamic>> proxies,
) {
  // Reserve the exit-group name so a node named 'PROXY' can't collide with it.
  final used = <String>{quickStartExitGroup};
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
