import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/providers/network_rules.dart';
import 'package:fl_clash/providers/network_rules_settings.dart';
import 'package:fl_clash/views/setting/widgets/edit_rule_dialog.dart';
import 'package:fl_clash/views/setting/widgets/rule_card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkRulesView extends ConsumerWidget {
  const NetworkRulesView({super.key});

  Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
    final created = await EditRuleDialog.show(context: context);
    if (created == null) return;
    await ref.read(networkRulesRepoProvider.notifier).add(created);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(networkRulesSettingsProvider);
    final rulesAsync = ref.watch(networkRulesStreamProvider);

    return BaseScaffold(
      title: appLocalizations.networkRulesTitle,
      body: Stack(
        children: [
          Column(
            children: [
              _MasterToggleCard(enabled: settings.enabled),
              const Divider(height: 0),
              Expanded(
                child: rulesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (rules) =>
                      _RulesList(rules: rules, masterEnabled: settings.enabled),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton.extended(
              onPressed: () => _openCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.networkRulesAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterToggleCard extends ConsumerWidget {
  final bool enabled;
  const _MasterToggleCard({required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      secondary: const Icon(Icons.toggle_on_outlined),
      title: Text(appLocalizations.networkRulesEnable),
      value: enabled,
      onChanged: (value) {
        ref.read(networkRulesSettingsProvider.notifier).setEnabled(value);
      },
    );
  }
}

class _RulesList extends ConsumerWidget {
  final List<NetworkRule> rules;
  final bool masterEnabled;

  const _RulesList({required this.rules, required this.masterEnabled});

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    NetworkRule rule,
  ) async {
    final updated = await EditRuleDialog.show(context: context, initial: rule);
    if (updated == null) return;
    await ref.read(networkRulesRepoProvider.notifier).update(updated);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    NetworkRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appLocalizations.networkRulesConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(appLocalizations.networkRulesDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(networkRulesRepoProvider.notifier).delete(rule.id);
  }

  Future<void> _toggleEnabled(WidgetRef ref, NetworkRule rule) async {
    await ref
        .read(networkRulesRepoProvider.notifier)
        .update(rule.copyWith(enabled: !rule.enabled));
  }

  Future<void> _onReorder(WidgetRef ref, int oldIndex, int newIndex) async {
    final ids = rules.map((r) => r.id).toList();
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = ids.removeAt(oldIndex);
    ids.insert(adjusted, moved);
    await ref.read(networkRulesRepoProvider.notifier).reorder(ids);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            appLocalizations.networkRulesEmpty,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Opacity(
      opacity: masterEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !masterEnabled,
        child: ReorderableListView.builder(
          itemCount: rules.length,
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.only(bottom: 160),
          onReorder: (oldIndex, newIndex) =>
              _onReorder(ref, oldIndex, newIndex),
          itemBuilder: (_, index) {
            final rule = rules[index];
            return RuleCard(
              key: ValueKey(rule.id),
              rule: rule,
              dragIndex: index,
              onEdit: () => _openEditDialog(context, ref, rule),
              onDelete: () => _confirmDelete(context, ref, rule),
              onToggleEnabled: () => _toggleEnabled(ref, rule),
            );
          },
        ),
      ),
    );
  }
}
