import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';

const _unset = Object();

sealed class Destination {
  const Destination();
}

final class ToVpn extends Destination {
  const ToVpn();
}

final class ToBypass extends Destination {
  const ToBypass();
}

final class ToBlock extends Destination {
  const ToBlock();
}

final class ToScenario extends Destination {
  final String name;

  const ToScenario(this.name);

  @override
  bool operator ==(Object other) => other is ToScenario && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

const toVpn = ToVpn();
const toBypass = ToBypass();
const toBlock = ToBlock();

enum TunnelMode { whitelist, blacklist, all }

enum ListKind { url, paste, country }

class RoutingList {
  final String id;
  final String name;
  final ListKind kind;
  final String? url;
  final String? behavior;
  final String? format;
  final List<String> payload;
  final String? countryCode;

  const RoutingList({
    required this.id,
    required this.name,
    required this.kind,
    this.url,
    this.behavior,
    this.format,
    this.payload = const [],
    this.countryCode,
  });

  RoutingList copyWith({String? name, String? behavior, String? format}) =>
      RoutingList(
        id: id,
        name: name ?? this.name,
        kind: kind,
        url: url,
        behavior: behavior ?? this.behavior,
        format: format ?? this.format,
        payload: payload,
        countryCode: countryCode,
      );
}

sealed class ScenarioRule {
  const ScenarioRule();
}

final class ListRule extends ScenarioRule {
  final String listId;
  final Destination dest;

  const ListRule({required this.listId, required this.dest});
}

final class CountryRule extends ScenarioRule {
  final String countryCode;
  final Destination dest;
  final bool noResolve;

  const CountryRule({
    required this.countryCode,
    required this.dest,
    this.noResolve = true,
  });
}

final class MatchRule extends ScenarioRule {
  final RuleAction action;
  final String value;
  final Destination dest;
  final bool noResolve;
  final bool src;

  const MatchRule({
    required this.action,
    required this.value,
    required this.dest,
    this.noResolve = false,
    this.src = false,
  });
}

final class LogicRule extends ScenarioRule {
  final RuleAction op;
  final List<LogicalClause> clauses;
  final Destination dest;
  final bool noResolve;
  final bool src;

  const LogicRule({
    required this.op,
    required this.clauses,
    required this.dest,
    this.noResolve = false,
    this.src = false,
  });
}

final class RawScenarioRule extends ScenarioRule {
  final RoutingRule raw;

  const RawScenarioRule(this.raw);
}

class Scenario {
  final String name;
  final List<ScenarioRule> rules;
  final Destination? defaultDest;

  const Scenario({required this.name, required this.rules, this.defaultDest});
}

class AppAssignment {
  final String packageName;
  final Destination dest;

  const AppAssignment({required this.packageName, required this.dest});
}

sealed class ServerSource {
  final String name;

  const ServerSource(this.name);

  const factory ServerSource.node({
    required String name,
    required Map<String, dynamic> proxy,
  }) = NodeSource;

  const factory ServerSource.subscription({
    required String name,
    required String? url,
    Map<String, dynamic>? xray,
  }) = SubscriptionSource;
}

final class NodeSource extends ServerSource {
  final Map<String, dynamic> proxy;

  const NodeSource({required String name, required this.proxy}) : super(name);
}

final class SubscriptionSource extends ServerSource {
  final String? url;

  final Map<String, dynamic>? xray;

  const SubscriptionSource({required String name, required this.url, this.xray})
    : super(name);
}

// Maps to clash types: autoFastest -> url-test, failover -> fallback, manual -> select.
enum GroupBehavior { autoFastest, failover, manual }

sealed class ServerGroup {
  const ServerGroup();

  String get name;
}

final class SmartGroup extends ServerGroup {
  @override
  final String name;
  final GroupBehavior behavior;
  final List<String> members;

  final List<String> use;
  final String? filter;
  final int? interval;
  final bool lazy;

  final String? url;
  final bool hidden;
  final int? tolerance;

  final Map<String, dynamic> extra;

  const SmartGroup({
    required this.name,
    required this.behavior,
    this.members = const [],
    this.use = const [],
    this.filter,
    this.interval,
    this.lazy = false,
    this.url,
    this.hidden = false,
    this.tolerance,
    this.extra = const {},
  });

  SmartGroup copyWith({
    String? name,
    GroupBehavior? behavior,
    List<String>? members,
    List<String>? use,
    Object? filter = _unset,
    Object? interval = _unset,
    bool? lazy,
    Object? url = _unset,
    bool? hidden,
    Object? tolerance = _unset,
    Map<String, dynamic>? extra,
  }) => SmartGroup(
    name: name ?? this.name,
    behavior: behavior ?? this.behavior,
    members: members ?? this.members,
    use: use ?? this.use,
    filter: identical(filter, _unset) ? this.filter : filter as String?,
    interval: identical(interval, _unset) ? this.interval : interval as int?,
    lazy: lazy ?? this.lazy,
    url: identical(url, _unset) ? this.url : url as String?,
    hidden: hidden ?? this.hidden,
    tolerance: identical(tolerance, _unset)
        ? this.tolerance
        : tolerance as int?,
    extra: extra ?? this.extra,
  );
}

final class RawGroup extends ServerGroup {
  final GroupSpec spec;

