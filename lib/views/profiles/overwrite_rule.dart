import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:flutter/material.dart';

class RuleItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Rule rule;
  final void Function() onSelected;
  final void Function(Rule rule) onEdit;

  const RuleItem({
    super.key,
    required this.isSelected,
    required this.rule,
    required this.onSelected,
    required this.onEdit,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return CommonSelectedListItem(
      isSelected: isSelected,
      onSelected: () {
        onSelected();
      },
      title: Text(
        rule.value,
        style: context.textTheme.bodyMedium?.toJetBrainsMono,
      ),
      onPressed: () {
        onEdit(rule);
      },
    );
  }
}

class RuleStatusItem extends StatelessWidget {
  final bool status;
  final Rule rule;
  final void Function(bool) onChange;

  const RuleStatusItem({
    super.key,
    required this.status,
    required this.rule,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        padding: EdgeInsets.zero,
        radius: 18,
        type: CommonCardType.filled,
        child: ListItem.switchItem(
          titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
          minTileHeight: 0,
          minVerticalPadding: 16,
          title: Text(rule.value),
          delegate: SwitchDelegate(value: status, onChanged: onChange),
        ),
      ),
    );
  }
}

class AddOrEditRuleDialog extends StatefulWidget {
  final Rule? rule;

  const AddOrEditRuleDialog({super.key, this.rule});

  @override
  State<AddOrEditRuleDialog> createState() => _AddOrEditRuleDialogState();
}

class _AddOrEditRuleDialogState extends State<AddOrEditRuleDialog> {
  late RuleAction _ruleAction;
  final _ruleTargetController = TextEditingController();
  final _contentController = TextEditingController();
  bool _noResolve = false;
  bool _src = false;
  List<String> _targetItems = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initState();
    super.initState();
  }

  List<String> _buildTargetItems(RuleAction action) {
    return RuleTarget.values
        .where((item) => item != RuleTarget.MATCH || action == RuleAction.MATCH)
        .map((item) => item.name)
        .toList();
  }

  void _initState() {
    if (widget.rule != null) {
      final parsedRule = ParsedRule.parseString(widget.rule!.value);
      _ruleAction = parsedRule.ruleAction;
      _targetItems = _buildTargetItems(_ruleAction);
      _contentController.text = parsedRule.content ?? '';
      _ruleTargetController.text = parsedRule.ruleTarget ?? '';
      _noResolve = parsedRule.noResolve;
      _src = parsedRule.src;
      return;
    }
    _ruleAction = RuleAction.addedRuleActions.first;
    _targetItems = _buildTargetItems(_ruleAction);
    if (_targetItems.isNotEmpty) {
      _ruleTargetController.text = _targetItems.first;
    }
  }

  @override
  void didUpdateWidget(AddOrEditRuleDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _initState();
    }
  }

  @override
  void dispose() {
    _ruleTargetController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final res = _formKey.currentState?.validate();
    if (res == false) {
      return;
    }
    final parsedRule = ParsedRule(
      ruleAction: _ruleAction,
      content: _contentController.text,
      ruleTarget: _ruleTargetController.text,
      noResolve: _noResolve,
      src: _src,
    );
    final rule = widget.rule != null
        ? widget.rule!.copyWith(value: parsedRule.value)
        : Rule.value(parsedRule.value);
    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.rule != null
          ? appLocalizations.editRule
          : appLocalizations.addRule,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    _ruleAction =
                        await globalState.showCommonDialog<RuleAction>(
                          filter: false,
                          child: OptionsDialog<RuleAction>(
                            title: appLocalizations.ruleName,
                            options: RuleAction.addedRuleActions,
                            textBuilder: (item) => item.value,
                            value: _ruleAction,
                          ),
                        ) ??
                        _ruleAction;
                    _targetItems = _buildTargetItems(_ruleAction);
                    final currentTarget = _ruleTargetController.text
                        .toUpperCase();
                    final hasCurrent = _targetItems.any(
                      (i) => i.toUpperCase() == currentTarget,
                    );
                    if (!hasCurrent && _targetItems.isNotEmpty) {
                      _ruleTargetController.text = _targetItems.first;
                    }
                    setState(() {});
                  },
                  child: Text(_ruleAction.value),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (_) {
                    _handleSubmit();
                  },
                  controller: _contentController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.content,
                  ),
                  validator: (_) {
                    if (_contentController.text.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.content,
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FormField<String>(
                  validator: (_) => _ruleTargetController.text.isEmpty
                      ? appLocalizations.emptyTip(appLocalizations.ruleTarget)
                      : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          final picked = await globalState
                              .showCommonDialog<String>(
                                filter: false,
                                child: OptionsDialog<String>(
                                  title: appLocalizations.ruleTarget,
                                  options: _targetItems,
                                  textBuilder: (s) => s,
                                  value: _ruleTargetController.text,
                                ),
                              );
                          if (picked != null) {
                            setState(() => _ruleTargetController.text = picked);
                          }
                        },
                        child: Text(
                          _ruleTargetController.text.isEmpty
                              ? appLocalizations.ruleTarget
                              : _ruleTargetController.text,
                        ),
                      ),
                      if (field.errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_ruleAction.hasParams) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: [
                      CommonCard(
                        radius: 8,
                        isSelected: _src,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            appLocalizations.sourceIp,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _src = !_src;
                          });
                        },
                      ),
                      CommonCard(
                        radius: 8,
                        isSelected: _noResolve,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            appLocalizations.noResolve,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _noResolve = !_noResolve;
                          });
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
