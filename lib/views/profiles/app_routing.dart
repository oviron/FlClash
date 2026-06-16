import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDefault = '';
const _kDirect = 'DIRECT';
const _kReject = 'REJECT';
const _kGlobal = 'GLOBAL';

enum _View { apps, rules }

class _IdRule {
  final int id;
  final RoutingRule rule;

  const _IdRule(this.id, this.rule);
}

/// Per-app routing. Two surfaces over the same profile-YAML `rules:` block,
/// live-mirrored via [AppRoutingController]:
/// - Apps: app-centric, one `PROCESS-NAME,<pkg>,<target>` per app.
/// - All rules: the full ordered rule list, typed rows editable, passthrough
///   (AND/OR/NOT/SUB-RULE/MATCH) rows read-only and preserved verbatim.
class AppRoutingView extends ConsumerStatefulWidget {
  final int profileId;

  const AppRoutingView({super.key, required this.profileId});

  @override
  ConsumerState<AppRoutingView> createState() => _AppRoutingViewState();
}

class _AppRoutingViewState extends ConsumerState<AppRoutingView> {
  List<_IdRule> _rows = const [];
  int _nextId = 0;
  bool _loading = true;
  _View _view = _View.apps;

  @override
  void initState() {
    super.initState();
    unawaited(appController.getPackages());
    _load();
  }

  Future<void> _load() async {
    final rules = await appController.readRoutingRules(widget.profileId);
    if (!mounted) return;
    setState(() {
      _rows = [for (final r in rules) _IdRule(_nextId++, r)];
      _loading = false;
    });
  }

  List<RoutingRule> get _rules => [for (final e in _rows) e.rule];

  Map<String, TypedRule> get _byPackage {
    final map = <String, TypedRule>{};
    for (final r in _rules) {
      if (r is TypedRule && r.action == RuleAction.PROCESS_NAME) {
        map[r.value] = r;
      }
    }
    return map;
  }

  Future<void> _persist(List<_IdRule> next) async {
    setState(() => _rows = next);
    final error = await appController.writeRoutingRules(widget.profileId, [
      for (final e in next) e.rule,
    ]);
    if (error != null && mounted) {
      context.showNotifier(error);
      await _load();
    }
  }

  // ---- Apps surface ----

  Future<void> _setTarget(String packageName, String target) async {
    final next = [
      for (final e in _rows)
        if (!(e.rule is TypedRule &&
            (e.rule as TypedRule).action == RuleAction.PROCESS_NAME &&
            (e.rule as TypedRule).value == packageName))
          e,
    ];
    if (target != _kDefault) {
      next.insert(
        0,
        _IdRule(
          _nextId++,
          TypedRule(
            action: RuleAction.PROCESS_NAME,
            value: packageName,
            target: target,
          ),
        ),
      );
    }
    await _persist(next);
  }

  Future<void> _pickTarget(Package package) async {
    final current = _byPackage[package.packageName]?.target ?? _kDefault;
    final picked = await _showTargetSheet(
      title: package.label,
      current: current,
      includeDefault: true,
    );
    if (picked != null && picked != current) {
      await _setTarget(package.packageName, picked);
    }
  }

