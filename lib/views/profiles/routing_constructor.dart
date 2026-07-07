import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/provider_quota.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/country_codes.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

// The zero-YAML routing constructor as an embeddable block: reads/writes the
// profile through [RoutingModel] and reloads after each sub-screen.
class RoutingSections extends StatefulWidget {
  final int profileId;

  const RoutingSections({super.key, required this.profileId});

  @override
  State<RoutingSections> createState() => _RoutingSectionsState();
}

mixin _RoutingSectionState<T extends StatefulWidget> on State<T> {
  RoutingModel? _model;

  int get profileId;

  Future<void> _load() async {
    final loaded = await appController.readRoutingModel(profileId);
    if (mounted) setState(() => _model = loaded);
  }

  Future<void> _write(RoutingModel next) async {
    final error = await appController.writeRoutingModel(profileId, next);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier('${appLocalizations.routingApplyFailed}: $error');
    } else {
      setState(() => _model = next);
    }
  }

  // A destructive edit writes to the YAML immediately (no staging, no undo), so
  // guard every delete/reset with one confirm.
  Future<bool> _confirmDelete(String label) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteTip(label)),
    );
    return res == true;
  }
}

class _RoutingSectionsState extends State<RoutingSections>
    with _RoutingSectionState<RoutingSections> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Widget _sectionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
  }) => ListItem(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      await BaseNavigator.push(context, destination);
      await _load();
    },
  );

  @override
  Widget build(BuildContext context) {
    final model = _model;
    if (model == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListHeader(title: appLocalizations.routingConnection),
        _sectionRow(
          icon: Icons.dns_outlined,
          title: '1 · ${appLocalizations.routingProxies}',
          subtitle: model.servers.isEmpty
              ? appLocalizations.routingProxiesSubtitle
              : appLocalizations.routingServerCount(model.servers.length),
          destination: _ProxiesView(profileId: widget.profileId),
        ),
        _sectionRow(
          icon: Icons.hub_outlined,
          title: '2 · ${appLocalizations.routingGroups}',
          subtitle: appLocalizations.routingGroupsSubtitle,
          destination: _GroupsView(profileId: widget.profileId),
        ),
        ListHeader(title: appLocalizations.routingRules),
        _sectionRow(
          icon: Icons.list_alt_outlined,
          title: '3 · ${appLocalizations.routingLists}',
          subtitle: appLocalizations.routingListCount(model.lists.length),
          destination: _ListsView(profileId: widget.profileId),
        ),
        _sectionRow(
          icon: Icons.rule_outlined,
          title: '4 · ${appLocalizations.routingGlobalRules}',
          subtitle: appLocalizations.routingGlobalRulesCount(
            model.globalRules.length,
          ),
          destination: _GlobalRulesView(profileId: widget.profileId),
        ),
        _sectionRow(
          icon: Icons.alt_route_outlined,
          title: appLocalizations.routingScenarios,
          subtitle: appLocalizations.routingScenarioCount(
            model.scenarios.length,
          ),
          destination: _ScenariosView(profileId: widget.profileId),
        ),
        ListHeader(title: appLocalizations.routingApps),
        _sectionRow(
          icon: Icons.apps_outlined,
          title: '5 · ${appLocalizations.routingApps}',
          subtitle: appLocalizations.routingAppsSubtitle,
          destination: _AppsView(profileId: widget.profileId),
        ),
      ],
    );
  }
}

// ===========================================================================
// Lists
// ===========================================================================

class _ListsView extends StatefulWidget {
  final int profileId;

  const _ListsView({required this.profileId});

  @override
  State<_ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<_ListsView>
    with _RoutingSectionState<_ListsView> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _addLists(List<RoutingList> lists) async {
    final model = _model!;
    final byId = {for (final l in model.lists) l.id: l};
    for (final l in lists) {
      byId[l.id] = l;
    }
    await _write(model.copyWith(lists: byId.values.toList()));
  }

  Future<void> _removeList(RoutingList list) async {
    if (!await _confirmDelete(list.name)) return;
    await _write(_model!.removeList(list.id));
  }

  Future<void> _addFlow() async {
    final source = await showSheet<_ListSource>(
      context: context,
      builder: (context, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routingAddList,
        body: ListView(
          shrinkWrap: true,
          children: [
            ListItem(
              leading: const Icon(Icons.link_outlined),
              title: Text(appLocalizations.routingSourceLink),
              onTap: () => Navigator.pop(context, _ListSource.link),
            ),
            ListItem(
              leading: const Icon(Icons.content_paste_outlined),
              title: Text(appLocalizations.routingSourcePaste),
              onTap: () => Navigator.pop(context, _ListSource.paste),
            ),
            ListItem(
              leading: const Icon(Icons.flag_outlined),
              title: Text(appLocalizations.routingSourceCountry),
              onTap: () => Navigator.pop(context, _ListSource.country),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    switch (source) {
      case _ListSource.link:
        await _addByLink();
      case _ListSource.paste:
        await _addByPaste();
      case _ListSource.country:
        await _addByCountry();
    }
  }

  Future<void> _addByLink() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingSourceLink,
        value: '',
        hintText: 'https://example.com/list',
      ),
    );
    if (url == null || url.trim().isEmpty || !mounted) return;
    final name = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingListName,
        value: '',
        hintText: appLocalizations.routingListName,
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final trimmed = url.trim();
    await _addLists([
      RoutingList(
        id: _slug(name),
        name: name.trim(),
        kind: ListKind.url,
        url: trimmed,
        behavior: 'domain',
        format: _formatFromUrl(trimmed),
      ),
    ]);
  }

  Future<void> _addByPaste() async {
    final domains = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingSourcePaste,
        value: '',
        hintText: appLocalizations.routingPasteHint,
      ),
    );
    if (domains == null || domains.trim().isEmpty || !mounted) return;
    final name = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingListName,
        value: '',
        hintText: appLocalizations.routingListName,
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final payload = domains
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    await _addLists([
      RoutingList(
        id: _slug(name),
        name: name.trim(),
        kind: ListKind.paste,
        behavior: 'domain',
        payload: payload,
      ),
    ]);
  }

  Future<void> _addByCountry() async {
    final code = await showSheet<String>(
      context: context,
      builder: (context, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routingSourceCountry,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final c in routingCountries)
              ListItem(
                leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                title: Text(localeLabel(c.labels, _locale(context))),
                onTap: () => Navigator.pop(context, c.code),
              ),
          ],
        ),
      ),
    );
    if (code == null || !mounted) return;
    await _addLists([countryList(code, locale: _locale(context))]);
  }

  String _behaviorLabel(String? b) => switch (b) {
    'domain' => appLocalizations.routingBehaviorDomain,
    'ipcidr' => appLocalizations.routingBehaviorIpcidr,
    'classical' => appLocalizations.routingBehaviorClassical,
    _ => b ?? '',
  };

  // Lets the user change how a list matches (domain / IP ranges / mixed);
  // country lists are GEOIP and carry no behavior.
  Future<void> _editList(RoutingList l) async {
    final behavior = await showSheet<String>(
      context: context,
      builder: (context, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routingListBehavior,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final b in const ['domain', 'ipcidr', 'classical'])
              ListItem(
                title: Text(_behaviorLabel(b)),
                trailing: l.behavior == b
                    ? Icon(Icons.check, color: context.colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, b),
              ),
          ],
        ),
      ),
    );
    if (behavior == null || !mounted) return;
    await _addLists([l.copyWith(behavior: behavior)]);
  }

  @override
  Widget build(BuildContext context) {
    final model = _model;
    return CommonScaffold(
      title: appLocalizations.routingLists,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingAddList,
        onPressed: model == null ? null : _addFlow,
      ),
      body: model == null
          ? const Center(child: CircularProgressIndicator())
          : model.lists.isEmpty
          ? NullStatus(
              label: appLocalizations.routingNoLists,
              illustration: const RuleEmptyIllustration(),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 88.mAp),
              itemCount: model.lists.length,
              itemBuilder: (_, i) {
                final l = model.lists[i];
                final isCountry = l.kind == ListKind.country;
                return ListItem(
                  leading: Icon(_kindIcon(l.kind)),
                  title: Text(l.name),
                  subtitle: Text(
                    isCountry
                        ? _kindLabel(l.kind)
                        : '${_kindLabel(l.kind)} · ${_behaviorLabel(l.behavior)}',
                  ),
                  onTap: isCountry ? null : () => _editList(l),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeList(l),
                  ),
                );
              },
            ),
    );
  }
}

enum _ListSource { link, paste, country }

// ===========================================================================
// Scenarios
// ===========================================================================

class _ScenariosView extends StatefulWidget {
  final int profileId;

  const _ScenariosView({required this.profileId});

  @override
  State<_ScenariosView> createState() => _ScenariosViewState();
}

