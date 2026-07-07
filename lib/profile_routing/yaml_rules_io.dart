import 'package:fl_clash/common/yaml.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'group_spec.dart';
import 'provider_spec.dart';
import 'rule_codec.dart';

// yaml_edit rewrites a block whole: comments inside it are best-effort, but
// keys/ordering/comments outside the block survive.
class ProfileRulesDocument {
  final String raw;

  ProfileRulesDocument(this.raw);

  // A half-written file yields null instead of throwing.
  late final YamlMap? _root = _parseRoot();

  YamlMap? _parseRoot() {
    try {
      final doc = loadYaml(raw);
      return doc is YamlMap ? doc : null;
    } on YamlException {
      return null;
    }
  }

  // A half-written file must not throw: returns empty when unparseable.
  List<RoutingRule> get rules {
    final node = _root?['rules'];
    if (node is! YamlList) return const [];
    return parseRoutingRules(node.map((e) => e.toString()).toList());
  }

  // Throws ProfileRulesWriteException when the root is not a YAML map.
  String withRules(List<RoutingRule> rules) {
    final editor = _mapEditor();
    editor.update(['rules'], serializeRoutingRules(rules));
    return _render(editor);
  }

  // tun.exclude-package: the blacklist (these bypass the tunnel).
  List<String> get excludedPackages => _tunPackages('exclude-package');

  // tun.include-package: the whitelist (only these enter the tunnel). Its
  // presence is how the screen derives whitelist vs blacklist mode.
  List<String> get includedPackages => _tunPackages('include-package');

  List<String> get subRuleNames {
    final node = _root?['sub-rules'];
    if (node is! YamlMap) return const [];
    return node.keys.map((e) => e.toString()).toList();
  }

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

  List<String> get proxyNames {
    final node = _root?['proxies'];
    if (node is! YamlList) return const [];
    return [
      for (final p in node)
        if (p is YamlMap && p['name'] != null) p['name'].toString(),
    ];
  }

  List<Map<String, dynamic>> get proxies {
    final node = _root?['proxies'];
    if (node is! YamlList) return const [];
    return [
      for (final p in node)
        if (p is YamlMap) (yamlToDart(p) as Map).cast<String, dynamic>(),
    ];
  }

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

  List<GroupSpec> get proxyGroups {
    final node = _root?['proxy-groups'];
    if (node is! YamlList) return const [];
    return [
      for (final g in node)
        if (g is YamlMap) GroupSpec.fromYaml(g),
    ];
  }

  String withProxyGroups(List<GroupSpec> groups) {
    final editor = _mapEditor();
    editor.update(['proxy-groups'], [for (final g in groups) g.raw]);
    return _render(editor);
  }

  Map<String, ProviderSpec> get proxyProviders => _providers('proxy-providers');

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

  String withProxyProviders(Map<String, ProviderSpec> providers) =>
      _withProviders('proxy-providers', providers);

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

  // Wraps a malformed file as a ProfileRulesWriteException the controller
  // catches, instead of an uncaught YamlException from the editor constructor.
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

  String withExcludedPackages(List<String> packages) =>
      _withTunPackages('exclude-package', packages);

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

// Only a change to the tun package sets needs a tunnel re-establish; every
// other routing change hot-reloads.
bool tunPackagesChanged(String before, String after) {
  bool sameSet(List<String> x, List<String> y) =>
      x.length == y.length && x.toSet().containsAll(y);
  final a = ProfileRulesDocument(before);
  final b = ProfileRulesDocument(after);
  return !sameSet(a.includedPackages, b.includedPackages) ||
      !sameSet(a.excludedPackages, b.excludedPackages);
}
