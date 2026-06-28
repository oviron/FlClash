import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

const _logicalOps = [RuleAction.AND, RuleAction.OR, RuleAction.NOT];

/// Condition types a clause may use: every [RuleAction] except the logical
/// operators (they need their own block) and MATCH (no condition).
List<RuleAction> get clauseActions => RuleAction.values
    .where((a) => !_logicalOps.contains(a))
    .where((a) => a != RuleAction.SUB_RULE && a != RuleAction.MATCH)
    .toList();

/// A sane default logical rule for the "add advanced rule" affordance.
LogicalRule defaultLogicalRule(String target) => LogicalRule(
  op: RuleAction.AND,
  clauses: const [LogicalClause(action: RuleAction.DOMAIN, params: '')],
  target: target,
);

/// Sheet that edits a [LogicalRule] (op, clauses, target, toggles) with a live
/// serialize preview. NOT is constrained to a single clause; confirm returns the
/// rule, an invalid build keeps the sheet open.
class RuleBlockBuilder extends StatefulWidget {
  final SheetType type;
  final LogicalRule initial;
  final Future<String?> Function(String current) pickTarget;

  const RuleBlockBuilder({
    super.key,
    required this.type,
    required this.initial,
    required this.pickTarget,
  });

  @override
  State<RuleBlockBuilder> createState() => _RuleBlockBuilderState();
}

class _RuleBlockBuilderState extends State<RuleBlockBuilder> {
  late RuleAction _op;
  late List<LogicalClause> _clauses;
  late String _target;
  late bool _noResolve;
  late bool _src;

  late final List<TextEditingController> _params;

  @override
  void initState() {
    super.initState();
    _op = widget.initial.op;
    _clauses = [...widget.initial.clauses];
    _target = widget.initial.target;
    _noResolve = widget.initial.noResolve;
    _src = widget.initial.src;
    _params = [for (final c in _clauses) TextEditingController(text: c.params)];
  }

  @override
  void dispose() {
    for (final c in _params) {
      c.dispose();
    }
    super.dispose();
  }

  LogicalRule get _current => LogicalRule(
    op: _op,
    clauses: [
      for (var i = 0; i < _clauses.length; i++)
        LogicalClause(action: _clauses[i].action, params: _params[i].text),
    ],
    target: _target,
    noResolve: _noResolve,
    src: _src,
  );

  bool get _valid =>
      _target.isNotEmpty &&
      _clauses.isNotEmpty &&
      (_op != RuleAction.NOT || _clauses.length == 1) &&
      // Parens in a clause param would re-parse as Passthrough (uneditable).
      _params.every((c) => !c.text.contains('(') && !c.text.contains(')'));

  void _setOp(RuleAction op) {
    setState(() {
      _op = op;
      if (op == RuleAction.NOT && _clauses.length > 1) {
        _clauses = [_clauses.first];
        final keep = _params.first;
        for (final c in _params.skip(1)) {
          c.dispose();
        }
        _params
          ..clear()
          ..add(keep);
      }
    });
  }

  void _addClause() {
    setState(() {
      _clauses = [
        ..._clauses,
        const LogicalClause(action: RuleAction.DOMAIN, params: ''),
      ];
      _params.add(TextEditingController());
    });
  }

  void _removeClause(int index) {
    setState(() {
      _clauses = [..._clauses]..removeAt(index);
      _params.removeAt(index).dispose();
    });
  }

  void _setClauseAction(int index, RuleAction action) {
    setState(() {
      final next = [..._clauses];
      next[index] = LogicalClause(action: action, params: _params[index].text);
      _clauses = next;
    });
  }

  Future<void> _pickTarget() async {
    final picked = await widget.pickTarget(_target);
    if (picked != null) setState(() => _target = picked);
  }

  void _submit() {
    if (!_valid) {
      context.showNotifier(appLocalizations.ruleBlockInvalid);
      return;
    }
    Navigator.of(context).pop(_current);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isNot = _op == RuleAction.NOT;
    final canRemove = !isNot && _clauses.length > 1;
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.ruleBlockTitle,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text(appLocalizations.ruleBlockOperator, style: _label(context)),
          const SizedBox(height: 8),
          CommonTabBar<RuleAction>(
            groupValue: _op,
            thumbColor: context.colorScheme.secondaryContainer,
            proportionalWidth: false,
            onValueChanged: (v) {
              if (v != null) _setOp(v);
            },
            children: {
              RuleAction.AND: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(child: Text(appLocalizations.ruleOpAnd)),
              ),
              RuleAction.OR: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(child: Text(appLocalizations.ruleOpOr)),
              ),
              RuleAction.NOT: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(child: Text(appLocalizations.ruleOpNot)),
              ),
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(appLocalizations.ruleConditions, style: _label(context)),
              const Spacer(),
              if (!isNot)
                TextButton.icon(
                  onPressed: _addClause,
                  icon: const Icon(Icons.add),
                  label: Text(appLocalizations.ruleAddClause),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _clauses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListItem.options(
                      title: Text(_clauses[i].action.value),
                      subtitle: Text(appLocalizations.ruleConditionType),
                      delegate: OptionsDelegate<RuleAction>(
                        title: appLocalizations.ruleConditionType,
                        options: clauseActions,
                        value: _clauses[i].action,
                        textBuilder: (a) => a.value,
                        onChanged: (v) {
                          if (v != null) _setClauseAction(i, v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: CommonTextField(
                      controller: _params[i],
                      labelText: appLocalizations.ruleConditionParams,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: canRemove ? () => _removeClause(i) : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(appLocalizations.ruleTarget, style: _label(context)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickTarget,
            icon: const Icon(Icons.hub_outlined),
            label: Text(
              _target.isEmpty ? appLocalizations.ruleTargetPick : _target,
            ),
          ),
          const SizedBox(height: 16),
          ListItem.switchItem(
            title: Text(appLocalizations.sourceIp),
            delegate: SwitchDelegate(
              value: _src,
              onChanged: (v) => setState(() => _src = v),
            ),
          ),
          ListItem.switchItem(
            title: Text(appLocalizations.noResolve),
            delegate: SwitchDelegate(
              value: _noResolve,
              onChanged: (v) => setState(() => _noResolve = v),
            ),
          ),
          const SizedBox(height: 16),
          Text(appLocalizations.preview, style: _label(context)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _current.serialize(),
              style: context.textTheme.bodyMedium?.toJetBrainsMono,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _valid ? _submit : null,
            child: Text(appLocalizations.confirm),
          ),
        ],
      ),
    );
  }

  TextStyle? _label(BuildContext context) => context.textTheme.titleSmall;
}