class _ScenariosViewState extends State<_ScenariosView>
    with _RoutingSectionState<_ScenariosView> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _newScenario() async {
    final name = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingNewScenario,
        value: '',
        hintText: appLocalizations.routingScenarioName,
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    final model = _model!;
    final scenario = Scenario(
      name: _uniqueName(_slug(name), {for (final s in model.scenarios) s.name}),
      rules: const [],
      defaultDest: toVpn,
    );
    await _write(model.copyWith(scenarios: [...model.scenarios, scenario]));
  }

  Future<void> _openEditor(Scenario scenario) async {
    final edited = await BaseNavigator.push<Scenario>(
      context,
      _ScenarioEditorView(model: _model!, scenario: scenario),
    );
    if (edited == null || !mounted) return;
    final model = _model!;
    await _write(
      model.copyWith(
        scenarios: [
          for (final s in model.scenarios)
            if (s.name == scenario.name) edited else s,
        ],
      ),
    );
  }

  Future<void> _renameScenario(Scenario scenario) async {
    final name = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingRename,
        value: scenario.name,
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    final model = _model!;
    final taken = {
      for (final s in model.scenarios)
        if (s.name != scenario.name) s.name,
    };
    await _write(
      model.renameScenario(scenario.name, _uniqueName(_slug(name), taken)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = _model;
    return CommonScaffold(
      title: appLocalizations.routingScenarios,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingNewScenario,
        onPressed: model == null ? null : _newScenario,
      ),
      body: model == null
          ? const Center(child: CircularProgressIndicator())
          : model.scenarios.isEmpty
          ? NullStatus(
              label: appLocalizations.routingNoScenarios,
              illustration: const RuleEmptyIllustration(),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 88.mAp),
              itemCount: model.scenarios.length,
              itemBuilder: (_, i) {
                final s = model.scenarios[i];
                return ListItem(
                  leading: const Icon(Icons.alt_route_outlined),
                  title: Text(s.name),
                  subtitle: Text(
                    appLocalizations.routingScenarioRuleCount(s.rules.length),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _renameScenario(s),
                  ),
                  onTap: () => _openEditor(s),
                );
              },
            ),
    );
  }
}

class _ScenarioEditorView extends StatefulWidget {
  final RoutingModel model;
  final Scenario scenario;

  const _ScenarioEditorView({required this.model, required this.scenario});

  @override
  State<_ScenarioEditorView> createState() => _ScenarioEditorViewState();
}

class _ScenarioEditorViewState extends State<_ScenarioEditorView> {
  late List<ScenarioRule> _rules = List.of(widget.scenario.rules);
  late Destination _default = widget.scenario.defaultDest ?? toVpn;

  Scenario get _result => Scenario(
    name: widget.scenario.name,
    rules: _rules,
    defaultDest: _default,
  );

  String _rowLabel(ScenarioRule r) =>
      _ruleLabel(r, widget.model.lists, _locale(context));

  Destination? _rowDest(ScenarioRule r) => _ruleDest(r);