  const RawGroup(this.spec);

  @override
  String get name => spec.name;
}

class RoutingModel {
  final String exitGroup;
  final List<RoutingList> lists;
  final List<Scenario> scenarios;
  final List<AppAssignment> apps;

  final List<ScenarioRule> globalRules;

  // The terminal MATCH target as a policy: block (fail-closed whitelist), viaVpn
  // (full tunnel), direct, or null. A non-policy MATCH,<group> is kept raw below.
  final Destination? defaultRoute;

  // A non-policy terminal MATCH,<group>, kept verbatim and written LAST so it is
  // never relocated above per-app rules (MATCH matches all, so a misplaced
  // terminal shadows every per-app rule).
  final RoutingRule? terminalRaw;

  final List<ServerSource> servers;
  final List<ServerGroup> groups;

  final TunnelMode tunnelMode;

  final bool degenerateBoth;

  const RoutingModel({
    required this.exitGroup,
    required this.lists,
    required this.scenarios,
    required this.apps,
    this.globalRules = const [],
    this.defaultRoute,
    this.terminalRaw,
    this.servers = const [],
    this.groups = const [],
    this.tunnelMode = TunnelMode.whitelist,
    this.degenerateBoth = false,
  });

  // Never throws on a malformed file; yields an empty overlay.
  static RoutingModel fromYaml(String raw) => _read(raw);

  // Touches only managed blocks; unmanaged YAML (DNS/sniffer/mesh/comments) round-trips verbatim.
  String toYaml(String base) => _write(this, base);

  RoutingModel copyWith({
    String? exitGroup,
    List<RoutingList>? lists,
    List<Scenario>? scenarios,
    List<AppAssignment>? apps,
    List<ScenarioRule>? globalRules,
    Destination? defaultRoute,
    RoutingRule? terminalRaw,
    List<ServerSource>? servers,
    List<ServerGroup>? groups,
    TunnelMode? tunnelMode,
    bool? degenerateBoth,
  }) => RoutingModel(
    exitGroup: exitGroup ?? this.exitGroup,
    lists: lists ?? this.lists,
    scenarios: scenarios ?? this.scenarios,
    apps: apps ?? this.apps,
    globalRules: globalRules ?? this.globalRules,
    defaultRoute: defaultRoute ?? this.defaultRoute,
    terminalRaw: terminalRaw ?? this.terminalRaw,
    servers: servers ?? this.servers,
    groups: groups ?? this.groups,
    tunnelMode: tunnelMode ?? this.tunnelMode,
    degenerateBoth: degenerateBoth ?? this.degenerateBoth,
  );

  RoutingModel renameGroup(String from, String to) {
    if (from == to || from.isEmpty) return this;
    List<String> ren(List<String> xs) => _replaceName(xs, from, to);
    return copyWith(
      exitGroup: exitGroup == from ? to : exitGroup,
      groups: [
        for (final g in groups)
          switch (g) {
            SmartGroup() => g.copyWith(
              name: g.name == from ? to : g.name,
              members: ren(g.members),
            ),
            RawGroup(:final spec) => RawGroup(
              spec.copyWith(
                name: spec.name == from ? to : spec.name,
                proxies: ren(spec.proxies),
              ),
            ),
          },
      ],
    );
  }

  RoutingModel renameServer(String from, String to) {
    if (from == to || from.isEmpty || to.isEmpty) return this;
    List<String> ren(List<String> xs) => _replaceName(xs, from, to);
    return copyWith(
      exitGroup: exitGroup == from ? to : exitGroup,
      servers: [
        for (final s in servers)
          if (s.name != from)
            s
          else
            switch (s) {
              NodeSource(:final proxy) => ServerSource.node(
                name: to,
                proxy: {...proxy, 'name': to},
              ),
              SubscriptionSource(:final url, :final xray) =>
                ServerSource.subscription(name: to, url: url, xray: xray),
            },
      ],
      groups: [
        for (final g in groups)
          switch (g) {
            SmartGroup() => g.copyWith(
              members: ren(g.members),
              use: ren(g.use),
            ),
            RawGroup(:final spec) => RawGroup(
              spec.copyWith(proxies: ren(spec.proxies), use: ren(spec.use)),
            ),
          },
      ],
    );
  }

