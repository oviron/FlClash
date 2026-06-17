import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/rule_block_builder.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDirect = 'DIRECT';
const _kReject = 'REJECT';
const _kGlobal = 'GLOBAL';

class _Row {
  final int id;
  final RoutingRule rule;

  const _Row(this.id, this.rule);
}

/// Reorderable editor over an in-memory rule list, shared by the per-app
/// "All rules" surface and the sub-rule editor. Typed rows (except MATCH) are
/// editable; logical/SUB-RULE/MATCH rows are read-only and preserved verbatim.
/// Each mutation calls [onChanged]; a non-null return (a validation error)
/// reverts the optimistic edit and is surfaced to the user.
class RoutingRulesEditor extends ConsumerStatefulWidget {
  final List<RoutingRule> rules;
  final Future<String?> Function(List<RoutingRule>) onChanged;

  const RoutingRulesEditor({
    super.key,
    required this.rules,
    required this.onChanged,
  });

  @override
  ConsumerState<RoutingRulesEditor> createState() => _RoutingRulesEditorState();
}

class _RoutingRulesEditorState extends ConsumerState<RoutingRulesEditor> {
  late List<_Row> _rows;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(RoutingRulesEditor old) {
    super.didUpdateWidget(old);
    if (!identical(old.rules, widget.rules)) setState(_seed);
  }

  void _seed() {
    _rows = [for (final r in widget.rules) _Row(_nextId++, r)];
  }

  bool _editable(RoutingRule r) =>
      (r is TypedRule && r.action != RuleAction.MATCH) || r is LogicalRule;

  IconData _leadingIcon(RoutingRule r) {
    if (r is LogicalRule) return Icons.account_tree_outlined;
    if (_editable(r)) return Icons.tune;
    return Icons.lock_outline;
  }

  Future<void> _commit(List<_Row> next) async {
    final prev = _rows;
    setState(() => _rows = next);
    final error = await widget.onChanged([for (final e in next) e.rule]);
    if (error != null && mounted) {
      context.showNotifier(error);
      setState(() => _rows = prev);
    }
  }

  Future<void> _add() async {
    final advanced = await _pickAddKind();
    if (advanced == null) return;
    final result = advanced ? await _blockSheet(null) : await _editSheet(null);
    if (result == null) return;
    await _commit([_Row(_nextId++, result), ..._rows]);
  }

  /// Offers both flat-typed and logical/advanced rule creation. Returns true for
  /// advanced (block builder), false for flat, null if dismissed.
  Future<bool?> _pickAddKind() => showSheet<bool>(
    context: context,
    props: const SheetProps(isScrollControlled: true),
    builder: (_, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.addRule,
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(appLocalizations.addRule),
            onTap: () => Navigator.of(context).pop(false),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(appLocalizations.addLogicalRule),
            onTap: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );

  Future<void> _edit(int index) async {
    final rule = _rows[index].rule;
    final result = rule is LogicalRule
        ? await _blockSheet(rule)
        : await _editSheet(rule as TypedRule);
    if (result == null) return;
    final next = [..._rows];
    next[index] = _Row(_rows[index].id, result);
    await _commit(next);
  }

  Future<void> _delete(int index) async {
    final next = [..._rows]..removeAt(index);
    await _commit(next);
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final next = [..._rows];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    next.insert(adjusted, next.removeAt(oldIndex));
    await _commit(next);
  }

  Future<TypedRule?> _editSheet(TypedRule? initial) => showSheet<TypedRule>(
    context: context,
    props: const SheetProps(isScrollControlled: true),
    builder: (_, type) => _RuleEditorSheet(
      type: type,
      initial: initial,
      pickTarget: _showTargetSheet,
    ),
  );

  Future<LogicalRule?> _blockSheet(LogicalRule? initial) =>
      showSheet<LogicalRule>(
        context: context,
        props: const SheetProps(isScrollControlled: true),
        builder: (_, type) => RuleBlockBuilder(
          type: type,
          initial: initial ?? defaultLogicalRule(_kDirect),
          pickTarget: _showTargetSheet,
        ),
      );

  Future<String?> _showTargetSheet(String current) {
    final groups = ref.read(currentGroupsStateProvider).value;
    final options = <String>[
      _kDirect,
      _kReject,
      _kGlobal,
      for (final g in groups) g.name,
    ];
    return showSheet<String>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.ruleTarget,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: o == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(o),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mono = context.textTheme.bodyMedium?.toJetBrainsMono;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.add),
            ),
          ),
        ),
        Expanded(
          child: _rows.isEmpty
              ? NullStatus(
                  label: appLocalizations.nullTip(appLocalizations.rule),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _rows.length,
                  onReorder: _reorder,
                  itemBuilder: (_, index) {
                    final row = _rows[index];
                    final editable = _editable(row.rule);
                    return ListTile(
                      key: ValueKey(row.id),
                      leading: Icon(_leadingIcon(row.rule), size: 18),
                      title: Text(row.rule.serialize(), style: mono),
                      onTap: editable ? () => _edit(index) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(index),
                      ),
                    );
                  },
                ),
        ),
      ],
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
                for (final a in editableRuleActions)
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