  Future<void> _addRow() async {
    final row = await _pickRuleRow(context, widget.model.lists);
    if (row != null) setState(() => _rules = [..._rules, row]);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: widget.scenario.name,
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => Navigator.pop(context, _result),
        ),
      ],
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingAddRule,
        onPressed: _addRow,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.mAp),
            child: Text(
              appLocalizations.routingCheckedTopToBottom,
              style: context.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.only(bottom: 88.mAp),
              itemCount: _rules.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                _rules.insert(newIndex, _rules.removeAt(oldIndex));
              }),
              footer: Column(
                children: [
                  const Divider(),
                  ListItem(
                    leading: const Icon(Icons.done_all_outlined),
                    title: Text(appLocalizations.routingEverythingElse),
                    trailing: _destChip(context, _default, () async {
                      final d = await _pickTarget(context, allowBypass: false);
                      if (d != null) setState(() => _default = d);
                    }),
                  ),
                ],
              ),
              itemBuilder: (context, i) => _ruleRow(context, i, _rules[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(BuildContext context, int i, ScenarioRule r) {
    final dest = _rowDest(r);
    final subtitle = _ruleSubtitle(r);
    return ListItem(
      key: ObjectKey(r),
      leading: ReorderableDragStartListener(
        index: i,
        child: const Icon(Icons.drag_indicator),
      ),
      title: Text(_rowLabel(r)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dest != null)
            _destChip(context, dest, () async {
              final d = await _pickTarget(context);
              if (d == null) return;
              setState(() {
                _rules = [
                  for (var j = 0; j < _rules.length; j++)
                    if (j == i) _withDest(_rules[j], d) else _rules[j],
                ];
              });
            }),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: appLocalizations.delete,
            onPressed: () => setState(
              () => _rules = [
                for (var j = 0; j < _rules.length; j++)
                  if (j != i) _rules[j],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

ScenarioRule _withDest(ScenarioRule r, Destination d) => switch (r) {
  ListRule(:final listId) => ListRule(listId: listId, dest: d),
  CountryRule(:final countryCode, :final noResolve) => CountryRule(
    countryCode: countryCode,
    dest: d,
    noResolve: noResolve,
  ),
  MatchRule(:final action, :final value, :final noResolve, :final src) =>
    MatchRule(
      action: action,
      value: value,
      dest: d,
      noResolve: noResolve,
      src: src,
    ),
  LogicRule(:final op, :final clauses, :final noResolve, :final src) =>
    LogicRule(
      op: op,
      clauses: clauses,
      dest: d,
      noResolve: noResolve,
      src: src,
    ),
  RawScenarioRule() => r,
};

String _ruleLabel(
  ScenarioRule r,
  List<RoutingList> lists,
  String locale,
) => switch (r) {
  ListRule(:final listId) =>
    lists
        .firstWhere(
          (l) => l.id == listId,
          orElse: () =>
              RoutingList(id: listId, name: listId, kind: ListKind.url),
        )
        .name,
  CountryRule(:final countryCode) => switch (countryEntry(countryCode)) {
    final e? => localeLabel(e.labels, locale),
    null => countryCode,
  },
  MatchRule(:final value) => value,
  LogicRule(:final op, :final clauses) =>
    '${op.value}: ${clauses.map((c) => c.params.isEmpty ? c.action.value : c.params).join(', ')}',
  RawScenarioRule(:final raw) => raw.serialize(),
};

Destination? _ruleDest(ScenarioRule r) => switch (r) {
  ListRule(:final dest) => dest,
  CountryRule(:final dest) => dest,
  MatchRule(:final dest) => dest,
  LogicRule(:final dest) => dest,
  RawScenarioRule() => null,
};

// The matcher kind, shown as a subtitle so a domain/IP/app rule reads plainly
// without leaking mihomo grammar. Null when the row's title already says it all.
String? _ruleSubtitle(ScenarioRule r) => switch (r) {
  MatchRule(:final action) => _matcherHint(action),
  _ => null,
};

String _matcherHint(RuleAction a) => switch (a) {
  RuleAction.DOMAIN => appLocalizations.routingMatcherDomain,
  RuleAction.DOMAIN_SUFFIX => appLocalizations.routingMatcherDomainSuffix,
  RuleAction.DOMAIN_KEYWORD => appLocalizations.routingMatcherDomainKeyword,
  RuleAction.DOMAIN_WILDCARD => appLocalizations.routingMatcherDomainWildcard,
  RuleAction.DOMAIN_REGEX => appLocalizations.routingMatcherDomainRegex,
  RuleAction.GEOSITE => appLocalizations.routingMatcherGeosite,
  RuleAction.IP_CIDR => appLocalizations.routingMatcherIp,
  RuleAction.IP_CIDR6 => appLocalizations.routingMatcherIpV6,
  RuleAction.IP_SUFFIX => appLocalizations.routingMatcherIpSuffix,
  RuleAction.IP_ASN => appLocalizations.routingMatcherAsn,
  RuleAction.GEOIP => appLocalizations.routingMatcherGeoip,
  RuleAction.DST_PORT => appLocalizations.routingMatcherDstPort,
  RuleAction.SRC_IP_CIDR => appLocalizations.routingMatcherSrcIp,
  RuleAction.SRC_IP_SUFFIX => appLocalizations.routingMatcherSrcIpSuffix,
  RuleAction.SRC_IP_ASN => appLocalizations.routingMatcherSrcAsn,
  RuleAction.SRC_GEOIP => appLocalizations.routingMatcherSrcGeoip,
  RuleAction.SRC_PORT => appLocalizations.routingMatcherSrcPort,
  RuleAction.PROCESS_NAME => appLocalizations.routingMatcherApp,
  RuleAction.PROCESS_NAME_WILDCARD =>
    appLocalizations.routingMatcherAppWildcard,
  RuleAction.PROCESS_NAME_REGEX => appLocalizations.routingMatcherAppRegex,
  RuleAction.PROCESS_PATH => appLocalizations.routingMatcherAppPath,
  RuleAction.PROCESS_PATH_WILDCARD =>
    appLocalizations.routingMatcherAppPathWildcard,
  RuleAction.PROCESS_PATH_REGEX => appLocalizations.routingMatcherAppPathRegex,
  RuleAction.UID => appLocalizations.routingMatcherUid,
  RuleAction.NETWORK => appLocalizations.routingMatcherNetwork,
  _ => a.value,
};

Future<RoutingList?> _pickList(BuildContext context, List<RoutingList> lists) =>
    showSheet<RoutingList>(
      context: context,
      builder: (context, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routingPickList,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final l in lists)
              ListItem(
                leading: Icon(_kindIcon(l.kind)),
                title: Text(l.name),
                onTap: () => Navigator.pop(context, l),
              ),
          ],
        ),
      ),
    );

// The single target picker for rules and apps alike: VPN, bypass (outside VPN),
// each named scenario, then block. [scenarios] is empty where a scenario target
// is not offered (inside a scenario, to avoid loops).
Future<Destination?> _pickTarget(
  BuildContext context, {
  List<Scenario> scenarios = const [],
  String? title,
  bool allowBypass = true,
}) => showSheet<Destination>(
  context: context,
  builder: (context, type) => AdaptiveSheetScaffold(
    type: type,
    title: title ?? appLocalizations.routingSendTo,
    body: ListView(
      shrinkWrap: true,
      children: [
        for (final d in <Destination>[
          toVpn,
          // A rule/terminal "bypass" would be an in-tunnel MATCH,DIRECT, not the
          // OS-level bypass; the everything-else default omits it (invariant 6).
          if (allowBypass) toBypass,
          for (final s in scenarios) ToScenario(s.name),
          toBlock,
        ])
          ListItem(
            leading: Icon(
              _destStyle(context, d).icon,
              color: _destStyle(context, d).color,
            ),
            title: Text(_destStyle(context, d).label),
            onTap: () => Navigator.pop(context, d),
          ),
      ],
    ),
  ),
);

// A searchable single-pick sheet: the full list lives here (label + optional
// detail per row), so a screen shows only what is selected + an "Add" that opens
// this. Returns the chosen `value` (which may differ from the shown `label`).
Future<String?> _pickFromList(
  BuildContext context, {
  required String title,
  required List<({String value, String label, String detail})> options,
  String? searchHint,
  IconData leading = Icons.dns_outlined,
}) => showSheet<String>(
  context: context,
  props: const SheetProps(isScrollControlled: true),
  builder: (context, type) => _SearchPickBody(
    type: type,
    title: title,
    options: options,
    searchHint: searchHint,
    leading: leading,
  ),
);

class _SearchPickBody extends StatefulWidget {
  final SheetType type;
  final String title;
  final List<({String value, String label, String detail})> options;
  final String? searchHint;
  final IconData leading;

  const _SearchPickBody({
    required this.type,
    required this.title,
    required this.options,
    this.searchHint,
    this.leading = Icons.dns_outlined,
  });

  @override
  State<_SearchPickBody> createState() => _SearchPickBodyState();
}

class _SearchPickBodyState extends State<_SearchPickBody> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final filtered = widget.options
        .where(
          (o) =>
              q.isEmpty ||
              o.value.toLowerCase().contains(q) ||
              o.label.toLowerCase().contains(q) ||
              o.detail.toLowerCase().contains(q),
        )
        .toList();
    // Full-height, keyboard-safe: the sheet grows to ~85% and lifts above the
    // keyboard (viewInsets) so the search field and list are never covered.
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: widget.title,
      body: Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: SizedBox(
          height: (maxHeight - insets).clamp(240.0, maxHeight),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.mAp),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText:
                        widget.searchHint ??
                        appLocalizations.appRoutingSearchHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(appLocalizations.noData))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final o = filtered[i];
                          return ListItem(
                            leading: Icon(widget.leading),
                            title: Text(o.label),
                            subtitle: o.detail.isEmpty ? null : Text(o.detail),
                            onTap: () => Navigator.pop(context, o.value),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RuleKind { list, matcher, logic }

typedef _MatcherCategory = ({
  String label,
  IconData icon,
  List<RuleAction> actions,
});

// Every leaf matcher mihomo supports, grouped for a human two-level picker. The
// exotic inbound (IN-*) and DSCP matchers stay reachable only via the raw-YAML
// hatch; source and destination conditions are kept apart so intent stays clear.
List<_MatcherCategory> _matcherCategories({bool includeApps = true}) => [
  (
    label: appLocalizations.routingMatcherCatDomain,
    icon: Icons.language_outlined,
    actions: const [
      RuleAction.DOMAIN,
      RuleAction.DOMAIN_SUFFIX,
      RuleAction.DOMAIN_KEYWORD,
      RuleAction.DOMAIN_WILDCARD,
      RuleAction.DOMAIN_REGEX,
      RuleAction.GEOSITE,
    ],
  ),
  (
    label: appLocalizations.routingMatcherCatDestIp,
    icon: Icons.public_outlined,
    actions: const [
      RuleAction.IP_CIDR,
      RuleAction.IP_CIDR6,
      RuleAction.IP_SUFFIX,
      RuleAction.IP_ASN,
      RuleAction.GEOIP,
      RuleAction.DST_PORT,
    ],
  ),
  (
    label: appLocalizations.routingMatcherCatSource,
    icon: Icons.login_outlined,
    actions: const [
      RuleAction.SRC_IP_CIDR,
      RuleAction.SRC_IP_SUFFIX,
      RuleAction.SRC_IP_ASN,
      RuleAction.SRC_GEOIP,
      RuleAction.SRC_PORT,
    ],
  ),
  // Per-app matchers live in the Apps step; the global-rules chain is
  // destination-based, so it drops this category to avoid a second app editor.
  if (includeApps)
    (
      label: appLocalizations.routingMatcherCatApp,
      icon: Icons.apps_outlined,
      actions: const [
        RuleAction.PROCESS_NAME,
        RuleAction.PROCESS_NAME_WILDCARD,
        RuleAction.PROCESS_NAME_REGEX,
        RuleAction.PROCESS_PATH,
        RuleAction.PROCESS_PATH_WILDCARD,
        RuleAction.PROCESS_PATH_REGEX,
        RuleAction.UID,
      ],
    ),
  (
    label: appLocalizations.routingMatcherCatConnection,
    icon: Icons.lan_outlined,
    actions: const [RuleAction.NETWORK],
  ),
];

// Add a rule: by list (RULE-SET / country GEOIP), by a single matcher, or as a
// combined AND/OR/NOT condition. Shared by the scenario and global-rules editors.
Future<ScenarioRule?> _pickRuleRow(
  BuildContext context,
  List<RoutingList> lists, {
  List<Scenario> scenarios = const [],
  bool includeApps = true,
}) async {
  final kind = await showSheet<_RuleKind>(
    context: context,
    builder: (context, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.routingAddRule,
      body: ListView(
        shrinkWrap: true,
        children: [
          ListItem(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text(appLocalizations.routingRuleByList),
            onTap: () => Navigator.pop(context, _RuleKind.list),
          ),
          ListItem(
            leading: const Icon(Icons.tune_outlined),
            title: Text(appLocalizations.routingRuleByMatcher),
            onTap: () => Navigator.pop(context, _RuleKind.matcher),
          ),
          ListItem(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(appLocalizations.routingRuleCombined),
            onTap: () => Navigator.pop(context, _RuleKind.logic),
          ),
        ],
      ),
    ),
  );
  if (kind == null || !context.mounted) return null;
  return switch (kind) {
    _RuleKind.list => _pickListRule(context, lists, scenarios),
    _RuleKind.matcher => _pickMatcherRule(
      context,
      scenarios,
      includeApps: includeApps,
    ),
    _RuleKind.logic => BaseNavigator.push<ScenarioRule>(
      context,
      const _LogicRuleView(),
    ),
  };
}

Future<ScenarioRule?> _pickListRule(
  BuildContext context,
  List<RoutingList> lists,
  List<Scenario> scenarios,
) async {
  final list = await _pickList(context, lists);
  if (list == null || !context.mounted) return null;
  final dest = await _pickTarget(context, scenarios: scenarios);
  if (dest == null) return null;
  return list.kind == ListKind.country
      ? CountryRule(countryCode: list.countryCode!, dest: dest)
      : ListRule(listId: list.id, dest: dest);
}

Future<RuleAction?> _pickMatcherAction(
  BuildContext context, {
  bool includeApps = true,
}) async {
  final category = await showSheet<_MatcherCategory>(
    context: context,
    builder: (context, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.routingMatcherType,
      body: ListView(
        shrinkWrap: true,
        children: [
          for (final c in _matcherCategories(includeApps: includeApps))
            ListItem(
              leading: Icon(c.icon),
              title: Text(c.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, c),
            ),
        ],
      ),
    ),
  );
  if (category == null || !context.mounted) return null;
  return showSheet<RuleAction>(
    context: context,
    builder: (context, type) => AdaptiveSheetScaffold(
      type: type,
      title: category.label,
      body: ListView(
        shrinkWrap: true,
        children: [
          for (final a in category.actions)
            ListItem(
              title: Text(_matcherHint(a)),
              onTap: () => Navigator.pop(context, a),
            ),
        ],
      ),
    ),
  );
}

// IP-family matchers accept the `no-resolve` refinement and, for GEOIP, humane
// country picking.
const _ipMatchers = {
  RuleAction.IP_CIDR,
  RuleAction.IP_CIDR6,
  RuleAction.IP_SUFFIX,
  RuleAction.IP_ASN,
  RuleAction.GEOIP,
  RuleAction.SRC_IP_CIDR,
  RuleAction.SRC_IP_SUFFIX,
  RuleAction.SRC_IP_ASN,
  RuleAction.SRC_GEOIP,
};

// One humane input per matcher type: GEOSITE/GEOIP pick from device geo data
// (GEOSITE falls back to text when the geo DB is absent), NETWORK is tcp/udp,
// PROCESS-NAME picks an installed app; everything else is free text.
Future<String?> _matcherValue(BuildContext context, RuleAction action) async {
  if (action == RuleAction.GEOSITE) {
    final categories = await loadGeositeCategories();
    if (!context.mounted) return null;
    if (categories.isNotEmpty) {
      return _pickFromList(
        context,
        title: appLocalizations.routingMatcherGeosite,
        searchHint: appLocalizations.routingSearchHint,
        leading: Icons.public_outlined,
        options: [for (final c in categories) (value: c, label: c, detail: '')],
      );
    }
  } else if (action == RuleAction.GEOIP || action == RuleAction.SRC_GEOIP) {
    return _pickCountryCode(context);
  } else if (action == RuleAction.NETWORK) {
    return _pickFromList(
      context,
      title: appLocalizations.routingMatcherNetwork,
      searchHint: appLocalizations.routingSearchHint,
      leading: Icons.lan_outlined,
      options: const [
        (value: 'tcp', label: 'TCP', detail: ''),
        (value: 'udp', label: 'UDP', detail: ''),
      ],
    );
  } else if (action == RuleAction.PROCESS_NAME) {
    return _pickAppPackage(context);
  }
  final value = await globalState.showCommonDialog<String>(
    child: InputDialog(
      title: _matcherHint(action),
      value: '',
      hintText: appLocalizations.routingMatchValueHint,
    ),
  );
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

// A country for GEOIP / SRC-GEOIP: the curated exit-country list, plus an "other
// code" escape for arbitrary ISO codes or geo tags (private, telegram, ...).
Future<String?> _pickCountryCode(BuildContext context) async {
  const other = '__other__';
  final locale = _locale(context);
  final code = await showSheet<String>(
    context: context,
    builder: (context, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.routingMatcherGeoip,
      body: ListView(
        shrinkWrap: true,
        children: [
          for (final c in routingCountries)
            ListItem(
              leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
              title: Text(localeLabel(c.labels, locale)),
              subtitle: Text(c.code),
              onTap: () => Navigator.pop(context, c.code),
            ),
          ListItem(
            leading: const Icon(Icons.tag_outlined),
            title: Text(appLocalizations.routingCountryOther),
            onTap: () => Navigator.pop(context, other),
          ),
        ],
      ),
    ),
  );
  if (code == null || !context.mounted) return null;
  if (code != other) return code;
  final value = await globalState.showCommonDialog<String>(
    child: InputDialog(
      title: appLocalizations.routingCountryOther,
      value: '',
      hintText: appLocalizations.routingCountryOtherHint,
    ),
  );
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

// Picks an installed, internet-capable app; the matcher value is its package.
Future<String?> _pickAppPackage(BuildContext context) async {
  final packages =
      (await appController.getPackages()).where((p) => p.internet).toList()
        ..sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
  if (!context.mounted) return null;
  return _pickFromList(
    context,
    title: appLocalizations.routingMatcherApp,
    searchHint: appLocalizations.appRoutingSearchHint,
    leading: Icons.apps_outlined,
    options: [
      for (final p in packages)
        (value: p.packageName, label: p.label, detail: p.packageName),
    ],
  );
}

// Whether an IP/GEOIP rule matches on IP only (no-resolve) or resolves domains
// first. Shown only for IP-family matchers.
Future<bool?> _askNoResolve(BuildContext context) => showSheet<bool>(
  context: context,
  builder: (context, type) => AdaptiveSheetScaffold(
    type: type,
    title: appLocalizations.routingNoResolveTitle,
    body: ListView(
      shrinkWrap: true,
      children: [
        ListItem(
          leading: const Icon(Icons.dns_outlined),
          title: Text(appLocalizations.routingNoResolveOn),
          subtitle: Text(appLocalizations.routingNoResolveOnDesc),
          onTap: () => Navigator.pop(context, true),
        ),
        ListItem(
          leading: const Icon(Icons.travel_explore_outlined),
          title: Text(appLocalizations.routingNoResolveOff),
          subtitle: Text(appLocalizations.routingNoResolveOffDesc),
          onTap: () => Navigator.pop(context, false),
        ),
      ],
    ),
  ),
);

Future<ScenarioRule?> _pickMatcherRule(
  BuildContext context,
  List<Scenario> scenarios, {
  bool includeApps = true,
}) async {
  final action = await _pickMatcherAction(context, includeApps: includeApps);
  if (action == null || !context.mounted) return null;
  final v = await _matcherValue(context, action);
  if (v == null || !context.mounted) return null;
  var noResolve = false;
  if (_ipMatchers.contains(action)) {
    final nr = await _askNoResolve(context);
    if (nr == null || !context.mounted) return null;
    noResolve = nr;
  }
  final dest = await _pickTarget(context, scenarios: scenarios);
  if (dest == null) return null;
  if (action == RuleAction.GEOIP) {
    return CountryRule(countryCode: v, dest: dest, noResolve: noResolve);
  }
  return MatchRule(action: action, value: v, dest: dest, noResolve: noResolve);
}

// Builds an AND/OR/NOT rule over flat clauses in plain language. NOT keeps a
// single condition; the result is a modeled [LogicRule].
class _LogicRuleView extends StatefulWidget {
  const _LogicRuleView();

  @override
  State<_LogicRuleView> createState() => _LogicRuleViewState();
}

class _LogicRuleViewState extends State<_LogicRuleView> {
  RuleAction _op = RuleAction.AND;
  final List<LogicalClause> _clauses = [];
  Destination _dest = toVpn;

  String _opLabel(RuleAction op) => switch (op) {
    RuleAction.AND => appLocalizations.routingLogicAll,
    RuleAction.OR => appLocalizations.routingLogicAny,
    RuleAction.NOT => appLocalizations.routingLogicNone,
    _ => op.value,
  };

  void _setOp(RuleAction op) => setState(() {
    _op = op;
    if (op == RuleAction.NOT && _clauses.length > 1) {
      _clauses.removeRange(1, _clauses.length);
    }
  });

  Future<void> _addClause() async {
    final action = await _pickMatcherAction(context);
    if (action == null || !mounted) return;
    final value = await _matcherValue(context, action);
    if (value == null || !mounted) return;
    setState(() {
      final clause = LogicalClause(action: action, params: value);
      if (_op == RuleAction.NOT) {
        _clauses
          ..clear()
          ..add(clause);
      } else {
        _clauses.add(clause);
      }
    });
  }

  void _save() {
    if (_clauses.isEmpty) return;
    Navigator.of(
      context,
    ).pop(LogicRule(op: _op, clauses: List.of(_clauses), dest: _dest));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.routingRuleCombined,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.save),
        label: appLocalizations.save,
        onPressed: _clauses.isEmpty ? null : _save,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 88.mAp),
        children: [
          ListHeader(title: appLocalizations.routingLogicOperator),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.mAp),
            child: Wrap(
              spacing: 8,
              children: [
                for (final op in const [
                  RuleAction.AND,
                  RuleAction.OR,
                  RuleAction.NOT,
                ])
                  ChoiceChip(
                    label: Text(_opLabel(op)),
                    selected: _op == op,
                    onSelected: (_) => _setOp(op),
                  ),
              ],
            ),
          ),
          ListHeader(title: appLocalizations.routingConditions),
          for (var i = 0; i < _clauses.length; i++)
            ListItem(
              leading: const Icon(Icons.rule),
              title: Text(_matcherHint(_clauses[i].action)),
              subtitle: Text(_clauses[i].params),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _clauses.removeAt(i)),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.mAp),
            child: OutlinedButton.icon(
              onPressed: _addClause,
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.routingAddCondition),
            ),
          ),
          ListHeader(title: appLocalizations.routingSendTo),
          for (final d in const <Destination>[toVpn, toBypass, toBlock])
            ListItem(
              leading: Icon(
                _destStyle(context, d).icon,
                color: _destStyle(context, d).color,
              ),
              title: Text(_destStyle(context, d).label),
              trailing: _dest == d
                  ? Icon(Icons.check, color: context.colorScheme.primary)
                  : null,
              onTap: () => setState(() => _dest = d),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Global rules (top-level routing chain, checked before per-app rules)
// ===========================================================================

class _GlobalRulesView extends StatefulWidget {
  final int profileId;

  const _GlobalRulesView({required this.profileId});

  @override
  State<_GlobalRulesView> createState() => _GlobalRulesViewState();
}

class _GlobalRulesViewState extends State<_GlobalRulesView>
    with _RoutingSectionState<_GlobalRulesView> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _writeRules(List<ScenarioRule> rules) =>
      _write(_model!.copyWith(globalRules: rules));

  Future<void> _add() async {
    final row = await _pickRuleRow(
      context,
      _model!.lists,
      scenarios: _model!.scenarios,
      includeApps: false,
    );
    if (row != null) await _writeRules([..._model!.globalRules, row]);
  }

  @override
  Widget build(BuildContext context) {
    final m = _model;
    return CommonScaffold(
      title: appLocalizations.routingGlobalRules,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingAddRule,
        onPressed: m == null ? null : _add,
      ),
      body: m == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (m.globalRules.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(16.mAp),
                    child: Text(
                      appLocalizations.routingCheckedTopToBottom,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.only(bottom: 88.mAp),
                    itemCount: m.globalRules.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final next = List.of(m.globalRules);
                      next.insert(newIndex, next.removeAt(oldIndex));
                      _writeRules(next);
                    },
                    footer: _everythingElse(m),
                    itemBuilder: (context, i) => _row(context, m, i),
                  ),
                ),
              ],
            ),
    );
  }

  // The terminal `MATCH,<dest>`: everything that matched no rule above (and no
  // per-app rule) goes here. Settable to any destination, including full-tunnel.
  Widget _everythingElse(RoutingModel m) => Column(
    children: [
      const Divider(),
      ListItem(
        leading: const Icon(Icons.done_all_outlined),
        title: Text(appLocalizations.routingEverythingElse),
        trailing: _destChip(context, m.defaultRoute ?? toVpn, () async {
          final d = await _pickTarget(context, allowBypass: false);
          if (d != null) await _write(m.copyWith(defaultRoute: d));
        }),
      ),
    ],
  );

  Widget _row(BuildContext context, RoutingModel m, int i) {
    final r = m.globalRules[i];
    final dest = _ruleDest(r);
    final subtitle = _ruleSubtitle(r);
    return ListItem(
      key: ObjectKey(r),
      leading: ReorderableDragStartListener(
        index: i,
        child: const Icon(Icons.drag_indicator),
      ),
      title: Text(_ruleLabel(r, m.lists, _locale(context))),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dest != null)
            _destChip(context, dest, () async {
              final d = await _pickTarget(context, scenarios: m.scenarios);
              if (d == null) return;
              await _writeRules([
                for (var j = 0; j < m.globalRules.length; j++)
                  if (j == i)
                    _withDest(m.globalRules[j], d)
                  else
                    m.globalRules[j],
              ]);
            }),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: appLocalizations.delete,
            onPressed: () => _writeRules([
              for (var j = 0; j < m.globalRules.length; j++)
                if (j != i) m.globalRules[j],
            ]),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Proxies (import nodes + subscriptions)
// ===========================================================================

class _ProxiesView extends ConsumerStatefulWidget {
  final int profileId;

  const _ProxiesView({required this.profileId});

  @override
  ConsumerState<_ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<_ProxiesView>
    with _RoutingSectionState<_ProxiesView> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _fail() {
    if (mounted) context.showNotifier(appLocalizations.routingImportFailed);
  }

  Future<void> _addServer() async {
    final text = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingAddServer,
        value: '',
        hintText: appLocalizations.routingServerHint,
      ),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final t = text.trim();
    final m = _model!;
    switch (classifyArtifact(t)) {
      case ArtifactKind.shareLink:
        final p = parseShareLink(t);
        if (p == null) return _fail();
        await _addNodes(m, [p]);
      case ArtifactKind.base64List:
        final res = parseSubscriptionContent(t);
        if (res.proxies.isEmpty) return _fail();
        await _addNodes(m, res.proxies);
        if (res.skipped > 0 && mounted) {
          context.showNotifier(appLocalizations.routingSkippedNodes);
        }
      case ArtifactKind.subscriptionUrl:
        await _addSubscription(m, t);
      case ArtifactKind.xrayJson:
        final ps = parseXrayJson(t);
        if (ps.isEmpty) return _fail();
        await _addNodes(m, ps);
      case ArtifactKind.clashYaml:
      case ArtifactKind.unknown:
        _fail();
    }
  }

  Future<void> _addNodes(
    RoutingModel m,
    List<Map<String, dynamic>> proxies,
  ) async {
    final used = {for (final s in m.servers) s.name};
    final added = <ServerSource>[];
    for (final p in proxies) {
      var base = (p['name'] as String?)?.trim();
      if (base == null || base.isEmpty) base = 'node';
      var unique = base;
      var n = 2;
      while (used.contains(unique)) {
        unique = '$base-${n++}';
      }
      used.add(unique);
      added.add(ServerSource.node(name: unique, proxy: {...p, 'name': unique}));
    }
    await _write(m.copyWith(servers: [...m.servers, ...added]));
    if (mounted) context.showNotifier(appLocalizations.routingServerAdded);
  }

  Future<void> _addSubscription(RoutingModel m, String url) async {
    final probe = await _probeSubscription(url);
    if (!mounted) return;
    // The provider key and its `<name>-auto` group name must both be free.
    final taken = {
      for (final s in m.servers) s.name,
      for (final g in m.groups) g.name,
    };
    var name = probe.name;
    var n = 2;
    while (taken.contains(name) || taken.contains('$name-auto')) {
      name = '${probe.name}-${n++}';
    }
    // A fresh subscription gets an auto (url-test) group over it, so it is
    // usable as an exit immediately; the user can refine it in Groups. This is
    // also the clean parent injectRemarkGroups rewires into per-remark groups.
    final group = SmartGroup(
      name: '$name-auto',
      behavior: GroupBehavior.autoFastest,
      use: [name],
      interval: 300,
      extra: const {'url': 'http://www.gstatic.com/generate_204'},
    );
    await _write(
      m.copyWith(
        servers: [
          ...m.servers,
          ServerSource.subscription(name: name, url: url, xray: probe.xray),
        ],
        groups: [...m.groups.where((g) => g.name != group.name), group],
        exitGroup: m.groups.any((g) => g.name == m.exitGroup)
            ? m.exitGroup
            : group.name,
      ),
    );
    if (mounted) {
      context.showNotifier(appLocalizations.routingSubscriptionAdded);
    }
  }

  // One fetch yields both: the by-remark marker (so setup's prefetch splits the
  // sub into per-remark groups, not one flat group) and a human name from the
  // response headers. A fetch failure degrades to a plain http sub named by host.
  Future<({Map<String, dynamic>? xray, String name})> _probeSubscription(
    String url,
  ) async {
    String? title;
    String? dispositionFilename;
    var byRemark = false;
    try {
      final resp = await request.getTextResponseForUrl(
        url,
        headers: await happHeaders(),
      );
      title = resp.headers.value('profile-title');
      dispositionFilename = utils.getFileNameForDisposition(
        resp.headers.value('content-disposition'),
      );
      byRemark = classifyArtifact(resp.data ?? '') == ArtifactKind.xrayJson;
    } catch (_) {}
    return (
      xray: byRemark ? const <String, dynamic>{'groups': 'by-remark'} : null,
      name: deriveSubscriptionName(
        profileTitle: title,
        dispositionFilename: dispositionFilename,
        url: url,
      ),
    );
  }

  Future<void> _removeServer(ServerSource s) async {
    if (_model!.isReferencedByRule(s.name) ||
        _model!.isReferencedByProxyChain(s.name)) {
      context.showNotifier(appLocalizations.routingDeleteInUse);
      return;
    }
    if (!await _confirmDelete(s.name)) return;
    await _write(_model!.removeServer(s.name));
  }

  ({Map<String, dynamic>? proxy, String error}) _parseProxy(String text) {
    try {
      final doc = loadYaml(text);
      if (doc is YamlMap) {
        return (
          proxy: (yamlToDart(doc) as Map).cast<String, dynamic>(),
          error: '',
        );
      }
      return (proxy: null, error: 'expected a YAML map');
    } catch (e) {
      return (proxy: null, error: '$e');
    }
  }

  // A node's config is edited as its own YAML (syntax-highlighted), so every
  // field, including nested ones (reality-opts, xhttp-opts), is fully editable.
  Future<void> _editNode(NodeSource s) async {
    final editor = EditorPage(
      title: appLocalizations.routingEditProxy,
      content: yaml.encode(s.proxy),
      onSave: (ctx, _, text) async {
        final parsed = _parseProxy(text);
        final proxy = parsed.proxy;
        if (proxy == null) {
          ctx.showNotifier(
            '${appLocalizations.routingApplyFailed}: ${parsed.error}',
          );
          return;
        }
        if ((proxy['name'] ?? '').toString().trim().isEmpty) {
          ctx.showNotifier('${appLocalizations.routingApplyFailed}: name');
          return;
        }
        final error = await appController.writeRoutingModel(
          widget.profileId,
          _model!.updateNode(s.name, proxy),
        );
        if (!ctx.mounted) return;
        if (error != null && error.isNotEmpty) {
          ctx.showNotifier('${appLocalizations.routingApplyFailed}: $error');
        } else {
          Navigator.of(ctx).pop(text);
        }
      },
      onPop: (ctx, _, text) async => true,
    );
    await BaseNavigator.push<String>(context, editor);
    await _load();
  }

  Future<void> _editSubscription(SubscriptionSource s) async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingSubscriptionUrl,
        value: s.url ?? '',
        hintText: 'https://example.com/sub.yaml',
      ),
    );
    if (url == null || url.trim().isEmpty || !mounted) return;
    await _write(_model!.updateSubscriptionUrl(s.name, url.trim()));
  }

  Widget _rowActions(
    ServerSource s, {
    required VoidCallback onEdit,
    bool latency = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (latency) LatencyBadge(ref.watch(getDelayProvider(proxyName: s.name))),
      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
      IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _removeServer(s),
      ),
    ],
  );

  Widget _subscriptionSubtitle(
    SubscriptionSource s,
    Map<String, SubscriptionInfo> quota,
  ) {
    final info = quota[providerQuotaKey(profileId, s.name)];
    if (info != null && (info.total != 0 || info.expire != 0)) {
      return SubscriptionInfoView(subscriptionInfo: info);
    }
    return Text(appLocalizations.routingSubscription);
  }

  @override
  Widget build(BuildContext context) {
    final m = _model;
    final quota = ref.watch(providerQuotaProvider);
    return CommonScaffold(
      title: appLocalizations.routingProxies,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingAddServer,
        onPressed: m == null ? null : _addServer,
      ),
      body: m == null
          ? const Center(child: CircularProgressIndicator())
          : m.servers.isEmpty
          ? Padding(
              padding: EdgeInsets.all(24.mAp),
              child: NullStatus(
                label: appLocalizations.routingNoServers,
                illustration: const ProxyEmptyIllustration(),
              ),
            )
          : ListView(
              padding: EdgeInsets.only(bottom: 88.mAp),
              children: [
                for (final s in m.servers)
                  if (s is NodeSource)
                    ListItem(
                      leading: const Icon(Icons.dns_outlined),
                      title: Text(
                        s.name,
                        maxLines: 1,
                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                      subtitle: Text(_nodeSubtitle(s)),
                      onTap: () => _editNode(s),
                      trailing: _rowActions(
                        s,
                        latency: true,
                        onEdit: () => _editNode(s),
                      ),
                    ),
                for (final s in m.servers)
                  if (s is SubscriptionSource)
                    ListItem(
                      leading: const Icon(Icons.cloud_outlined),
                      title: Text(s.name),
                      subtitle: _subscriptionSubtitle(s, quota),
                      onTap: () => _editSubscription(s),
                      trailing: _rowActions(
                        s,
                        onEdit: () => _editSubscription(s),
                      ),
                    ),
              ],
            ),
    );
  }

  String _nodeSubtitle(NodeSource s) {
    final p = s.proxy;
    final type = (p['type'] ?? '').toString();
    final server = p['server']?.toString();
    return server == null || server.isEmpty ? type : '$type · $server';
  }
}