  RoutingModel renameScenario(String from, String to) {
    if (from == to || from.isEmpty || to.isEmpty) return this;
    List<ScenarioRule> remap(List<ScenarioRule> rows) => [
      for (final r in rows) _renameDestScenario(r, from, to),
    ];
    return copyWith(
      scenarios: [
        for (final s in scenarios)
          Scenario(
            name: s.name == from ? to : s.name,
            rules: remap(s.rules),
            defaultDest: s.defaultDest,
          ),
      ],
      globalRules: remap(globalRules),
      apps: [
        for (final a in apps)
          if (a.dest case ToScenario(:final name) when name == from)
            AppAssignment(packageName: a.packageName, dest: ToScenario(to))
          else
            a,
      ],
    );
  }

  RoutingModel removeServer(String name) {
    if (name.isEmpty) return this;
    final scrubbed = _dropGroupRef(groups, name, includeUse: true);
    final pruned = _pruneEmptyGroups(scrubbed, exitGroup);
    return copyWith(
      servers: [
        for (final s in servers)
          if (s.name != name) s,
      ],
      groups: pruned.groups,
      exitGroup: pruned.exitGroup,
    );
  }

  RoutingModel removeGroup(String name) {
    if (name.isEmpty) return this;
    final remaining = <ServerGroup>[
      for (final g in groups)
        if (g.name != name) g,
    ];
    final scrubbed = _dropGroupRef(remaining, name, includeUse: false);
    final exitAfterRemoval = exitGroup == name
        ? (scrubbed.isEmpty ? '' : scrubbed.first.name)
        : exitGroup;
    final pruned = _pruneEmptyGroups(scrubbed, exitAfterRemoval);
    return copyWith(exitGroup: pruned.exitGroup, groups: pruned.groups);
  }

  // True when [name] is the target of an explicit (raw) rule or the raw terminal
  // MATCH. Modeled rules route only to VPN/DIRECT/REJECT/scenarios, so a rule
  // naming a specific proxy or non-exit group survives only as a RawScenarioRule.
  bool isReferencedByRule(String name) {
    bool hit(ScenarioRule r) =>
        r is RawScenarioRule && policyTargetOf(r.raw) == name;
    if (globalRules.any(hit)) return true;
    if (scenarios.any((s) => s.rules.any(hit))) return true;
    final t = terminalRaw;
    return t != null && policyTargetOf(t) == name;
  }

  // A node's dialer-proxy chains through another proxy/group by name; deleting
  // the referenced entity would silently break the chain, so deletion is
  // restricted rather than cascaded.
  bool isReferencedByProxyChain(String name) => servers.any(
    (s) => s is NodeSource && s.name != name && s.proxy['dialer-proxy'] == name,
  );

  RoutingModel removeList(String id) {
    if (id.isEmpty) return this;
    bool keep(ScenarioRule r) => r is! ListRule || r.listId != id;
    return copyWith(
      lists: [
        for (final l in lists)
          if (l.id != id) l,
      ],
      globalRules: [
        for (final r in globalRules)
          if (keep(r)) r,
      ],
      scenarios: [
        for (final s in scenarios)
          Scenario(
            name: s.name,
            rules: [
              for (final r in s.rules)
                if (keep(r)) r,
            ],
            defaultDest: s.defaultDest,
          ),
      ],
    );
  }

  RoutingModel updateNode(String from, Map<String, dynamic> proxy) {
    final to = (proxy['name'] ?? from).toString();
    final base = from == to ? this : renameServer(from, to);
    return base.copyWith(
      servers: [
        for (final s in base.servers)
          if (s is NodeSource && s.name == to)
            ServerSource.node(name: to, proxy: proxy)
          else
            s,
      ],
    );
  }

