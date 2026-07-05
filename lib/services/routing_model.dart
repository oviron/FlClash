library;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';

const _unset = Object();

/// Where matched traffic goes, in human terms. One target vocabulary for rules
/// and apps alike: the VPN, bypass (direct), block, or a named scenario. A
/// [ToScenario] target serializes as a `SUB-RULE` and is on par with the rest.
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

/// Whether the profile tunnels a whitelist (`include-package`, only these apps
/// enter) or a blacklist (`exclude-package`, all except these).
enum TunnelMode { whitelist, blacklist }

/// How a [RoutingList] is backed. Every list is the user's own: a rule-set URL,
/// pasted domains, or a country (GEOIP). No curated/catalog content.
enum ListKind { url, paste, country }

/// A named matcher. `catalog`/`url`/`paste` are backed by a rule-provider and
/// referenced by [id] in `RULE-SET,<id>`; `country` carries a [countryCode] and
/// renders as `GEOIP,<cc>` with no provider.
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

/// One ordered row inside a [Scenario]. Cleanly-mapped rows become [ListRule]/
/// [CountryRule]; anything else is kept verbatim as [RawScenarioRule] so it
/// round-trips and surfaces as "Custom / Advanced".
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

/// A typed matcher (`DOMAIN`, `DOMAIN-SUFFIX`, `IP-CIDR`, `PROCESS-NAME`, …)
/// whose target is a human [Destination]. Carries the raw [action]/[value] so it
/// round-trips verbatim while its destination stays editable.
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

/// A logical matcher (`AND`/`OR`/`NOT` over flat clauses) whose target is a
/// human [Destination]. Carries the raw clauses so it round-trips verbatim.
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

/// An ordered set of rows plus a default, mapped to a named `sub-rules:` entry.
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

/// A single node (inline proxy from a pasted link) or a subscription (a
/// proxy-provider from a URL). Both are "servers" to the user; never typed.
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
  }) = SubscriptionSource;
}

final class NodeSource extends ServerSource {
  final Map<String, dynamic> proxy;

  const NodeSource({required String name, required this.proxy}) : super(name);
}

final class SubscriptionSource extends ServerSource {
  final String? url;

  const SubscriptionSource({required String name, required this.url})
    : super(name);
}

/// A human server-selection behavior. `autoFastest` -> `url-test`, `failover` ->
/// `fallback`, `manual` -> `select`; the clash type never surfaces.
enum GroupBehavior { autoFastest, failover, manual }

/// A group of servers. [SmartGroup] is a clean behavior; anything else
/// (provider-backed `use:`, `filter:`, load-balance, relay) is kept verbatim as
/// [RawGroup] so a power-user mesh round-trips and shows only under Advanced.
sealed class ServerGroup {
  const ServerGroup();

  String get name;
}

final class SmartGroup extends ServerGroup {
  @override
  final String name;
  final GroupBehavior behavior;
  final List<String> members;

  /// Provider sources (`use:`) the group draws members from, and an optional
  /// regex `filter:` over them. The common subscription-backed shape.
  final List<String> use;
  final String? filter;
  final int? interval;
  final bool lazy;

  /// Health-check URL (url-test/fallback), the `hidden` flag, and url-test
  /// `tolerance` (ms) as first-class fields.
  final String? url;
  final bool hidden;
  final int? tolerance;

  /// Group keys the editor does not model (`icon`, `exclude-filter`, ...),
  /// carried so a rename or a fresh write never drops them.
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

/// The human-language overlay over a mihomo config: which apps enter the VPN and
/// how traffic is routed, expressed as Lists / Scenarios / Apps. Everything not
/// modeled here (DNS, sniffer, the server mesh, anti-loop rules) stays in the
/// underlying YAML and is preserved verbatim by the writer.
class RoutingModel {
  final String exitGroup;
  final List<RoutingList> lists;
  final List<Scenario> scenarios;
  final List<AppAssignment> apps;

  /// The top-level rules that run before per-app routing (ad-block, domestic
  /// carve-outs, anti-leak IP rules) as editable rows. Everything not per-app
  /// and not the terminal lives here; unmodeled shapes stay [RawScenarioRule].
  final List<ScenarioRule> globalRules;

  /// The terminal `MATCH,<target>` for top-level rules: `block` (fail-closed
  /// whitelist), `viaVpn` (full tunnel, Part I), `direct`, or null (no terminal).
  final Destination? defaultRoute;

  /// Imported nodes + subscriptions. Empty means "this model does not manage the
  /// server layer" (e.g. a routing-only or paste-and-go model); the writer then
  /// leaves `proxies:`/`proxy-providers:`/`proxy-groups:` untouched.
  final List<ServerSource> servers;
  final List<ServerGroup> groups;

  /// Whether apps tunnel by whitelist (`include-package`) or blacklist
  /// (`exclude-package`). Default whitelist (fail-closed).
  final TunnelMode tunnelMode;

  const RoutingModel({
    required this.exitGroup,
    required this.lists,
    required this.scenarios,
    required this.apps,
    this.globalRules = const [],
    this.defaultRoute,
    this.servers = const [],
    this.groups = const [],
    this.tunnelMode = TunnelMode.whitelist,
  });

  /// Reads an arbitrary profile into the model: recognizes modeled shapes, keeps
  /// the rest as raw. Never throws on a malformed file (yields an empty overlay).
  static RoutingModel fromYaml(String raw) => _read(raw);

  /// Materializes the overlay onto [base] (an existing profile or a from-zero
  /// envelope), touching only the blocks it manages so DNS/sniffer/mesh/comments
  /// round-trip verbatim. The single writer behind both paste-and-go and edit.
  String toYaml(String base) => _write(this, base);