// ===========================================================================
// Groups (behavior + members/subscription source, choose the exit)
// ===========================================================================

class _GroupsView extends ConsumerStatefulWidget {
  final int profileId;

  const _GroupsView({required this.profileId});

  @override
  ConsumerState<_GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends ConsumerState<_GroupsView>
    with _RoutingSectionState<_GroupsView> {
  @override
  int get profileId => widget.profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _createGroup() async {
    final m = _model!;
    final behavior = await showSheet<GroupBehavior>(
      context: context,
      builder: (context, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routingCreateGroup,
        body: ListView(
          shrinkWrap: true,
          children: [
            ListItem(
              leading: const Icon(Icons.bolt),
              title: Text(appLocalizations.routingGroupAuto),
              onTap: () => Navigator.pop(context, GroupBehavior.autoFastest),
            ),
            ListItem(
              leading: const Icon(Icons.shield_outlined),
              title: Text(appLocalizations.routingGroupFailover),
              onTap: () => Navigator.pop(context, GroupBehavior.failover),
            ),
            ListItem(
              leading: const Icon(Icons.touch_app_outlined),
              title: Text(appLocalizations.routingGroupManual),
              onTap: () => Navigator.pop(context, GroupBehavior.manual),
            ),
          ],
        ),
      ),
    );
    if (behavior == null || !mounted) return;
    final name = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.routingCreateGroup,
        value: '',
        hintText: appLocalizations.routingGroupNameHint,
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    final gname = _slug(name);
    final nodes = [
      for (final s in m.servers)
        if (s is NodeSource) s.name,
    ];
    await _write(
      m.copyWith(
        groups: [
          ...m.groups.where((g) => g.name != gname),
          SmartGroup(name: gname, behavior: behavior, members: nodes),
        ],
        exitGroup: m.groups.any((g) => g.name == m.exitGroup)
            ? m.exitGroup
            : gname,
      ),
    );
    if (mounted) await _openEditor(gname);
  }

  Future<void> _openEditor(String groupName) async {
    await BaseNavigator.push(
      context,
      _GroupEditorView(profileId: widget.profileId, groupName: groupName),
    );
    await _load();
  }

  Future<void> _tap(ServerGroup g) async {
    if (g is RawGroup) {
      context.showNotifier(appLocalizations.routingRawGroupHint);
      return;
    }
    await _openEditor(g.name);
  }

  Future<void> _delete(ServerGroup g) async {
    if (_model!.isReferencedByRule(g.name) ||
        _model!.isReferencedByProxyChain(g.name)) {
      context.showNotifier(appLocalizations.routingDeleteInUse);
      return;
    }
    if (!await _confirmDelete(g.name)) return;
    await _write(_model!.removeGroup(g.name));
  }

  String _subtitle(ServerGroup g) {
    final behavior = switch (g) {
      SmartGroup(:final behavior) => switch (behavior) {
        GroupBehavior.autoFastest => appLocalizations.routingGroupAuto,
        GroupBehavior.failover => appLocalizations.routingGroupFailover,
        GroupBehavior.manual => appLocalizations.routingGroupManual,
      },
      RawGroup() => appLocalizations.routingAdvanced,
    };
    final source = switch (g) {
      SmartGroup(:final use) when use.isNotEmpty =>
        appLocalizations.routingGroupVia(use.join(', ')),
      SmartGroup(:final members) => appLocalizations.routingServerCount(
        members.length,
      ),
      RawGroup() => '',
    };
    return source.isEmpty ? behavior : '$behavior · $source';
  }

  @override
  Widget build(BuildContext context) {
    final m = _model;
    return CommonScaffold(
      title: appLocalizations.routingGroups,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.add),
        label: appLocalizations.routingCreateGroup,
        onPressed: m == null ? null : _createGroup,
      ),
      body: m == null
          ? const Center(child: CircularProgressIndicator())
          : m.groups.isEmpty
          ? Padding(
              padding: EdgeInsets.all(24.mAp),
              child: NullStatus(
                label: appLocalizations.routingNoGroups,
                illustration: const ProxyEmptyIllustration(),
              ),
            )
          : ListView(
              padding: EdgeInsets.only(bottom: 88.mAp),
              children: [
                for (final g in m.groups)
                  ListItem(
                    leading: Icon(
                      Icons.hub_outlined,
                      color: context.colorScheme.tertiary,
                    ),
                    title: Text(g.name),
                    subtitle: Text(_subtitle(g)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(g),
                    ),
                    onTap: () => _tap(g),
                  ),
              ],
            ),
    );
  }
}