  // happ == null leaves the Happ/xray marker as-is; true sets it (per-remark,
  // fetched as Happ at apply), false clears it (honest fetch, native clash).
  RoutingModel updateSubscription(String name, {String? url, bool? happ}) =>
      copyWith(
        servers: [
          for (final s in servers)
            if (s is SubscriptionSource && s.name == name)
              ServerSource.subscription(
                name: name,
                url: url ?? s.url,
                xray: happ == null
                    ? s.xray
                    : (happ ? const {'groups': 'by-remark'} : null),
              )
            else
              s,
        ],
      );
}

// Preserves each filtering mode's own app selection across a switch: leaving a mode
// stashes its packages; entering one restores its stash when the profile carries none.
({RoutingModel model, List<String> stashInclude, List<String> stashExclude})
switchTunnelMode({
  required RoutingModel current,
  required List<String> stashInclude,
  required List<String> stashExclude,
  required TunnelMode newMode,
}) {
  List<String> includeOf(RoutingModel m) => [
    for (final a in m.apps)
      if (a.dest is! ToBypass) a.packageName,
  ];
  List<String> excludeOf(RoutingModel m) => [
    for (final a in m.apps)
      if (a.dest is ToBypass) a.packageName,
  ];

  var nextInclude = stashInclude;
  var nextExclude = stashExclude;
  switch (current.tunnelMode) {
    case TunnelMode.whitelist:
      nextInclude = includeOf(current);
    case TunnelMode.blacklist:
      nextExclude = excludeOf(current);
    case TunnelMode.all:
      break;
  }

  final List<AppAssignment> apps;
  switch (newMode) {
    case TunnelMode.whitelist:
      final cur = includeOf(current);
      apps = [
        for (final p in cur.isNotEmpty ? cur : nextInclude)
          AppAssignment(packageName: p, dest: toVpn),
      ];
    case TunnelMode.blacklist:
      final cur = excludeOf(current);
      apps = [
        for (final p in cur.isNotEmpty ? cur : nextExclude)
          AppAssignment(packageName: p, dest: toBypass),
      ];
    case TunnelMode.all:
      apps = current.apps;
  }

  return (
    model: current.copyWith(
      tunnelMode: newMode,
      apps: apps,
      degenerateBoth: false,
      defaultRoute: newMode == TunnelMode.whitelist
          ? current.defaultRoute
          : toVpn,
    ),
    stashInclude: nextInclude,
    stashExclude: nextExclude,
  );
}

List<String> _replaceName(List<String> xs, String from, String to) => [
  for (final x in xs) x == from ? to : x,
];

// Removes SmartGroups left with no members and no `use:` (a select/url-test group
// with neither is invalid); iterates because pruning one group can empty another.
// RawGroups are user-authored and never pruned. Repoints the exit off a pruned group.
({List<ServerGroup> groups, String exitGroup}) _pruneEmptyGroups(
  List<ServerGroup> groups,
  String exitGroup,
) {
  var current = groups;
  var exit = exitGroup;
  while (true) {
    final empties = {
      for (final g in current)
        if (g is SmartGroup && g.members.isEmpty && g.use.isEmpty) g.name,
    };
    if (empties.isEmpty) break;
    var next = <ServerGroup>[
      for (final g in current)
        if (!empties.contains(g.name)) g,
    ];
    for (final name in empties) {
      next = _dropGroupRef(next, name, includeUse: false);
    }
    current = next;
    if (empties.contains(exit)) {
      exit = current.isEmpty ? '' : current.first.name;
    }
  }
  return (groups: current, exitGroup: exit);
}

// includeUse also strips the `use:` provider list (a removed server can back a
// group); a removed group only ever appears in members/proxies, never in `use:`.
List<ServerGroup> _dropGroupRef(
  List<ServerGroup> groups,
  String name, {
  required bool includeUse,
}) {
  List<String> drop(List<String> xs) => [
    for (final x in xs)
      if (x != name) x,
  ];
  return [
    for (final g in groups)
      switch (g) {
        SmartGroup() => g.copyWith(
          members: drop(g.members),
          use: includeUse ? drop(g.use) : g.use,
        ),
        RawGroup(:final spec) => RawGroup(
          spec.copyWith(
            proxies: drop(spec.proxies),
            use: includeUse ? drop(spec.use) : spec.use,
          ),
        ),
      },
  ];
}

String _write(RoutingModel m, String base) {
  var out = _writeServers(m, base);

  final managedProviderIds = {
    for (final l in m.lists)
      if (l.kind != ListKind.country) l.id,
  };

  final baseProviders = ProfileRulesDocument(out).ruleProviders;
  final providers = <String, ProviderSpec>{};
  for (final l in m.lists) {
    if (l.kind == ListKind.country) continue;
    providers[l.id] = _listToProvider(l, baseProviders[l.id]);
  }
  // Preserve any rule-provider the model never adopted (defensive; today every
  // provider maps to a List, so this is empty on a round-trip).
  for (final e in baseProviders.entries) {
    if (!managedProviderIds.contains(e.key)) providers[e.key] = e.value;
  }

  out = ProfileRulesDocument(out).withRuleProviders(providers);
  out = ProfileRulesDocument(
    out,
  ).withSubRules({for (final s in m.scenarios) s.name: _scenarioToRules(m, s)});
  out = _writeTunnelPackages(m, out);
  return _writeRulesBlock(m, out);
}

// Whitelist fail-closed sentinel: kept in `include-package` when no app is routed
// via VPN, because an absent key makes Android VpnService capture ALL apps. It is
// the app's own package (force-added natively anyway) and is filtered out on read.
const routingOwnPackageSentinel = 'com.follow.clash';

// Each branch clears the unused package key, so a mode switch never leaves a stale list.
String _writeTunnelPackages(RoutingModel m, String base) {
  if (m.tunnelMode == TunnelMode.all) {
    // Drop both keys so Android VpnService captures every app (absent key = capture all).
    final out = ProfileRulesDocument(base).withIncludedPackages(const []);
    return ProfileRulesDocument(out).withExcludedPackages(const []);
  }
  if (m.tunnelMode == TunnelMode.blacklist) {
    final exclude = [
      for (final a in m.apps)
        if (a.dest is ToBypass) a.packageName,
    ];
    // Keep the key (via the sentinel) even with no exceptions, so the mode is
    // durable: an absent key would read back as whitelist and flip the default.
    final out = ProfileRulesDocument(base).withIncludedPackages(const []);
    return ProfileRulesDocument(out).withExcludedPackages(
      exclude.isEmpty ? const [routingOwnPackageSentinel] : exclude,
    );
  }
  final include = [
    for (final a in m.apps)
      if (a.dest is! ToBypass) a.packageName,
  ];
  final out = ProfileRulesDocument(base).withExcludedPackages(const []);
  return ProfileRulesDocument(out).withIncludedPackages(
    include.isEmpty ? const [routingOwnPackageSentinel] : include,
  );
}

// Materializes the server layer only when the model owns it (servers/groups
// non-empty). A routing-only or paste-and-go model leaves proxies/providers/
// groups untouched, so those paths never wipe an existing exit.
String _writeServers(RoutingModel m, String base) {
  if (m.servers.isEmpty && m.groups.isEmpty) return base;
  final doc = ProfileRulesDocument(base);
  final baseProviders = doc.proxyProviders;
  final baseGroups = {for (final g in doc.proxyGroups) g.name: g};

  var out = base;
  if (m.servers.isNotEmpty) {
    out = ProfileRulesDocument(out).withProxies([
      for (final s in m.servers)
        if (s is NodeSource) s.proxy,
    ]);
    out = ProfileRulesDocument(out).withProxyProviders({
      for (final s in m.servers)
        if (s is SubscriptionSource)
          s.name: _subToProvider(s, baseProviders[s.name]),
    });
  }
  if (m.groups.isNotEmpty) {
    out = ProfileRulesDocument(
      out,
    ).withProxyGroups([for (final g in m.groups) _groupToSpec(g, baseGroups)]);
  }
  return out;
}

ProviderSpec _subToProvider(SubscriptionSource s, ProviderSpec? existing) {
  final base = (existing ?? ProviderSpec.create(type: 'http')).copyWith(
    type: 'http',
    url: s.url,
  );
  // An xray/Happ subscription carries the `xray:` marker so setup's prefetch
  // fetches + converts it; a plain http subscription drops it (honest fetch),
  // so toggling Happ off clears a previously-set marker instead of keeping it.
  final raw = {...base.raw}..remove('xray');
  return s.xray == null
      ? ProviderSpec(raw)
      : ProviderSpec({...raw, 'xray': s.xray});
}

GroupSpec _groupToSpec(ServerGroup g, Map<String, GroupSpec> baseGroups) =>
    switch (g) {
      RawGroup(:final spec) => spec,
      SmartGroup() => _smartToSpec(g, baseGroups[g.name]),
    };

GroupSpec _smartToSpec(SmartGroup g, GroupSpec? base) {
  final spec =
      (base ?? GroupSpec.create(name: g.name, type: _groupType(g.behavior)))
          .copyWith(
            name: g.name,
            type: _groupType(g.behavior),
            // Leave proxies untouched for a pure provider-backed group so it
            // never gains a spurious empty `proxies:` key.
            proxies: g.use.isNotEmpty && g.members.isEmpty ? null : g.members,
            use: g.use,
            filter: g.filter,
            interval: g.interval,
            lazy: g.lazy,
            url: g.url,
            hidden: g.hidden,
            tolerance: g.tolerance,
          );
  if (g.extra.isEmpty) return spec;
  final m = Map<String, dynamic>.of(spec.raw);
  g.extra.forEach((k, v) => m[k] = v);
  return GroupSpec(m);
}

String _groupType(GroupBehavior b) => switch (b) {
  GroupBehavior.autoFastest => 'url-test',
  GroupBehavior.failover => 'fallback',
  GroupBehavior.manual => 'select',
};

// Never called with ToScenario; _ruleFor intercepts those into a SUB-RULE.
String _targetOf(RoutingModel m, Destination d) => switch (d) {
  ToVpn() => m.exitGroup,
  ToBypass() => 'DIRECT',
  ToBlock() => 'REJECT',
  ToScenario() => throw ArgumentError('scenario dest has no plain target'),
};

// A scenario target wraps the condition in a SUB-RULE, folding src/no-resolve into
// the clause params so it round-trips; every other target is a plain typed rule.
RoutingRule _ruleFor(
  RoutingModel m,
  RuleAction action,
  String value,
  Destination dest, {
  bool noResolve = false,
  bool src = false,
}) {
  if (dest case ToScenario(:final name)) {
    final params = [
      value,
      if (src) 'src',
      if (noResolve) 'no-resolve',
    ].where((e) => e.isNotEmpty).join(',');
    return SubRuleRoute(action: action, params: params, subRuleName: name);
  }
  return TypedRule(
    action: action,
    value: value,
    target: _targetOf(m, dest),
    noResolve: noResolve,
    src: src,
  );
}

ProviderSpec _listToProvider(RoutingList l, ProviderSpec? existing) {
  final base = existing ?? ProviderSpec.create(type: 'http');
  if (l.kind == ListKind.paste) {
    final m = Map<String, dynamic>.of(base.raw)
      ..['type'] = 'inline'
      ..['payload'] = List<String>.of(l.payload)
      ..remove('url');
    if (l.behavior != null) m['behavior'] = l.behavior;
    return ProviderSpec(m);
  }
  return base.copyWith(
    type: 'http',
    url: l.url,
    behavior: l.behavior,
    format: l.format,
  );
}

List<RoutingRule> _rowsToRules(RoutingModel m, List<ScenarioRule> rows) => [
  for (final row in rows)
    switch (row) {
      ListRule(:final listId, :final dest) => _ruleFor(
        m,
        RuleAction.RULE_SET,
        listId,
        dest,
      ),
      CountryRule(:final countryCode, :final dest, :final noResolve) =>
        _ruleFor(m, RuleAction.GEOIP, countryCode, dest, noResolve: noResolve),
      MatchRule(
        :final action,
        :final value,
        :final dest,
        :final noResolve,
        :final src,
      ) =>
        _ruleFor(m, action, value, dest, noResolve: noResolve, src: src),
      LogicRule(
        :final op,
        :final clauses,
        :final dest,
        :final noResolve,
        :final src,
      ) =>
        LogicalRule(
          op: op,
          clauses: clauses,
          target: _targetOf(m, dest),
          noResolve: noResolve,
          src: src,
        ),
      RawScenarioRule(:final raw) => raw,
    },
];

List<RoutingRule> _scenarioToRules(RoutingModel m, Scenario s) {
  final out = _rowsToRules(m, s.rules);
  final def = s.defaultDest;
  if (def == null) return out;
  return [
    ...out,
    TypedRule(action: RuleAction.MATCH, value: '', target: _targetOf(m, def)),
  ];
}

// Order is load-bearing (mihomo first-match): safety carve-outs, then per-app,
// then policy, then the terminal MATCH. Per-app overrides policy but never the
// safety rules (LAN/loopback/anti-leak), and MATCH can only ever be last.
String _writeRulesBlock(RoutingModel m, String yaml) {
  final safety = <ScenarioRule>[];
  final policy = <ScenarioRule>[];
  for (final r in m.globalRules) {
    (_isSafetyRule(r) ? safety : policy).add(r);
  }
  final next = <RoutingRule>[
    ..._rowsToRules(m, safety),
    for (final a in m.apps)
      if (_appRule(m, a) case final rule?) rule,
    ..._rowsToRules(m, policy),
    if (m.defaultRoute case final def?)
      TypedRule(action: RuleAction.MATCH, value: '', target: _targetOf(m, def)),
    if (m.terminalRaw case final t?) t,
  ];
  return ProfileRulesDocument(yaml).withRules(next);
}

// A safety carve-out is a DIRECT network rule for a reserved/private/loopback
// range or a single host: an app routed "via VPN" above it would pull LAN /
// loopback / the proxy server into the tunnel (broken net or an anti-leak loop).
bool _isSafetyRule(ScenarioRule r) {
  if (_rowDest(r) is! ToBypass) return false;
  return switch (r) {
    CountryRule(:final countryCode) => const {
      'private',
      'lan',
    }.contains(countryCode.toLowerCase()),
    MatchRule(:final action, :final value) =>
      (action == RuleAction.IP_CIDR || action == RuleAction.IP_CIDR6) &&
          _isReservedOrHostCidr(value),
    _ => false,
  };
}

// True for a single-host route (/32, /128 — the anti-leak shape) or a CIDR whose
// base is reserved/private/loopback/link-local/CGNAT/multicast.
bool _isReservedOrHostCidr(String cidr) {
  final slash = cidr.indexOf('/');
  final addr = slash == -1 ? cidr : cidr.substring(0, slash);
  final prefix = slash == -1 ? null : int.tryParse(cidr.substring(slash + 1));
  final ip = InternetAddress.tryParse(addr);
  if (ip == null) return false;
  final b = ip.rawAddress;
  if (ip.type == InternetAddressType.IPv4) {
    if (prefix == 32) return true;
    return b[0] == 0 ||
        b[0] == 10 ||
        b[0] == 127 ||
        (b[0] == 100 && b[1] >= 64 && b[1] <= 127) ||
        (b[0] == 169 && b[1] == 254) ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 && b[1] == 168) ||
        (b[0] == 198 && (b[1] == 18 || b[1] == 19)) ||
        b[0] >= 224;
  }
  if (prefix == 128) return true;
  return b[0] == 0xff ||
      (b[0] & 0xfe) == 0xfc ||
      (b[0] == 0xfe && (b[1] & 0xc0) == 0x80) ||
      b.every((x) => x == 0);
}