  Future<String?> _showTargetSheet({
    required String title,
    required String current,
    required bool includeDefault,
  }) {
    final groups = ref.read(currentGroupsStateProvider).value;
    final options = <({String value, String label})>[
      if (includeDefault)
        (value: _kDefault, label: appLocalizations.appRoutingDefault),
      (value: _kDirect, label: _kDirect),
      (value: _kReject, label: _kReject),
      (value: _kGlobal, label: _kGlobal),
      for (final g in groups) (value: g.name, label: g.name),
    ];
    return showSheet<String>(
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
                title: Text(o.label),
                trailing: o.value == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
          ],
        ),
      ),
    );
  }

  // ---- All-rules surface ----

  bool _editable(RoutingRule r) =>
      r is TypedRule && r.action != RuleAction.MATCH;

  Future<void> _editRule(int index) async {
    final result = await showSheet<TypedRule>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => _RuleEditorSheet(
        type: type,
        initial: _rows[index].rule as TypedRule,
        pickTarget: (current) => _showTargetSheet(
          title: appLocalizations.ruleTarget,
          current: current,
          includeDefault: false,
        ),
      ),
    );
    if (result == null) return;
    final next = [..._rows];
    next[index] = _IdRule(_rows[index].id, result);
    await _persist(next);
  }

  Future<void> _addRule() async {
    final result = await showSheet<TypedRule>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => _RuleEditorSheet(
        type: type,
        initial: null,
        pickTarget: (current) => _showTargetSheet(
          title: appLocalizations.ruleTarget,
          current: current,
          includeDefault: false,
        ),
      ),
    );
    if (result == null) return;
    await _persist([_IdRule(_nextId++, result), ..._rows]);
  }

  Future<void> _deleteRule(int index) async {
    final next = [..._rows]..removeAt(index);
    await _persist(next);
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final next = [..._rows];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    next.insert(adjusted, next.removeAt(oldIndex));
    await _persist(next);
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final findProcessOff =
        ref.watch(patchClashConfigProvider.select((s) => s.findProcessMode)) ==
        FindProcessMode.off;
    return CommonScaffold(
      title: appLocalizations.appRouting,
      actions: _view == _View.rules
          ? [
              IconButton(
                tooltip: appLocalizations.add,
                onPressed: _addRule,
                icon: const Icon(Icons.add),
              ),
            ]
          : const [],
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
                Expanded(
                  child: _view == _View.apps
                      ? _AppsList(byPackage: _byPackage, onTap: _pickTarget)
                      : _buildRulesTable(context),
                ),
              ],
            ),
    );
  }

  Widget _buildRulesTable(BuildContext context) {
    if (_rows.isEmpty) {
      return NullStatus(label: appLocalizations.nullTip(appLocalizations.rule));
    }
    final mono = context.textTheme.bodyMedium?.toJetBrainsMono;
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _rows.length,
      onReorder: _reorder,
      itemBuilder: (_, index) {
        final row = _rows[index];
        final editable = _editable(row.rule);
        return ListTile(
          key: ValueKey(row.id),
          leading: editable
              ? const Icon(Icons.tune, size: 18)
              : const Icon(Icons.lock_outline, size: 18),
          title: Text(row.rule.serialize(), style: mono),
          onTap: editable ? () => _editRule(index) : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteRule(index),
          ),
        );
      },
    );
  }
}

class _AppsList extends ConsumerWidget {
  final Map<String, TypedRule> byPackage;
  final Future<void> Function(Package) onTap;

  const _AppsList({required this.byPackage, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref
        .watch(packagesProvider)
        .where((p) => !p.system)
        .sortedByLabel();
    return ListView.builder(
      itemCount: packages.length,
      itemExtent: 72,
      itemBuilder: (_, index) {
        final package = packages[index];
        final rule = byPackage[package.packageName];
        return ListTile(
          leading: SizedBox(
            width: 44,
            height: 44,
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
          subtitle: Text(
            package.packageName,
            maxLines: 1,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          trailing: Chip(
            label: Text(rule?.target ?? appLocalizations.appRoutingDefault),
            visualDensity: VisualDensity.compact,
          ),
          onTap: () => onTap(package),
        );
      },
    );
  }
}

class _RuleEditorSheet extends StatefulWidget {
  final SheetType type;
  final TypedRule? initial;
  final Future<String?> Function(String current) pickTarget;

  const _RuleEditorSheet({
    required this.type,
    required this.initial,
    required this.pickTarget,
  });

  @override
  State<_RuleEditorSheet> createState() => _RuleEditorSheetState();
}

class _RuleEditorSheetState extends State<_RuleEditorSheet> {
  late RuleAction _action;
  late final TextEditingController _value;
  late final TextEditingController _target;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _action = widget.initial?.action ?? RuleAction.PROCESS_NAME;
    _value = TextEditingController(text: widget.initial?.value ?? '');
    _target = TextEditingController(text: widget.initial?.target ?? '');
  }

  @override
  void dispose() {
    _value.dispose();
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(
      context,
    ).pop(TypedRule(action: _action, value: _value.text, target: _target.text));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: widget.initial == null
          ? appLocalizations.addRule
          : appLocalizations.editRule,
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<RuleAction>(
              initialValue: _action,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.ruleName,
              ),
              items: [
                for (final a in RuleAction.addedRuleActions)
                  DropdownMenuItem(value: a, child: Text(a.value)),
              ],
              onChanged: (v) => setState(() => _action = v ?? _action),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _value,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.content,
              ),
              validator: (_) => _value.text.isEmpty
                  ? appLocalizations.emptyTip(appLocalizations.content)
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _target,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.ruleTarget,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.layers_outlined),
                  onPressed: () async {
                    final picked = await widget.pickTarget(_target.text);
                    if (picked != null) _target.text = picked;
                  },
                ),
              ),
              validator: (_) => _target.text.isEmpty
                  ? appLocalizations.emptyTip(appLocalizations.ruleTarget)
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(appLocalizations.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Iterable<Package> {
  List<Package> sortedByLabel() {
    final list = toList();
    list.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }
}