// ===========================================================================
// Group editor (behavior, source, health-check, advanced keys, exit)
// ===========================================================================

class _GroupEditorView extends ConsumerStatefulWidget {
  final int profileId;
  final String groupName;

  const _GroupEditorView({required this.profileId, required this.groupName});

  @override
  ConsumerState<_GroupEditorView> createState() => _GroupEditorViewState();
}

class _GroupEditorViewState extends ConsumerState<_GroupEditorView>
    with _RoutingSectionState<_GroupEditorView> {
  @override
  int get profileId => widget.profileId;
  late final String _original = widget.groupName;
  final _nameController = TextEditingController();
  final _filterController = TextEditingController();
  final _intervalController = TextEditingController();
  final _urlController = TextEditingController();
  final _toleranceController = TextEditingController();
  GroupBehavior _behavior = GroupBehavior.autoFastest;
  bool _fromSub = false;
  final Set<String> _members = {};
  final Set<String> _use = {};
  bool _lazy = false;
  bool _hidden = false;
  Map<String, dynamic> _extra = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _filterController.dispose();
    _intervalController.dispose();
    _urlController.dispose();
    _toleranceController.dispose();
    super.dispose();
  }

  @override
  Future<void> _load() async {
    final loaded = await appController.readRoutingModel(profileId);
    final matches = loaded.groups.whereType<SmartGroup>().where(
      (x) => x.name == widget.groupName,
    );
    if (!mounted) return;
    setState(() {
      _model = loaded;
      if (matches.isNotEmpty) {
        final g = matches.first;
        _nameController.text = g.name;
        _behavior = g.behavior;
        _members
          ..clear()
          ..addAll(g.members);
        _use
          ..clear()
          ..addAll(g.use);
        _fromSub = g.use.isNotEmpty;
        _filterController.text = g.filter ?? '';
        _intervalController.text = g.interval?.toString() ?? '';
        _urlController.text = g.url ?? '';
        _toleranceController.text = g.tolerance?.toString() ?? '';
        _lazy = g.lazy;
        _hidden = g.hidden;
        _extra = g.extra;
      }
    });
  }

  Future<void> _save() async {
    final model = _model;
    if (model == null) return;
    // Keep an unchanged name verbatim; only slug a name the user actually
    // rewrote, so opening + saving a group never silently renames it.
    final typed = _nameController.text.trim();
    final name = typed == _original ? _original : _slug(typed);
    if (name.isEmpty) {
      context.showNotifier(appLocalizations.routingGroupNameHint);
      return;
    }
    final filter = _filterController.text.trim();
    final url = _urlController.text.trim();
    final healthCheck = _behavior != GroupBehavior.manual;
    final edited = SmartGroup(
      name: name,
      behavior: _behavior,
      members: _fromSub ? const [] : _members.toList(),
      use: _fromSub ? _use.toList() : const [],
      filter: _fromSub && filter.isNotEmpty ? filter : null,
      interval: int.tryParse(_intervalController.text.trim()),
      lazy: _lazy,
      url: healthCheck && url.isNotEmpty ? url : null,
      hidden: _hidden,
      tolerance: _behavior == GroupBehavior.autoFastest
          ? int.tryParse(_toleranceController.text.trim())
          : null,
      extra: _extra,
    );
    var next = model;
    if (name != _original) next = next.renameGroup(_original, name);
    next = next.copyWith(
      groups: [for (final g in next.groups) g.name == name ? edited : g],
    );
    final error = await appController.writeRoutingModel(widget.profileId, next);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier('${appLocalizations.routingApplyFailed}: $error');
    } else {
      Navigator.of(context).pop();
    }
  }

  String _behaviorLabel(GroupBehavior b) => switch (b) {
    GroupBehavior.autoFastest => appLocalizations.routingGroupAuto,
    GroupBehavior.failover => appLocalizations.routingGroupFailover,
    GroupBehavior.manual => appLocalizations.routingGroupManual,
  };

  // A member's hint: "type · server" for a node, or "Groups" when it is itself
  // a group referenced as a member.
  String _memberHint(RoutingModel m, String name) {
    final node = m.servers.whereType<NodeSource>().where((s) => s.name == name);
    if (node.isEmpty) return appLocalizations.routingGroups;
    final p = node.first.proxy;
    final type = (p['type'] ?? '').toString();
    final server = p['server']?.toString();
    return server == null || server.isEmpty ? type : '$type · $server';
  }

  Future<void> _addMember() async {
    final m = _model;
    if (m == null) return;
    final options = <({String value, String label, String detail})>[
      for (final s in m.servers)
        if (s is NodeSource && !_members.contains(s.name))
          (value: s.name, label: s.name, detail: _memberHint(m, s.name)),
      for (final g in m.groups)
        if (g.name != _original && !_members.contains(g.name))
          (
            value: g.name,
            label: g.name,
            detail: appLocalizations.routingGroups,
          ),
    ];
    final picked = await _pickFromList(
      context,
      title: appLocalizations.routingAddServer,
      options: options,
    );
    if (picked != null && mounted) setState(() => _members.add(picked));
  }

  Future<void> _addSubSource() async {
    final m = _model;
    if (m == null) return;
    final options = <({String value, String label, String detail})>[
      for (final s in m.servers)
        if (s is SubscriptionSource && !_use.contains(s.name))
          (value: s.name, label: s.name, detail: s.url ?? ''),
    ];
    final picked = await _pickFromList(
      context,
      title: appLocalizations.routingGroupSourceSubscription,
      options: options,
    );
    if (picked != null && mounted) setState(() => _use.add(picked));
  }

  @override
  Widget build(BuildContext context) {
    final m = _model;
    return CommonScaffold(
      title: appLocalizations.routingEditGroup,
      floatingActionButton: CommonFloatingActionButton(
        icon: const Icon(Icons.save),
        label: appLocalizations.save,
        onPressed: m == null ? null : _save,
      ),
      body: m == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(bottom: 88.mAp),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.mAp, 16.mAp, 16.mAp, 8.mAp),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.name,
                    ),
                  ),
                ),
                ListHeader(title: appLocalizations.routingGroupBehavior),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.mAp),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final b in GroupBehavior.values)
                        ChoiceChip(
                          label: Text(_behaviorLabel(b)),
                          selected: _behavior == b,
                          onSelected: (_) => setState(() => _behavior = b),
                        ),
                    ],
                  ),
                ),
                ListHeader(title: appLocalizations.routingGroupSource),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.mAp),
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(appLocalizations.routingGroupSourceServers),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(
                          appLocalizations.routingGroupSourceSubscription,
                        ),
                      ),
                    ],
                    selected: {_fromSub},
                    onSelectionChanged: (s) =>
                        setState(() => _fromSub = s.first),
                  ),
                ),
                if (!_fromSub) ...[
                  for (final mem in _members)
                    ListItem(
                      leading: const Icon(Icons.dns_outlined),
                      title: Text(mem),
                      subtitle: Text(_memberHint(m, mem)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _members.remove(mem)),
                      ),
                    ),
                  ListItem(
                    leading: Icon(
                      Icons.add,
                      color: context.colorScheme.primary,
                    ),
                    title: Text(appLocalizations.routingAddServer),
                    onTap: _addMember,
                  ),
                ] else ...[
                  for (final sub in _use)
                    ListItem(
                      leading: const Icon(Icons.cloud_outlined),
                      title: Text(sub),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _use.remove(sub)),
                      ),
                    ),
                  ListItem(
                    leading: Icon(
                      Icons.add,
                      color: context.colorScheme.primary,
                    ),
                    title: Text(
                      appLocalizations.routingGroupSourceSubscription,
                    ),
                    onTap: _addSubSource,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.mAp, 8.mAp, 16.mAp, 8.mAp),
                    child: TextField(
                      controller: _filterController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: appLocalizations.routingGroupFilter,
                        hintText: appLocalizations.routingGroupFilterHint,
                      ),
                    ),
                  ),
                ],
                if (_behavior != GroupBehavior.manual) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.mAp, 8.mAp, 16.mAp, 8.mAp),
                    child: TextField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: appLocalizations.routingGroupInterval,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.mAp, 8.mAp, 16.mAp, 8.mAp),
                    child: TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: appLocalizations.routingGroupTestUrl,
                        hintText: 'http://www.gstatic.com/generate_204',
                      ),
                    ),
                  ),
                  if (_behavior == GroupBehavior.autoFastest)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.mAp,
                        8.mAp,
                        16.mAp,
                        8.mAp,
                      ),
                      child: TextField(
                        controller: _toleranceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: appLocalizations.routingGroupTolerance,
                        ),
                      ),
                    ),
                  ListItem.switchItem(
                    title: Text(appLocalizations.routingGroupLazy),
                    delegate: SwitchDelegate<bool>(
                      value: _lazy,
                      onChanged: (v) => setState(() => _lazy = v),
                    ),
                  ),
                ],
                ListItem.switchItem(
                  title: Text(appLocalizations.routingGroupHidden),
                  delegate: SwitchDelegate<bool>(
                    value: _hidden,
                    onChanged: (v) => setState(() => _hidden = v),
                  ),
                ),
              ],
            ),
    );
  }
}

