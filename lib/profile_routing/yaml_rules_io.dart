import 'package:fl_clash/common/yaml.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'group_spec.dart';
import 'provider_spec.dart';
import 'rule_codec.dart';

/// Reads/rewrites the `rules:` block of a raw mihomo config via `yaml_edit`,
/// preserving other keys, ordering, and comments. Comments *inside* the rules
/// block are best-effort (the block is rewritten whole).
class ProfileRulesDocument {
  final String raw;

  ProfileRulesDocument(this.raw);

  // Parsed once per instance; a half-written file yields null instead of throwing.
  late final YamlMap? _root = _parseRoot();

  YamlMap? _parseRoot() {
    try {
      final doc = loadYaml(raw);
      return doc is YamlMap ? doc : null;
    } on YamlException {
      return null;
    }
  }

  /// Parsed `rules:` entries; empty when the key is absent, not a list, or the
  /// document fails to parse (a half-written file must not throw).
  List<RoutingRule> get rules {
    final node = _root?['rules'];
    if (node is! YamlList) return const [];
    return parseRoutingRules(node.map((e) => e.toString()).toList());
  }

  /// New document string with the `rules:` list replaced by [rules]. Throws
  /// [ProfileRulesWriteException] when the root is not a YAML map.
  String withRules(List<RoutingRule> rules) {
    final editor = _mapEditor();
    editor.update(['rules'], serializeRoutingRules(rules));
    return _render(editor);
  }

  /// Packages under `tun.exclude-package` (the blacklist: these bypass the
  /// tunnel); empty when absent.
  List<String> get excludedPackages => _tunPackages('exclude-package');

  /// Packages under `tun.include-package` (the whitelist: only these enter the
  /// tunnel); empty when absent. Its presence is how the screen derives
  /// whitelist vs blacklist mode for a profile.
  List<String> get includedPackages => _tunPackages('include-package');

  /// Names under `sub-rules:` (each is its own named rule list); empty when
  /// absent. These are valid routing targets for app->sub-rule rules.
  List<String> get subRuleNames {
    final node = _root?['sub-rules'];
    if (node is! YamlMap) return const [];
    return node.keys.map((e) => e.toString()).toList();
  }

  /// Each `sub-rules:` entry parsed into its rule list (preserving order);
  /// empty map when absent or malformed.
  Map<String, List<RoutingRule>> get subRules {
    final node = _root?['sub-rules'];
    if (node is! YamlMap) return const {};
    final out = <String, List<RoutingRule>>{};
    for (final entry in node.entries) {
      final value = entry.value;
      out[entry.key.toString()] = value is YamlList
          ? parseRoutingRules(value.map((e) => e.toString()).toList())
          : const [];
    }
    return out;
  }

  /// New document with `sub-rules:` replaced by [subRules] (an empty map removes
  /// the key). Insertion order is kept; other keys/comments are preserved.
  String withSubRules(Map<String, List<RoutingRule>> subRules) {
    final editor = _mapEditor();
    final root = editor.parseAt([]) as YamlMap;
    if (subRules.isEmpty) {
      if (root.containsKey('sub-rules')) editor.remove(['sub-rules']);
      return _render(editor);
    }
    editor.update(
      ['sub-rules'],
      {for (final e in subRules.entries) e.key: serializeRoutingRules(e.value)},
    );
    return _render(editor);
  }

  /// Names declared under `proxies:`; empty when absent. Candidate members for
  /// a proxy group, distinct from group names.
  List<String> get proxyNames {
    final node = _root?['proxies'];
    if (node is! YamlList) return const [];
    return [
      for (final p in node)
        if (p is YamlMap && p['name'] != null) p['name'].toString(),
    ];
  }

  /// `proxies:` entries as (name, type, server) for a read-only listing.
  List<({String name, String type, String? server})> get proxyInfos {
    final node = _root?['proxies'];
    if (node is! YamlList) return const [];
    return [
      for (final p in node)
        if (p is YamlMap && p['name'] != null)
          (
            name: p['name'].toString(),
            type: (p['type'] ?? '').toString(),
            server: p['server']?.toString(),
          ),
    ];
  }

  /// Each `proxies:` entry as a lossless dart map; empty when absent. Preserves
  /// every protocol field verbatim so an imported node round-trips.
  List<Map<String, dynamic>> get proxies {
    final node = _root?['proxies'];
    if (node is! YamlList) return const [];
    return [
      for (final p in node)
        if (p is YamlMap) (yamlToDart(p) as Map).cast<String, dynamic>(),
    ];
  }

  /// New document with `proxies:` replaced by [proxies] (an empty list removes
  /// the key); every field preserved. Other keys/comments are kept.
  String withProxies(List<Map<String, dynamic>> proxies) {
    final editor = _mapEditor();
    final root = editor.parseAt([]) as YamlMap;
    if (proxies.isEmpty) {
      if (root.containsKey('proxies')) editor.remove(['proxies']);
      return _render(editor);
    }
    editor.update(['proxies'], proxies);
    return _render(editor);
  }

  /// Each `proxy-groups:` entry as a lossless [GroupSpec]; empty when absent.
  List<GroupSpec> get proxyGroups {
    final node = _root?['proxy-groups'];
    if (node is! YamlList) return const [];
    return [
      for (final g in node)
        if (g is YamlMap) GroupSpec.fromYaml(g),
    ];
  }