RoutingRule? _appRule(RoutingModel m, AppAssignment a) => switch (a.dest) {
  ToScenario(:final name) => AppToSubRuleRoute(
    packageName: a.packageName,
    subRuleName: name,
  ),
  ToVpn() => TypedRule(
    action: RuleAction.PROCESS_NAME,
    value: a.packageName,
    target: m.exitGroup,
  ),
  ToBlock() => TypedRule(
    action: RuleAction.PROCESS_NAME,
    value: a.packageName,
    target: 'REJECT',
  ),
  ToBypass() => null,
};

RoutingModel _read(String raw) {
  final doc = ProfileRulesDocument(raw);
  final groupNames = doc.proxyGroups.map((g) => g.name).toSet();
  final exit = _detectExit(doc, groupNames);

  Destination? destOf(String target) {
    if (target == exit) return toVpn;
    if (target == 'REJECT') return toBlock;
    if (target == 'DIRECT') return toBypass;
    return null;
  }

  final lists = <RoutingList>[
    for (final e in doc.ruleProviders.entries)
      RoutingList(
        id: e.key,
        name: e.key,
        kind: ListKind.url,
        url: e.value.url,
        behavior: e.value.behavior,
        format: e.value.format,
      ),
  ];

  final scenarios = <Scenario>[];
  for (final entry in doc.subRules.entries) {
    final body = entry.value;
    final rows = <ScenarioRule>[];
    Destination? defaultDest;
    for (var i = 0; i < body.length; i++) {
      final r = body[i];
      final isLast = i == body.length - 1;
      if (isLast &&
          r is TypedRule &&
          r.action == RuleAction.MATCH &&
          destOf(r.target) != null) {
        defaultDest = destOf(r.target);
        continue;
      }
      rows.add(_modelRow(r, destOf) ?? RawScenarioRule(r));
    }
    scenarios.add(
      Scenario(name: entry.key, rules: rows, defaultDest: defaultDest),
    );
  }

  final servers = <ServerSource>[
    for (final p in doc.proxies)
      if (p['name'] != null)
        ServerSource.node(name: p['name'].toString(), proxy: p),
    for (final e in doc.proxyProviders.entries)
      ServerSource.subscription(
        name: e.key,
        url: e.value.url,
        xray: e.value.raw['xray'] is Map
            ? (e.value.raw['xray'] as Map).cast<String, dynamic>()
            : null,
      ),
  ];
  final groups = [for (final g in doc.proxyGroups) _readGroup(g)];

  final topRules = doc.rules;
  final terminal =
      topRules.isNotEmpty &&
          topRules.last is TypedRule &&
          (topRules.last as TypedRule).action == RuleAction.MATCH
      ? topRules.last as TypedRule
      : null;
  // Only a terminal MATCH to a base policy (exit/DIRECT/REJECT) is the modeled
  // default route; a non-policy MATCH,<group> is kept verbatim (terminalRaw) and
  // re-emitted last, so it is not folded into globalRules and hoisted above the
  // per-app rules it would otherwise shadow.
  final defaultRoute = terminal != null ? destOf(terminal.target) : null;
  final terminalRaw = terminal != null && defaultRoute == null
      ? terminal
      : null;

  // One destination per package (dedup); a LinkedHashMap keeps first-seen order.
  final appByPkg = <String, Destination>{};
  final globalRules = <ScenarioRule>[];
  for (var i = 0; i < topRules.length; i++) {
    if ((defaultRoute != null || terminalRaw != null) &&
        i == topRules.length - 1) {
      continue;
    }
    final r = topRules[i];
    if (r is AppToSubRuleRoute) {
      appByPkg[r.packageName] = ToScenario(r.subRuleName);
    } else if (r is TypedRule && r.action == RuleAction.PROCESS_NAME) {
      appByPkg[r.value] = destOf(r.target) ?? toVpn;
    } else {
      globalRules.add(_modelRow(r, destOf) ?? RawScenarioRule(r));
    }
  }

  // Mode from the tun keys: neither -> all, exclude-only -> blacklist, else whitelist.
  // Both present is unrepresentable, so it reads as whitelist (include - exclude) and
  // raises degenerateBoth. The sentinel keeps an empty whitelist non-absent, not `all`.
  final hasInclude = doc.includedPackages.isNotEmpty;
  final hasExclude = doc.excludedPackages.isNotEmpty;
  final degenerateBoth = hasInclude && hasExclude;
  final tunnelMode = !hasInclude && !hasExclude
      ? TunnelMode.all
      : hasExclude && !hasInclude
      ? TunnelMode.blacklist
      : TunnelMode.whitelist;

  // A tunnel member with no rule is still via VPN; keep its membership so a
  // rewrite never strips include-package and fails open. The sentinel is not a
  // user app.
  for (final pkg in doc.includedPackages) {
    if (pkg == routingOwnPackageSentinel) continue;
    appByPkg.putIfAbsent(pkg, () => toVpn);
  }

  // OS-level exclusion is authoritative: an excluded package bypasses the VPN
  // even if a stray rule targets it, so an OS-excluded app is never upgraded.
  for (final pkg in doc.excludedPackages) {
    if (pkg == routingOwnPackageSentinel) continue;
    appByPkg[pkg] = toBypass;
  }

  final apps = [
    for (final e in appByPkg.entries)
      AppAssignment(packageName: e.key, dest: e.value),
  ];

  return RoutingModel(
    exitGroup: exit,
    lists: lists,
    scenarios: scenarios,
    apps: apps,
    globalRules: globalRules,
    defaultRoute: defaultRoute,
    terminalRaw: terminalRaw,
    servers: servers,
    groups: groups,
    tunnelMode: tunnelMode,
    degenerateBoth: degenerateBoth,
  );
}