// ===========================================================================
// Apps (zero-knowledge per-app intents)
// ===========================================================================

class _AppsView extends StatefulWidget {
  final int profileId;

  const _AppsView({required this.profileId});

  @override
  State<_AppsView> createState() => _AppsViewState();
}

class _AppsViewState extends State<_AppsView>
    with _RoutingSectionState<_AppsView> {
  @override
  int get profileId => widget.profileId;
  List<Package> _packages = const [];
  String _query = '';
  bool _hideSystem = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _resetApps() async {
    final model = _model;
    if (model == null || model.apps.isEmpty) return;
    if (!await _confirmDelete(appLocalizations.routingApps)) return;
    await _write(model.copyWith(apps: const []));
  }

  @override
  Future<void> _load() async {
    final loaded = await appController.readRoutingModel(profileId);
    final packages = await appController.getPackages();
    if (!mounted) return;
    setState(() {
      _model = loaded;
      _packages = packages.where((p) => p.internet).toList()
        ..sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
    });
  }

  AppAssignment? _assignment(String pkg) {
    for (final a in _model!.apps) {
      if (a.packageName == pkg) return a;
    }
    return null;
  }

  TunnelMode get _mode => _model!.tunnelMode;

  // The outcome an untouched app gets in the current mode. Whitelist -> bypass
  // (OS-excluded, fail-closed); blacklist and all -> via VPN (enters tunnel).
  Destination get _defaultDest =>
      _mode == TunnelMode.whitelist ? toBypass : toVpn;

  Future<void> _setDest(String pkg, Destination dest) async {
    final model = _model!;
    // Store only explicit overrides; an app left at the mode default drops out of
    // the list, keeping the default/exception split honest.
    final isDefault = dest == _defaultDest;
    final apps = <AppAssignment>[
      for (final a in model.apps)
        if (a.packageName != pkg) a,
      if (!isDefault) AppAssignment(packageName: pkg, dest: dest),
    ];
    await _write(model.copyWith(apps: apps));
  }

  Future<void> _pickIntent(Package p) async {
    final dest = await _pickTarget(
      context,
      scenarios: _model!.scenarios,
      title: p.label,
    );
    if (dest == null) return;
    await _setDest(p.packageName, dest);
  }

  // VpnService.Builder is allow XOR disallow, so a mode flip tears down and
  // re-raises the tunnel and flips the default side for untouched apps; confirm.
  Future<void> _switchMode(TunnelMode mode) async {
    final model = _model!;
    if (model.tunnelMode == mode) return;
    final body = switch (mode) {
      TunnelMode.all => appLocalizations.routingSwitchBodyAll,
      TunnelMode.whitelist => appLocalizations.routingSwitchBodyOnlySelected,
      TunnelMode.blacklist => appLocalizations.routingSwitchBodyAllExcept,
    };
    final ok = await globalState.showCommonDialog<bool>(
      child: CommonDialog(
        title: appLocalizations.routingModeSwitchTitle,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Text(body),
      ),
    );
    if (ok != true) return;
    final error = await appController.applyTunnelModeSwitch(profileId, mode);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier('${appLocalizations.routingApplyFailed}: $error');
    }
    // Reload strictly from YAML so the screen always mirrors the file.
    await _load();
  }

  // Collapse the unrepresentable both-lists state to the whitelist that actually
  // runs (include - exclude): keep the via-VPN apps, drop the rest, clear both.
  Future<void> _normalizeBoth(RoutingModel model) async {
    final kept = [
      for (final a in model.apps)
        if (a.dest is! ToBypass) a,
    ];
    await _write(
      model.copyWith(
        tunnelMode: TunnelMode.whitelist,
        degenerateBoth: false,
        apps: kept,
      ),
    );
  }

  Widget _dim(bool active, Widget child) => active
      ? IgnorePointer(child: Opacity(opacity: 0.5, child: child))
      : child;

  Widget _bothBanner(RoutingModel model) => Container(
    margin: EdgeInsets.fromLTRB(16.mAp, 16.mAp, 16.mAp, 0),
    padding: EdgeInsets.all(12.mAp),
    decoration: BoxDecoration(
      color: context.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: context.colorScheme.onErrorContainer,
        ),
        SizedBox(width: 12.mAp),
        Expanded(
          child: Text(
            appLocalizations.routingBothBannerBody,
            style: TextStyle(color: context.colorScheme.onErrorContainer),
          ),
        ),
        TextButton(
          onPressed: () => _normalizeBoth(model),
          child: Text(appLocalizations.routingBothNormalize),
        ),
      ],
    ),
  );

  Widget _appChip(AppAssignment? a) {
    final dest = a?.dest ?? _defaultDest;
    final style = _destStyle(context, dest);
    return CommonChip(
      label: style.label,
      type: ChipType.tonal,
      tonalColor: style.color,
      // Lock = OS-level bypass, the bank-safety signal (dark-mode/colorblind safe).
      avatar: Icon(
        dest is ToBypass ? Icons.lock_outline : style.icon,
        size: 16,
        color: style.color,
      ),
    );
  }

  Widget _appRow(Package p) => ListItem(
    leading: SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder<ImageProvider?>(
        future: app?.getPackageIcon(p.packageName),
        builder: (_, snap) => snap.data == null
            ? const Icon(Icons.android)
            : Image(image: snap.data!, gaplessPlayback: true),
      ),
    ),
    title: Text(
      p.label,
      maxLines: 1,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
    ),
    trailing: _appChip(_assignment(p.packageName)),
    onTap: () => _pickIntent(p),
  );

  @override
  Widget build(BuildContext context) {
    final model = _model;
    if (model == null) {
      return CommonScaffold(
        title: appLocalizations.routingApps,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final q = _query.toLowerCase();
    final filtered = _packages
        .where(
          (p) =>
              (q.isEmpty || p.label.toLowerCase().contains(q)) &&
              (!_hideSystem || !p.system),
        )
        .toList();
    final changed = [
      for (final p in filtered)
        if (_assignment(p.packageName) != null) p,
    ];
    final rest = [
      for (final p in filtered)
        if (_assignment(p.packageName) == null) p,
    ];
    // A flat header+row list keeps ListView.builder lazy over hundreds of apps.
    final rows = <({String? header, Package? pkg})>[
      if (changed.isNotEmpty) ...[
        (header: appLocalizations.routingAppsSectionChanged, pkg: null),
        for (final p in changed) (header: null, pkg: p),
      ],
      (
        header:
            '${appLocalizations.routingAppsSectionRest}: ${_destStyle(context, _defaultDest).label}',
        pkg: null,
      ),
      for (final p in rest) (header: null, pkg: p),
    ];
    final degenerate = model.degenerateBoth;
    final allMode = _mode == TunnelMode.all;
    final modes = <(TunnelMode, String)>[
      (TunnelMode.all, appLocalizations.routingModeAll),
      (TunnelMode.whitelist, appLocalizations.routingModeOnlySelected),
      (TunnelMode.blacklist, appLocalizations.routingModeAllExcept),
    ];
    final caption = switch (_mode) {
      TunnelMode.all => appLocalizations.routingModeAllDesc,
      TunnelMode.whitelist => appLocalizations.routingModeOnlySelectedDesc,
      TunnelMode.blacklist => appLocalizations.routingModeAllExceptDesc,
    };
    // Horizontal segments + one concise caption for the active mode; the caption
    // carries the meaning so the segment labels stay short.
    final picker = Padding(
      padding: EdgeInsets.fromLTRB(16.mAp, 12.mAp, 16.mAp, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TunnelMode>(
            showSelectedIcon: false,
            segments: [
              for (final (mode, label) in modes)
                ButtonSegment(value: mode, label: Text(label)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => _switchMode(s.first),
          ),
          SizedBox(height: 8.mAp),
          Text(
            caption,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    final bodyLen = allMode ? 0 : (filtered.isEmpty ? 1 : rows.length);
    return CommonScaffold(
      title: appLocalizations.routingApps,
      actions: [
        PopupMenuButton<int>(
          onSelected: (v) {
            if (v == 0) setState(() => _hideSystem = !_hideSystem);
            if (v == 1) _resetApps();
          },
          itemBuilder: (_) => [
            CheckedPopupMenuItem(
              value: 0,
              checked: _hideSystem,
              child: Text(appLocalizations.routingHideSystemApps),
            ),
            PopupMenuItem(value: 1, child: Text(appLocalizations.reset)),
          ],
        ),
      ],
      body: Column(
        children: [
          if (degenerate) _bothBanner(model),
          if (!allMode)
            _dim(
              degenerate,
              Padding(
                padding: EdgeInsets.fromLTRB(16.mAp, 12.mAp, 16.mAp, 8.mAp),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: appLocalizations.appRoutingSearchHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
          // Picker rides at the top of the scroll so it frees the screen for the
          // app list on short displays instead of pinning a header.
          Expanded(
            child: _dim(
              degenerate,
              ListView.builder(
                itemCount: 1 + (allMode ? 0 : 1) + bodyLen,
                itemBuilder: (_, i) {
                  if (i == 0) return picker;
                  if (i == 1) return const Divider(height: 0);
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.mAp),
                      child: Center(
                        child: NullStatus(
                          label: appLocalizations.nullTip(
                            appLocalizations.routingApps,
                          ),
                        ),
                      ),
                    );
                  }
                  final row = rows[i - 2];
                  return row.header != null
                      ? ListHeader(title: row.header!)
                      : _appRow(row.pkg!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Shared helpers
// ===========================================================================

Widget _destChip(BuildContext context, Destination d, VoidCallback onTap) {
  final style = _destStyle(context, d);
  return CommonChip(
    label: style.label,
    type: ChipType.tonal,
    tonalColor: style.color,
    avatar: Icon(style.icon, size: 16, color: style.color),
    onPressed: onTap,
  );
}

({String label, IconData icon, Color color}) _destStyle(
  BuildContext context,
  Destination d,
) => switch (d) {
  ToVpn() => (
    label: appLocalizations.routingViaVpn,
    icon: Icons.vpn_lock_outlined,
    color: context.colorScheme.primary,
  ),
  ToBypass() => (
    label: appLocalizations.routingAppBypass,
    icon: Icons.arrow_outward,
    color: context.colorScheme.onSurfaceVariant,
  ),
  ToBlock() => (
    label: appLocalizations.routingBlock,
    icon: Icons.block,
    color: context.colorScheme.error,
  ),
  ToScenario(:final name) => (
    label: name,
    icon: Icons.alt_route_outlined,
    color: context.colorScheme.tertiary,
  ),
};

IconData _kindIcon(ListKind k) => switch (k) {
  ListKind.url => Icons.link_outlined,
  ListKind.paste => Icons.content_paste_outlined,
  ListKind.country => Icons.flag_outlined,
};

String _kindLabel(ListKind k) => switch (k) {
  ListKind.url => appLocalizations.routingListFromLink,
  ListKind.paste => appLocalizations.routingListPasted,
  ListKind.country => appLocalizations.routingListByCountry,
};

String _locale(BuildContext context) {
  final l = Localizations.localeOf(context);
  return l.countryCode != null && l.countryCode!.isNotEmpty
      ? '${l.languageCode}_${l.countryCode}'
      : l.languageCode;
}

// Appends -2, -3, ... until the name is free. Sub-rule / group / server names
// key a map on write, so a collision silently drops the earlier entry.
String _uniqueName(String base, Set<String> taken) {
  var unique = base;
  var n = 2;
  while (taken.contains(unique)) {
    unique = '$base-${n++}';
  }
  return unique;
}

String _slug(String name) {
  // Keep any-script letters/digits (mihomo provider/sub-rule keys accept them),
  // so a Cyrillic name stays readable instead of collapsing to list-<hash>.
  final base = name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return base.isEmpty ? 'list-${name.hashCode.abs()}' : base;
}

String _formatFromUrl(String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.mrs')) return 'mrs';
  if (lower.endsWith('.txt')) return 'text';
  return 'yaml';
}
