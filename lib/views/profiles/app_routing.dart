import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/routing_rules_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDefault = '';
const _kDirect = 'DIRECT';
const _kReject = 'REJECT';
const _kGlobal = 'GLOBAL';

enum _View { apps, rules }

/// Per-app routing. Two surfaces over the same profile-YAML, live-mirrored via
/// [AppRoutingController]:
/// - Apps: app-centric tunnel membership + a routing target (a flat
///   `PROCESS-NAME` rule, or `SUB-RULE,(PROCESS-NAME,...)` for a sub-rule).
/// - All rules: the full ordered `rules:` list (see [RoutingRulesEditor]).
class AppRoutingView extends ConsumerStatefulWidget {
  final int profileId;

  const AppRoutingView({super.key, required this.profileId});

  @override
  ConsumerState<AppRoutingView> createState() => _AppRoutingViewState();
}

class _AppRoutingViewState extends ConsumerState<AppRoutingView> {
  List<RoutingRule> _ruleList = const [];
  Set<String> _excluded = const {};
  Set<String> _included = const {};
  List<String> _subRuleNames = const [];
  AccessControlMode _mode = AccessControlMode.rejectSelected;
  bool _loading = true;
  _View _view = _View.apps;
  String _query = '';
  bool _showSystem = false;

  @override
  void initState() {
    super.initState();
    unawaited(appController.getPackages());
    _load();
  }

  Future<void> _load() async {
    final migrated = await appController.migrateAccessControlToYaml(
      widget.profileId,
    );
    final rules = await appController.readRoutingRules(widget.profileId);
    final excluded = await appController.readExcludedPackages(widget.profileId);
    final included = await appController.readIncludedPackages(widget.profileId);
    final subRuleNames = await appController.readSubRuleNames(widget.profileId);
    final mode = await appController.readTunnelMode(widget.profileId);
    if (!mounted) return;
    setState(() {
      _ruleList = rules;
      _excluded = excluded.toSet();
      _included = included.toSet();
      _subRuleNames = subRuleNames;
      _mode = mode;
      _loading = false;
    });
    if (migrated != null && mounted) {
      context.showNotifier(appLocalizations.appRoutingMigrated(migrated));
    }
  }

  /// Whether [pkg] currently routes into the tunnel, per the active mode.
  bool _inTunnel(String pkg) => _mode == AccessControlMode.acceptSelected
      ? _included.contains(pkg)
      : !_excluded.contains(pkg);

  /// Per-package routing target, recognizing both a flat `PROCESS-NAME` rule
  /// (a proxy/group) and the `SUB-RULE,(PROCESS-NAME,...)` form (a sub-rule).
  Map<String, ({String value, bool isSubRule})> get _byPackage {
    final map = <String, ({String value, bool isSubRule})>{};
    for (final r in _ruleList) {
      if (r is TypedRule && r.action == RuleAction.PROCESS_NAME) {
        map[r.value] = (value: r.target, isSubRule: false);
      } else if (r is AppToSubRuleRoute) {
        map[r.packageName] = (value: r.subRuleName, isSubRule: true);
      }
    }
    return map;
  }

  // ---- Apps surface ----

  Future<void> _pickTarget(Package package) async {
    final pkg = package.packageName;
    final current = _byPackage[pkg]?.value ?? _kDefault;
    final picked = await _showAppTargetSheet(
      title: package.label,
      current: current,
    );
    if (picked == null || picked.value == current) return;
    final error = await appController.setAppTarget(
      widget.profileId,
      pkg,
      target: picked.value == _kDefault ? null : picked.value,
      isSubRule: picked.isSubRule,
    );
    if (!mounted) return;
    if (error != null) context.showNotifier(error);
    await _load();
  }

  Future<void> _toggleMembership(Package package) async {
    final pkg = package.packageName;
    final error = await appController.setAppMembership(
      widget.profileId,
      pkg,
      mode: _mode,
      inTunnel: !_inTunnel(pkg),
    );
    if (!mounted) return;
    context.showNotifier(error ?? appLocalizations.appRoutingTunnelRestart);
    await _load();
  }