ServerGroup _readGroup(GroupSpec g) {
  final behavior = switch (g.type) {
    'url-test' => GroupBehavior.autoFastest,
    'fallback' => GroupBehavior.failover,
    'select' => GroupBehavior.manual,
    _ => null,
  };
  if (behavior == null) return RawGroup(g);
  return SmartGroup(
    name: g.name,
    behavior: behavior,
    members: g.proxies,
    use: g.use,
    filter: g.filter,
    interval: g.interval,
    lazy: g.lazy,
    url: g.url,
    hidden: g.hidden,
    tolerance: g.tolerance,
    extra: g.extra,
  );
}

ScenarioRule? _modelRow(RoutingRule r, Destination? Function(String) destOf) {
  if (r is LogicalRule) {
    final d = destOf(r.target);
    return d == null
        ? null
        : LogicRule(
            op: r.op,
            clauses: r.clauses,
            dest: d,
            noResolve: r.noResolve,
            src: r.src,
          );
  }
  // A single-clause SUB-RULE routes an ordinary matcher to a scenario; flags
  // stay folded in the clause params so it re-serializes byte-for-byte.
  if (r is SubRuleRoute) {
    return _matcherRow(r.action, r.params, ToScenario(r.subRuleName));
  }
  if (r is! TypedRule || r.action == RuleAction.MATCH) return null;
  final d = destOf(r.target);
  if (d == null) return null; // target is some other group -> keep raw
  return _matcherRow(r.action, r.value, d, noResolve: r.noResolve, src: r.src);
}

