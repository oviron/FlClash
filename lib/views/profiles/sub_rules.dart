import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/views/profiles/routing_rules_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists and edits a profile's `sub-rules:` (named rule lists that routing or
/// app rules can target). Live-mirrors the raw YAML via [AppRoutingController].
class SubRulesView extends ConsumerStatefulWidget {
  final int profileId;

  const SubRulesView({super.key, required this.profileId});

  @override
  ConsumerState<SubRulesView> createState() => _SubRulesViewState();
}

class _SubRulesViewState extends ConsumerState<SubRulesView> {
  Map<String, List<RoutingRule>> _subRules = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sub = await appController.readSubRules(widget.profileId);
    if (!mounted) return;
    setState(() {
      _subRules = sub;
      _loading = false;
    });
  }

  Future<void> _apply(Map<String, List<RoutingRule>> next) async {
    final error = await appController.writeSubRules(widget.profileId, next);
    if (!mounted) return;
    if (error != null) {
      context.showNotifier(error);
    } else {
      setState(() => _subRules = next);
    }
  }

  Future<void> _create() async {
    final name = await _promptName(appLocalizations.subRuleNew, '');
    if (name == null || name.isEmpty || !mounted) return;
    if (_subRules.containsKey(name)) {
      context.showNotifier(appLocalizations.subRuleNameExists);
      return;
    }
    await _apply({..._subRules, name: const []});
  }

  Future<void> _rename(String oldName) async {
    final name = await _promptName(appLocalizations.subRuleRename, oldName);
    if (name == null || name.isEmpty || name == oldName || !mounted) return;
    if (_subRules.containsKey(name)) {
      context.showNotifier(appLocalizations.subRuleNameExists);
      return;
    }
    final next = <String, List<RoutingRule>>{};
    _subRules.forEach((k, v) => next[k == oldName ? name : k] = v);
    await _apply(next);
  }

  Future<void> _delete(String name) async {
    final ok = await _confirmDelete(name);
    if (ok != true || !mounted) return;
    await _apply({..._subRules}..remove(name));
  }

  void _openEditor(String name) {
    BaseNavigator.push(
      context,
      _SubRuleEditorView(
        name: name,
        rules: _subRules[name] ?? const [],
        onChanged: (rules) async {
          final next = {..._subRules, name: rules};
          final error = await appController.writeSubRules(
            widget.profileId,
            next,
          );
          if (error == null && mounted) setState(() => _subRules = next);
          return error;
        },
      ),
    );
  }

  Future<String?> _promptName(String title, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => CommonDialog(
        title: title,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(appLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: CommonTextField(
          controller: controller,
          autofocus: true,
          labelText: appLocalizations.name,
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String name) => showDialog<bool>(
    context: context,
    builder: (ctx) => CommonDialog(
      title: name,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(appLocalizations.delete),
        ),
      ],
      child: Text(appLocalizations.subRuleDeleteConfirm),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.subRules,
      floatingActionButton: CommonFloatingActionButton(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: appLocalizations.add,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subRules.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.subRule),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final entry in _subRules.entries)
                  ListItem(
                    leading: const Icon(Icons.alt_route),
                    title: Text(entry.key),
                    subtitle: Text(
                      appLocalizations.subRuleRuleCount(entry.value.length),
                    ),
                    onTap: () => _openEditor(entry.key),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: appLocalizations.edit,
                          icon: const Icon(Icons.drive_file_rename_outline),
                          onPressed: () => _rename(entry.key),
                        ),
                        IconButton(
                          tooltip: appLocalizations.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(entry.key),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SubRuleEditorView extends StatelessWidget {
  final String name;
  final List<RoutingRule> rules;
  final Future<String?> Function(List<RoutingRule>) onChanged;

  const _SubRuleEditorView({
    required this.name,
    required this.rules,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: name,
      body: RoutingRulesEditor(rules: rules, onChanged: onChanged),
    );
  }
}