  /// New document with `proxy-groups:` replaced by [groups] (each group's
  /// unknown keys preserved verbatim). Other keys/comments are preserved.
  String withProxyGroups(List<GroupSpec> groups) {
    final editor = _mapEditor();
    editor.update(['proxy-groups'], [for (final g in groups) g.raw]);
    return _render(editor);
  }

  /// Each `proxy-providers:` entry (a name->config map) as a lossless
  /// [ProviderSpec]; empty when absent.
  Map<String, ProviderSpec> get proxyProviders => _providers('proxy-providers');

  /// Each `rule-providers:` entry as a lossless [ProviderSpec]; empty when
  /// absent.
  Map<String, ProviderSpec> get ruleProviders => _providers('rule-providers');

  Map<String, ProviderSpec> _providers(String key) {
    final node = _root?[key];
    if (node is! YamlMap) return const {};
    final out = <String, ProviderSpec>{};
    for (final e in node.entries) {
      final value = e.value;
      if (value is YamlMap) {
        out[e.key.toString()] = ProviderSpec.fromYaml(value);
      }
    }
    return out;
  }

  /// New document with `proxy-providers:` replaced by [providers] (an empty map
  /// removes the key); unknown keys per provider preserved. Other keys/comments
  /// are kept.
  String withProxyProviders(Map<String, ProviderSpec> providers) =>
      _withProviders('proxy-providers', providers);

  /// New document with `rule-providers:` replaced by [providers]; same
  /// preservation/removal semantics as [withProxyProviders].
  String withRuleProviders(Map<String, ProviderSpec> providers) =>
      _withProviders('rule-providers', providers);

  String _withProviders(String key, Map<String, ProviderSpec> providers) {
    final editor = _mapEditor();
    final root = editor.parseAt([]) as YamlMap;
    if (providers.isEmpty) {
      if (root.containsKey(key)) editor.remove([key]);
      return _render(editor);
    }
    editor.update(
      [key],
      {for (final e in providers.entries) e.key: e.value.raw},
    );
    return _render(editor);
  }

  // yaml_edit emits `/` as YAML-1.1 `\/` in double-quoted scalars; mihomo's Go
  // yaml.v3 rejects `\/` (unknown escape) though it decodes to the same `/`.
  // Dart's lenient parser accepts `\/`, so a re-parse round-trip never sees it.
  static String _render(YamlEditor editor) =>
      editor.toString().replaceAll(r'\/', '/');

  // A YamlEditor over a map-rooted config, or a ProfileRulesWriteException the
  // controller already catches; so a malformed file surfaces as a message
  // instead of an uncaught YamlException from the editor constructor.
  YamlEditor _mapEditor() {
    final YamlEditor editor;
    final Object? root;
    try {
      editor = YamlEditor(raw);
      root = editor.parseAt([]);
    } on YamlException catch (e) {
      throw ProfileRulesWriteException(
        'config is not valid YAML: ${e.message}',
      );
    }
    if (root is! YamlMap) {
      throw const ProfileRulesWriteException('config root is not a YAML map');
    }
    return editor;
  }

  List<String> _tunPackages(String key) {
    final tun = _root?['tun'];
    final node = tun is YamlMap ? tun[key] : null;
    if (node is! YamlList) return const [];
    return node.whereType<String>().toList();
  }

  /// New document with `tun.exclude-package` set to [packages] (creates `tun`
  /// or the key when absent; an empty list removes the key). Other tun fields
  /// and document parts are preserved.
  String withExcludedPackages(List<String> packages) =>
      _withTunPackages('exclude-package', packages);

  /// New document with `tun.include-package` set to [packages]; same
  /// preservation/removal semantics as [withExcludedPackages].
  String withIncludedPackages(List<String> packages) =>
      _withTunPackages('include-package', packages);

  String _withTunPackages(String key, List<String> packages) {
    final editor = _mapEditor();
    final root = editor.parseAt([]) as YamlMap;
    final tun = root['tun'];
    if (packages.isEmpty) {
      if (tun is YamlMap && tun.containsKey(key)) {
        editor.remove(['tun', key]);
      }
      return _render(editor);
    }
    if (tun is YamlMap) {
      editor.update(['tun', key], packages);
    } else {
      editor.update(['tun'], {key: packages});
    }
    return _render(editor);
  }
}

class ProfileRulesWriteException implements Exception {
  final String message;

  const ProfileRulesWriteException(this.message);

  @override
  String toString() => 'ProfileRulesWriteException: $message';
}

/// Whether the tun include/exclude-package SETS differ between two profile
/// documents (order-insensitive). A routing write only needs a tunnel
/// re-establish when this is true, since everything else hot-reloads.
bool tunPackagesChanged(String before, String after) {
  bool sameSet(List<String> x, List<String> y) =>
      x.length == y.length && x.toSet().containsAll(y);
  final a = ProfileRulesDocument(before);
  final b = ProfileRulesDocument(after);
  return !sameSet(a.includedPackages, b.includedPackages) ||
      !sameSet(a.excludedPackages, b.excludedPackages);
}