ScenarioRule _matcherRow(
  RuleAction action,
  String value,
  Destination dest, {
  bool noResolve = false,
  bool src = false,
}) => switch (action) {
  RuleAction.RULE_SET => ListRule(listId: value, dest: dest),
  RuleAction.GEOIP => CountryRule(
    countryCode: value,
    dest: dest,
    noResolve: noResolve,
  ),
  _ => MatchRule(
    action: action,
    value: value,
    dest: dest,
    noResolve: noResolve,
    src: src,
  ),
};

Destination? _rowDest(ScenarioRule r) => switch (r) {
  ListRule(:final dest) => dest,
  CountryRule(:final dest) => dest,
  MatchRule(:final dest) => dest,
  LogicRule(:final dest) => dest,
  RawScenarioRule() => null,
};

ScenarioRule _withDest(ScenarioRule r, Destination dest) => switch (r) {
  ListRule(:final listId) => ListRule(listId: listId, dest: dest),
  CountryRule(:final countryCode, :final noResolve) => CountryRule(
    countryCode: countryCode,
    dest: dest,
    noResolve: noResolve,
  ),
  MatchRule(:final action, :final value, :final noResolve, :final src) =>
    MatchRule(
      action: action,
      value: value,
      dest: dest,
      noResolve: noResolve,
      src: src,
    ),
  LogicRule(:final op, :final clauses, :final noResolve, :final src) =>
    LogicRule(
      op: op,
      clauses: clauses,
      dest: dest,
      noResolve: noResolve,
      src: src,
    ),
  RawScenarioRule() => r,
};

ScenarioRule _renameDestScenario(ScenarioRule r, String from, String to) {
  if (_rowDest(r) case ToScenario(:final name) when name == from) {
    return _withDest(r, ToScenario(to));
  }
  return r;
}

// The exit group is the target of the "all via VPN" scenario (a single
// MATCH,<group>); else the first non-hidden group; else 'PROXY' (Part I default).
String _detectExit(ProfileRulesDocument doc, Set<String> groupNames) {
  for (final body in doc.subRules.values) {
    if (body.length != 1) continue;
    final only = body.first;
    if (only is TypedRule &&
        only.action == RuleAction.MATCH &&
        groupNames.contains(only.target)) {
      return only.target;
    }
  }
  final groups = doc.proxyGroups;
  final nonHidden = groups.where((g) => g.raw['hidden'] != true).toList();
  if (nonHidden.isNotEmpty) return nonHidden.first.name;
  if (groups.isNotEmpty) return groups.first.name;
  return 'PROXY';
}
