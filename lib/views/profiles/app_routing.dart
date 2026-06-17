import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/app_routing_model.dart';
import 'package:fl_clash/views/profiles/routing_rules_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _View { apps, rules }

enum _Sort { name, configuredFirst }

/// Per-app routing. Two surfaces over the same profile-YAML, live-mirrored via
/// [AppRoutingController]:
/// - Apps: grouped by tunnel membership (in mihomo / bypass) with a per-app
///   routing target (a flat `PROCESS-NAME` rule, or `SUB-RULE,(PROCESS-NAME,...)`).
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
  _Sort _sort = _Sort.name;

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

  /// Per-package routing target, recognizing both a flat `PROCESS-NAME` rule
  /// (a proxy/group) and the `SUB-RULE,(PROCESS-NAME,...)` form (a sub-rule).
  Map<String, AppTarget> get _byPackage {
    final map = <String, AppTarget>{};
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

  Future<void> _pickApp(Package package) async {
    final pkg = package.packageName;
    final inTun = inTunnel(pkg, _mode, _included, _excluded);
    final current = _byPackage[pkg]?.value ?? kRoutingDefault;
    final picked = await _showTwoStepSheet(
      package: package,
      inTunnel: inTun,
      current: current,
      currentIsSubRule: _byPackage[pkg]?.isSubRule ?? false,
    );
    if (picked == null) return;
    if (picked.inTunnel != inTun) {
      final error = await appController.setAppMembership(
        widget.profileId,
        pkg,
        mode: _mode,
        inTunnel: picked.inTunnel,
      );
      if (!mounted) return;
      if (error != null) {
        context.showNotifier(error);
        return; // don't write a target onto a failed membership change
      }
      context.showNotifier(appLocalizations.appRoutingTunnelRestart);
    }
    if (picked.inTunnel && picked.target.value != current) {
      final error = await appController.setAppTarget(
        widget.profileId,
        pkg,
        target: picked.target.value == kRoutingDefault
            ? null
            : picked.target.value,
        isSubRule: picked.target.isSubRule,
      );
      if (mounted && error != null) context.showNotifier(error);
    }
    await _load();
  }

  /// Two-step per-app sheet: step 1 picks tunnel membership, step 2 the route
  /// inside mihomo (disabled when bypassing). Reuses [setAppMembership] /
  /// [setAppTarget] on confirm via [_pickApp].
  Future<({bool inTunnel, AppTarget target})?> _showTwoStepSheet({
    required Package package,
    required bool inTunnel,
    required String current,
    required bool currentIsSubRule,
  }) {
    final groups = ref.read(currentGroupsStateProvider).value;
    return showSheet<({bool inTunnel, AppTarget target})>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AppRoutingPickerSheet(
        type: type,
        title: package.label,
        initialInTunnel: inTunnel,
        initialTarget: (value: current, isSubRule: currentIsSubRule),
        groupNames: [for (final g in groups) g.name],
        subRuleNames: _subRuleNames,
      ),
    );
  }

  Future<void> _openSettings() async {
    final findProcessOn =
        ref.read(patchClashConfigProvider).findProcessMode ==
        FindProcessMode.always;
    await showSheet<void>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => _SettingsSheet(
        type: type,
        mode: _mode,
        showSystem: _showSystem,
        sort: _sort,
        findProcessOn: findProcessOn,
        onMode: _setMode,
        onShowSystem: (v) => setState(() => _showSystem = v),
        onSort: (v) => setState(() => _sort = v),
        onFindProcess: (v) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (s) => s.copyWith(
                  findProcessMode: v
                      ? FindProcessMode.always
                      : FindProcessMode.off,
                ),
              );
        },
      ),
    );
  }

  Future<void> _setMode(AccessControlMode mode) async {
    if (mode == _mode) return;
    final packages = ref
        .read(packagesProvider)
        .map((p) => p.packageName)
        .toList();
    final error = await appController.setTunnelMode(
      widget.profileId,
      mode,
      packages: packages,
    );
    if (!mounted) return;
    if (error != null) context.showNotifier(error);
    await _load();
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final findProcessOff =
        ref.watch(patchClashConfigProvider.select((s) => s.findProcessMode)) ==
        FindProcessMode.off;
    return CommonScaffold(
      title: appLocalizations.appRouting,
      actions: _view == _View.apps
          ? [
              IconButton(
                tooltip: appLocalizations.appRoutingSettingsTitle,
                icon: const Icon(Icons.tune),
                onPressed: _openSettings,
              ),
            ]
          : null,
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
                if (_view == _View.apps)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                Expanded(
                  child: _view == _View.apps
                      ? _AppsList(
                          byPackage: _byPackage,
                          mode: _mode,
                          included: _included,
                          excluded: _excluded,
                          query: _query,
                          showSystem: _showSystem,
                          configuredFirst: _sort == _Sort.configuredFirst,
                          onPickApp: _pickApp,
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

class _AppsList extends ConsumerWidget {
  final Map<String, AppTarget> byPackage;
  final AccessControlMode mode;
  final Set<String> included;
  final Set<String> excluded;
  final String query;
  final bool showSystem;
  final bool configuredFirst;
  final Future<void> Function(Package) onPickApp;

  const _AppsList({
    required this.byPackage,
    required this.mode,
    required this.included,
    required this.excluded,
    required this.query,
    required this.showSystem,
    required this.configuredFirst,
    required this.onPickApp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = filterRoutingApps(
      ref.watch(packagesProvider),
      query: query,
      showSystem: showSystem,
      configuredFirst: configuredFirst,
      configured: byPackage.keys.toSet(),
    );
    if (all.isEmpty) {
      return NullStatus(label: appLocalizations.noData);
    }
    final parts = partitionApps(all, mode, included, excluded);
    final whitelist = mode == AccessControlMode.acceptSelected;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (parts.inTunnel.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.vpn_lock,
            label: appLocalizations.appRoutingInTunnelSection,
            count: parts.inTunnel.length,
            emphasized: true,
          ),
          for (final p in parts.inTunnel)
            _AppRow(
              package: p,
              target: byPackage[p.packageName],
              onTap: () => onPickApp(p),
            ),
        ],
        if (parts.bypass.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.logout,
            label: appLocalizations.appRoutingBypassSection,
            count: parts.bypass.length,
            emphasized: false,
          ),
          for (final p in parts.bypass)
            _AppRow(
              package: p,
              target: null,
              bypass: true,
              deadRule: byPackage.containsKey(p.packageName),
              onTap: () => onPickApp(p),
            ),
        ],
        const SizedBox(height: 8),
        _CollapsedFooter(whitelist: whitelist),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool emphasized;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = emphasized ? scheme.primary : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: context.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  final Package package;
  final AppTarget? target;
  final bool bypass;
  final bool deadRule;
  final VoidCallback onTap;

  const _AppRow({
    required this.package,
    required this.target,
    this.bypass = false,
    this.deadRule = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: FutureBuilder<ImageProvider?>(
          future: app?.getPackageIcon(package.packageName),
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
      subtitle: bypass
          ? Text(
              package.packageName,
              maxLines: 1,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            )
          : _TargetWay(target: target),
      trailing: bypass
          ? Row(
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
                Text(
                  appLocalizations.appRoutingBypassChip,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            )
          : _TargetChip(target: target),
    );
  }
}

/// Subtitle line under an in-tunnel app: an icon + a human phrase naming where
/// it routes (group / sub-rule / builtin / profile rules).
class _TargetWay extends StatelessWidget {
  final AppTarget? target;

  const _TargetWay({required this.target});

  @override
  Widget build(BuildContext context) {
    final kind = targetChipKind(target);
    final scheme = context.colorScheme;
    return Row(
      children: [
        Icon(_kindIcon(kind), size: 13, color: scheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _wayLabel(context, kind, target),
            maxLines: 1,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _wayLabel(BuildContext context, TargetChipKind kind, AppTarget? t) =>
      switch (kind) {
        TargetChipKind.profileRules => appLocalizations.appRoutingDefault,
        TargetChipKind.direct => kRoutingDirect,
        TargetChipKind.reject => kRoutingReject,
        TargetChipKind.global => kRoutingGlobal,
        TargetChipKind.group => t!.value,
        TargetChipKind.subRule => t!.value,
      };
}

/// Color-coded routing-target chip for an in-tunnel app. Group → primary,
/// sub-rule → tertiary, DIRECT/builtins → neutral, REJECT → error, default →
/// outlined.
class _TargetChip extends StatelessWidget {
  final AppTarget? target;

  const _TargetChip({required this.target});

  @override
  Widget build(BuildContext context) {
    final kind = targetChipKind(target);
    final scheme = context.colorScheme;
    final (bg, fg) = switch (kind) {
      TargetChipKind.group => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      TargetChipKind.subRule => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      TargetChipKind.reject => (scheme.errorContainer, scheme.onErrorContainer),
      TargetChipKind.direct || TargetChipKind.global => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      TargetChipKind.profileRules => (
        Colors.transparent,
        scheme.onSurfaceVariant,
      ),
    };
    final label = switch (kind) {
      TargetChipKind.profileRules => appLocalizations.appRoutingDefault,
      _ => target!.value,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 124),
      child: Container(
        decoration: ShapeDecoration(
          color: bg,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
            side: kind == TargetChipKind.profileRules
                ? BorderSide(color: scheme.outlineVariant)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_kindIcon(kind), size: 15, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                style: context.textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedFooter extends StatelessWidget {
  final bool whitelist;

  const _CollapsedFooter({required this.whitelist});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final fallback = whitelist
        ? appLocalizations.appRoutingDefaultBypass
        : appLocalizations.appRoutingDefaultTunnel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerLow,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.apps, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 11),
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
            const SizedBox(width: 8),
            Text(
              fallback,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _kindIcon(TargetChipKind kind) => switch (kind) {
  TargetChipKind.profileRules => Icons.rule,
  TargetChipKind.direct => Icons.arrow_forward,
  TargetChipKind.reject => Icons.block,
  TargetChipKind.global => Icons.public,
  TargetChipKind.group => Icons.hub,
  TargetChipKind.subRule => Icons.alt_route,
};

/// Two-step per-app picker. Step 1 segments tunnel membership; step 2 lists the
/// route inside mihomo, grouped Fast / Via group / By scenario, dimmed and
/// non-interactive while step 1 is "Bypass". Pops
/// `({bool inTunnel, AppTarget target})`.
class AppRoutingPickerSheet extends StatefulWidget {
  final SheetType type;
  final String title;
  final bool initialInTunnel;
  final AppTarget initialTarget;
  final List<String> groupNames;
  final List<String> subRuleNames;

  const AppRoutingPickerSheet({
    super.key,
    required this.type,
    required this.title,
    required this.initialInTunnel,
    required this.initialTarget,
    required this.groupNames,
    required this.subRuleNames,
  });

  @override
  State<AppRoutingPickerSheet> createState() => _AppRoutingPickerSheetState();
}

class _AppRoutingPickerSheetState extends State<AppRoutingPickerSheet> {
  late bool _inTunnel = widget.initialInTunnel;
  late AppTarget _target = widget.initialTarget;

  bool _isSelected(String value, bool isSubRule) =>
      _target.value == value && _target.isSubRule == isSubRule;

  void _select(String value, bool isSubRule) {
    setState(() => _target = (value: value, isSubRule: isSubRule));
    Navigator.of(context).pop((inTunnel: _inTunnel, target: _target));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: widget.title,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          _StepLabel('1 · ${appLocalizations.appRoutingStep1}'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(appLocalizations.appRoutingInTunnel),
                  icon: const Icon(Icons.vpn_lock, size: 18),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(appLocalizations.appRoutingBypassDirect),
                  icon: const Icon(Icons.logout, size: 18),
                ),
              ],
              selected: {_inTunnel},
              onSelectionChanged: (s) => setState(() => _inTunnel = s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
            child: Text(
              appLocalizations.appRoutingStep1Hint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (!_inTunnel)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.of(
                  context,
                ).pop((inTunnel: false, target: _target)),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(appLocalizations.appRoutingBypassDirect),
              ),
            ),
          _StepLabel('2 · ${appLocalizations.appRoutingStep2}'),
          IgnorePointer(
            ignoring: !_inTunnel,
            child: Opacity(
              opacity: _inTunnel ? 1 : 0.32,
              child: Column(children: _buildRouteNodes(context)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteNodes(BuildContext context) {
    return [
      _NodeLabel(
        icon: Icons.bolt,
        label: appLocalizations.appRoutingSectionFast,
      ),
      _RouteNode(
        kind: TargetChipKind.profileRules,
        title: appLocalizations.appRoutingDefault,
        subtitle: appLocalizations.appRoutingProfileRulesDesc,
        selected: _isSelected(kRoutingDefault, false),
        onTap: () => _select(kRoutingDefault, false),
      ),
      _RouteNode(
        kind: TargetChipKind.direct,
        title: kRoutingDirect,
        subtitle: appLocalizations.appRoutingDirectDesc,
        selected: _isSelected(kRoutingDirect, false),
        onTap: () => _select(kRoutingDirect, false),
      ),
      _RouteNode(
        kind: TargetChipKind.reject,
        title: kRoutingReject,
        selected: _isSelected(kRoutingReject, false),
        onTap: () => _select(kRoutingReject, false),
      ),
      if (widget.groupNames.isNotEmpty) ...[
        _NodeLabel(
          icon: Icons.hub,
          label: appLocalizations.appRoutingSectionGroup,
          hint: appLocalizations.appRoutingSectionGroupHint,
          color: context.colorScheme.primary,
        ),
        for (final g in widget.groupNames)
          _RouteNode(
            kind: TargetChipKind.group,
            title: g,
            selected: _isSelected(g, false),
            onTap: () => _select(g, false),
          ),
      ],
      if (widget.subRuleNames.isNotEmpty) ...[
        _NodeLabel(
          icon: Icons.alt_route,
          label: appLocalizations.appRoutingSectionScenario,
          hint: appLocalizations.appRoutingSectionScenarioHint,
          color: context.colorScheme.tertiary,
        ),
        for (final n in widget.subRuleNames)
          _RouteNode(
            kind: TargetChipKind.subRule,
            title: n,
            subtitle: appLocalizations.appRoutingSubRule,
            selected: _isSelected(n, true),
            onTap: () => _select(n, true),
          ),
      ],
    ];
  }
}

class _StepLabel extends StatelessWidget {
  final String text;

  const _StepLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Text(
        text,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final Color? color;

  const _NodeLabel({
    required this.icon,
    required this.label,
    this.hint,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 7),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                hint!,
                maxLines: 1,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  final TargetChipKind kind;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RouteNode({
    required this.kind,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ListItem(
      onTap: onTap,
      color: selected ? scheme.secondaryContainer : null,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Icon(_kindIcon(kind), size: 18, color: _iconColor(scheme)),
      ),
      title: Text(
        title,
        maxLines: 1,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
      trailing: selected
          ? Icon(Icons.check, color: scheme.onSecondaryContainer)
          : null,
    );
  }

  Color _iconColor(ColorScheme scheme) => switch (kind) {
    TargetChipKind.group => scheme.primary,
    TargetChipKind.subRule => scheme.tertiary,
    TargetChipKind.reject => scheme.error,
    _ => scheme.onSurfaceVariant,
  };
}

/// Screen-settings sheet: list mode cards, process-matching + show-system
/// toggles, and the sort choice. Each wires to the screen's existing
/// provider/state via the callbacks.
class _SettingsSheet extends StatefulWidget {
  final SheetType type;
  final AccessControlMode mode;
  final bool showSystem;
  final _Sort sort;
  final bool findProcessOn;
  final ValueChanged<AccessControlMode> onMode;
  final ValueChanged<bool> onShowSystem;
  final ValueChanged<_Sort> onSort;
  final ValueChanged<bool> onFindProcess;

  const _SettingsSheet({
    required this.type,
    required this.mode,
    required this.showSystem,
    required this.sort,
    required this.findProcessOn,
    required this.onMode,
    required this.onShowSystem,
    required this.onSort,
    required this.onFindProcess,
  });

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late AccessControlMode _mode = widget.mode;
  late bool _showSystem = widget.showSystem;
  late _Sort _sort = widget.sort;
  late bool _findProcessOn = widget.findProcessOn;

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.appRoutingSettingsTitle,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _SettingsLabel(appLocalizations.appRoutingListMode),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    icon: Icons.checklist,
                    title: appLocalizations.whitelistMode,
                    desc: appLocalizations.appRoutingModeWhitelist,
                    selected: _mode == AccessControlMode.acceptSelected,
                    onTap: () => _setMode(AccessControlMode.acceptSelected),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeCard(
                    icon: Icons.block,
                    title: appLocalizations.blacklistMode,
                    desc: appLocalizations.appRoutingModeBlacklist,
                    selected: _mode == AccessControlMode.rejectSelected,
                    onTap: () => _setMode(AccessControlMode.rejectSelected),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListItem.switchItem(
            leading: const Icon(Icons.polymer_outlined),
            title: Text(appLocalizations.appRoutingProcessMatch),
            subtitle: Text(appLocalizations.appRoutingProcessMatchDesc),
            delegate: SwitchDelegate(
              value: _findProcessOn,
              onChanged: (v) {
                setState(() => _findProcessOn = v);
                widget.onFindProcess(v);
              },
            ),
          ),
          ListItem.switchItem(
            leading: const Icon(Icons.android),
            title: Text(appLocalizations.appRoutingShowSystem),
            subtitle: Text(appLocalizations.appRoutingShowSystemDesc),
            delegate: SwitchDelegate(
              value: _showSystem,
              onChanged: (v) {
                setState(() => _showSystem = v);
                widget.onShowSystem(v);
              },
            ),
          ),
          _SettingsLabel(appLocalizations.sort),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(appLocalizations.appRoutingSortName),
                  selected: _sort == _Sort.name,
                  onSelected: (_) => _setSort(_Sort.name),
                ),
                ChoiceChip(
                  label: Text(appLocalizations.appRoutingSortConfigured),
                  selected: _sort == _Sort.configuredFirst,
                  onSelected: (_) => _setSort(_Sort.configuredFirst),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setMode(AccessControlMode mode) {
    setState(() => _mode = mode);
    widget.onMode(mode);
  }

  void _setSort(_Sort sort) {
    setState(() => _sort = sort);
    widget.onSort(sort);
  }
}

class _SettingsLabel extends StatelessWidget {
  final String text;

  const _SettingsLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Text(
        text,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      isSelected: selected,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