  /// App-routing target picker: profile rules (default), builtins, proxy
  /// groups, and the profile's sub-rules (which a flat rule cannot target).
  Future<({String value, bool isSubRule})?> _showAppTargetSheet({
    required String title,
    required String current,
  }) {
    final groups = ref.read(currentGroupsStateProvider).value;
    final d = appLocalizations.appRoutingDefault;
    final options = <({String value, String label, bool isSubRule})>[
      (value: _kDefault, label: d, isSubRule: false),
      (value: _kDirect, label: _kDirect, isSubRule: false),
      (value: _kReject, label: _kReject, isSubRule: false),
      (value: _kGlobal, label: _kGlobal, isSubRule: false),
      for (final g in groups) (value: g.name, label: g.name, isSubRule: false),
      for (final n in _subRuleNames) (value: n, label: n, isSubRule: true),
    ];
    return showSheet<({String value, bool isSubRule})>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: title,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final o in options)
              ListTile(
                leading: o.isSubRule
                    ? const Icon(Icons.alt_route, size: 20)
                    : null,
                title: Text(o.label),
                subtitle: o.isSubRule
                    ? Text(appLocalizations.appRoutingSubRule)
                    : null,
                trailing: o.value == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(
                  context,
                ).pop((value: o.value, isSubRule: o.isSubRule)),
              ),
          ],
        ),
      ),
    );
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final findProcessOff =
        ref.watch(patchClashConfigProvider.select((s) => s.findProcessMode)) ==
        FindProcessMode.off;
    return CommonScaffold(
      title: appLocalizations.appRouting,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (findProcessOff)
                  MaterialBanner(
                    leading: const Icon(Icons.warning_amber),
                    content: Text(appLocalizations.appRoutingProcessOff),
                    actions: const [SizedBox.shrink()],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SegmentedButton<_View>(
                    segments: [
                      ButtonSegment(
                        value: _View.apps,
                        label: Text(appLocalizations.appRoutingApps),
                        icon: const Icon(Icons.apps),
                      ),
                      ButtonSegment(
                        value: _View.rules,
                        label: Text(appLocalizations.appRoutingAllRules),
                        icon: const Icon(Icons.list),
                      ),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) => setState(() => _view = s.first),
                  ),
                ),
                if (_view == _View.apps) ...[
                  _ModeBanner(mode: _mode),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              hintText: appLocalizations.appRoutingSearchHint,
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(appLocalizations.appRoutingShowSystem),
                          selected: _showSystem,
                          onSelected: (v) => setState(() => _showSystem = v),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: _view == _View.apps
                      ? _AppsList(
                          byPackage: _byPackage,
                          mode: _mode,
                          included: _included,
                          excluded: _excluded,
                          query: _query,
                          showSystem: _showSystem,
                          onPickTarget: _pickTarget,
                          onToggleMembership: _toggleMembership,
                        )
                      : RoutingRulesEditor(
                          rules: _ruleList,
                          onChanged: (next) async {
                            final error = await appController.writeRoutingRules(
                              widget.profileId,
                              next,
                            );
                            if (error == null && mounted) await _load();
                            return error;
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// Read-only banner stating the profile's tunnel mode (whitelist vs blacklist),
/// so "in tunnel" / "outside" read correctly against the active semantics.
class _ModeBanner extends StatelessWidget {
  final AccessControlMode mode;

  const _ModeBanner({required this.mode});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final whitelist = mode == AccessControlMode.acceptSelected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(
            whitelist ? Icons.check_circle_outline : Icons.block_outlined,
            size: 16,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              whitelist
                  ? appLocalizations.appRoutingModeWhitelist
                  : appLocalizations.appRoutingModeBlacklist,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppsList extends ConsumerWidget {
  final Map<String, ({String value, bool isSubRule})> byPackage;
  final AccessControlMode mode;
  final Set<String> included;
  final Set<String> excluded;
  final String query;
  final bool showSystem;
  final Future<void> Function(Package) onPickTarget;
  final Future<void> Function(Package) onToggleMembership;

  const _AppsList({
    required this.byPackage,
    required this.mode,
    required this.included,
    required this.excluded,
    required this.query,
    required this.showSystem,
    required this.onPickTarget,
    required this.onToggleMembership,
  });

  bool _inTunnel(String pkg) => mode == AccessControlMode.acceptSelected
      ? included.contains(pkg)
      : !excluded.contains(pkg);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = filterRoutingApps(
      ref.watch(packagesProvider),
      query: query,
      showSystem: showSystem,
    );
    if (packages.isEmpty) {
      return NullStatus(label: appLocalizations.noData);
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: packages.length,
      itemExtent: 72,
      itemBuilder: (_, index) {
        final package = packages[index];
        final pkg = package.packageName;
        final inTunnel = _inTunnel(pkg);
        final rule = byPackage[pkg];
        final deadRule = !inTunnel && rule != null;
        final targetLabel = rule?.value ?? appLocalizations.appRoutingDefault;
        return ListTile(
          leading: SizedBox(
            width: 44,
            height: 44,
            child: FutureBuilder<ImageProvider?>(
              future: app?.getPackageIcon(pkg),
              builder: (_, snapshot) => snapshot.data == null
                  ? const SizedBox()
                  : Image(image: snapshot.data!, gaplessPlayback: true),
            ),
          ),
          title: Text(
            package.label,
            maxLines: 1,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          subtitle: Text(
            pkg,
            maxLines: 1,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (deadRule)
                Tooltip(
                  message: appLocalizations.appRoutingDeadRule,
                  child: Icon(
                    Icons.warning_amber,
                    size: 18,
                    color: scheme.error,
                  ),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: inTunnel
                    ? appLocalizations.appRoutingInTunnel
                    : appLocalizations.appRoutingOutside,
                icon: Icon(
                  inTunnel ? Icons.vpn_key : Icons.block,
                  size: 18,
                  color: inTunnel ? scheme.primary : scheme.outline,
                ),
                onPressed: () => onToggleMembership(package),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: ActionChip(
                  avatar: rule?.isSubRule == true
                      ? const Icon(Icons.alt_route, size: 16)
                      : null,
                  label: Text(
                    targetLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onPickTarget(package),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Apps for the routing list: optionally hide system apps, filter by a
/// case-insensitive [query] over label/package, sorted by label.
List<Package> filterRoutingApps(
  Iterable<Package> packages, {
  required String query,
  required bool showSystem,
}) {
  final q = query.toLowerCase();
  final list = packages
      .where((p) => showSystem || !p.system)
      .where(
        (p) =>
            q.isEmpty ||
            p.label.toLowerCase().contains(q) ||
            p.packageName.toLowerCase().contains(q),
      )
      .toList();
  list.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  return list;
}