  RoutingModel copyWith({
    String? exitGroup,
    List<RoutingList>? lists,
    List<Scenario>? scenarios,
    List<AppAssignment>? apps,
    List<ScenarioRule>? globalRules,
    Destination? defaultRoute,
    List<ServerSource>? servers,
    List<ServerGroup>? groups,
    TunnelMode? tunnelMode,
  }) => RoutingModel(
    exitGroup: exitGroup ?? this.exitGroup,
    lists: lists ?? this.lists,
    scenarios: scenarios ?? this.scenarios,
    apps: apps ?? this.apps,
    globalRules: globalRules ?? this.globalRules,
    defaultRoute: defaultRoute ?? this.defaultRoute,
    servers: servers ?? this.servers,
    groups: groups ?? this.groups,
    tunnelMode: tunnelMode ?? this.tunnelMode,
  );

  /// Renames a group, cascading the new name into the exit selection and any
  /// group whose members reference it, so nothing silently reroutes.
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

  /// Renames a server (node or subscription), cascading into every group's
  /// members/`use:` and the exit selection so no reference dangles.
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
              SubscriptionSource(:final url) => ServerSource.subscription(
                name: to,
                url: url,
              ),
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

  /// Renames a scenario (sub-rule), cascading into every reference (apps, global
  /// rules, and other scenarios' rows that target it) so no reference dangles.
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

  /// Replaces the node [from]'s protocol fields with [proxy]. When `proxy['name']`
  /// differs, this also renames the node (cascading references).
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

  /// Replaces the subscription [name]'s URL.
  RoutingModel updateSubscriptionUrl(String name, String url) => copyWith(
    servers: [
      for (final s in servers)
        if (s is SubscriptionSource && s.name == name)
          ServerSource.subscription(name: name, url: url)
        else
          s,
    ],
  );
}

List<String> _replaceName(List<String> xs, String from, String to) => [
  for (final x in xs) x == from ? to : x,
];

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

// The whitelist fail-closed sentinel: kept in `include-package` when no app is
// routed via VPN, so the key is never removed (an absent key makes Android
// VpnService capture ALL apps). It is the app's own package (always installed,
// force-added natively anyway) and is filtered out on read.
const routingOwnPackageSentinel = 'com.follow.clash';

// Whitelist -> `tun.include-package` (apps that enter the tunnel); blacklist ->
// `tun.exclude-package` (apps that bypass it). The unused key is cleared so a
// mode switch never leaves a stale package list behind.
String _writeTunnelPackages(RoutingModel m, String base) {
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

ProviderSpec _subToProvider(SubscriptionSource s, ProviderSpec? existing) =>
    (existing ?? ProviderSpec.create(type: 'http')).copyWith(
      type: 'http',
      url: s.url,
    );

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

// A plain policy target. Never called with [ToScenario] (those emit a SUB-RULE
// via [_ruleFor]); the default/terminal MATCH only ever carries a base policy.
String _targetOf(RoutingModel m, Destination d) => switch (d) {
  ToVpn() => m.exitGroup,
  ToBypass() => 'DIRECT',
  ToBlock() => 'REJECT',
  ToScenario() => throw ArgumentError('scenario dest has no plain target'),
};

// One matcher (action + verbatim params) plus a destination. A scenario target
// wraps the condition in `SUB-RULE`, folding flags into the clause so it
// round-trips; every other target is a plain typed rule.
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

// Rebuilds `rules:` from the model: the editable global rules first (anti-loop
// DIRECTs, carve-outs, ad-block), then per-app routing, then the terminal MATCH.
// The model owns every top-level rule, so a no-op edit reproduces it verbatim.
String _writeRulesBlock(RoutingModel m, String yaml) {
  final next = <RoutingRule>[
    ..._rowsToRules(m, m.globalRules),
    for (final a in m.apps)
      if (_appRule(m, a) case final rule?) rule,
    if (m.defaultRoute case final def?)
      TypedRule(action: RuleAction.MATCH, value: '', target: _targetOf(m, def)),
  ];
  return ProfileRulesDocument(yaml).withRules(next);
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
      ServerSource.subscription(name: e.key, url: e.value.url),
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
  // default route; MATCH to an arbitrary group round-trips as a global rule.
  final defaultRoute = terminal != null ? destOf(terminal.target) : null;

  // One destination per package (dedup); a LinkedHashMap keeps first-seen order.
  final appByPkg = <String, Destination>{};
  final globalRules = <ScenarioRule>[];
  for (var i = 0; i < topRules.length; i++) {
    if (defaultRoute != null && i == topRules.length - 1) continue;
    final r = topRules[i];
    if (r is AppToSubRuleRoute) {
      appByPkg[r.packageName] = ToScenario(r.subRuleName);
    } else if (r is TypedRule && r.action == RuleAction.PROCESS_NAME) {
      appByPkg[r.value] = destOf(r.target) ?? toVpn;
    } else {
      globalRules.add(_modelRow(r, destOf) ?? RawScenarioRule(r));
    }
  }

  final tunnelMode =
      doc.excludedPackages.isNotEmpty && doc.includedPackages.isEmpty
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
    servers: servers,
    groups: groups,
    tunnelMode: tunnelMode,
  );
}

// Classify by group TYPE: a known behavior (select/url-test/fallback) is a
// human-editable SmartGroup even when provider-backed (use/filter) or carrying
// benign keys (hidden/icon/url); only an exotic type (relay, load-balance, ...)
// stays a RawGroup.
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

// Reads a row's destination for reference rewriting; a raw row has none.
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

// Rewrites a row that targets scenario [from] to point at [to]; others pass through.
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
