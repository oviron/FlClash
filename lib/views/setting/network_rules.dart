import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/network_rules/engine.dart';
import 'package:fl_clash/views/setting/location_permission_gate.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/network_rules.dart';
import 'package:fl_clash/providers/network_rules_settings.dart';
import 'package:fl_clash/providers/network_state.dart';
import 'package:fl_clash/views/setting/widgets/edit_rule_dialog.dart';
import 'package:fl_clash/views/setting/widgets/rule_card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkRulesView extends ConsumerStatefulWidget {
  const NetworkRulesView({super.key});

  @override
  ConsumerState<NetworkRulesView> createState() => _NetworkRulesViewState();
}

class _NetworkRulesViewState extends ConsumerState<NetworkRulesView> {
  @override
  void initState() {
    super.initState();
    // Reconcile with the OS on entry so a grant made earlier (or revoked in
    // Settings) is reflected instead of a stale cached value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationPermissionProvider.notifier).refresh();
    });
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final created = await EditRuleDialog.show(context: context);
    if (created == null) return;
    await ref.read(networkRulesRepoProvider.notifier).add(created);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(networkRulesSettingsProvider);
    final rulesAsync = ref.watch(networkRulesStreamProvider);

    return BaseScaffold(
      title: appLocalizations.networkRulesTitle,
      body: Stack(
        children: [
          Column(
            children: [
              _MasterToggleCard(enabled: settings.enabled),
              _DefaultActionCard(
                enabled: settings.enabled,
                value: settings.defaultAction,
              ),
              const _StatusLine(),
              const Divider(height: 0),
              const _PermissionBanner(),
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
              onPressed: () => _openCreateDialog(context),
              icon: const Icon(Icons.add),
              label: Text(appLocalizations.networkRulesAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends ConsumerWidget {
  const _PermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPermissionProvider);
    // notDetermined = OS not read yet; granted = fine. Neither is an error to
    // surface, so the banner stays hidden and never flashes on a fresh open.
    if (state == LocationPermissionState.granted ||
        state == LocationPermissionState.notDetermined) {
      return const SizedBox.shrink();
    }

    final rules = ref.watch(networkRulesStreamProvider).value ?? const [];
    final needsWifi = rules.any(
      (r) =>
          r.enabled && r.conditions.any((c) => c is WifiNamed || c is AnyWifi),
    );
    if (!needsWifi) return const SizedBox.shrink();

    final serviceOff = state == LocationPermissionState.serviceDisabled;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.errorContainer,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              serviceOff
                  ? appLocalizations.locationServicesDisabled
                  : appLocalizations.networkRulesPermissionBanner,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: () => ensureLocationPermissionForSsid(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: scheme.onErrorContainer,
            ),
            child: Text(
              serviceOff
                  ? appLocalizations.openSettings
                  : appLocalizations.permissionAllow,
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

class _DefaultActionCard extends ConsumerWidget {
  final bool enabled;
  final DefaultNetworkAction value;

  const _DefaultActionCard({required this.enabled, required this.value});

  String _label(DefaultNetworkAction action) {
    switch (action) {
      case DefaultNetworkAction.leaveAsIs:
        return appLocalizations.networkRulesDefaultLeave;
      case DefaultNetworkAction.turnOn:
        return appLocalizations.networkRulesDefaultTurnOn;
      case DefaultNetworkAction.turnOff:
        return appLocalizations.networkRulesDefaultTurnOff;
    }
  }

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final picked = await showDialog<DefaultNetworkAction>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(appLocalizations.networkRulesDefaultActionTitle),
        children: [
          for (final action in DefaultNetworkAction.values)
            ListTile(
              title: Text(_label(action)),
              trailing: action == value ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop(action),
            ),
        ],
      ),
    );
    if (picked != null) {
      ref.read(networkRulesSettingsProvider.notifier).setDefaultAction(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ListTile(
        enabled: enabled,
        leading: const Icon(Icons.rule_outlined),
        title: Text(appLocalizations.networkRulesDefaultActionTitle),
        subtitle: Text(_label(value)),
        onTap: enabled ? () => _choose(context, ref) : null,
      ),
    );
  }
}

class _StatusLine extends ConsumerWidget {
  const _StatusLine();

  String _decisionLabel(NetworkDecision decision) {
    switch (decision) {
      case NetworkDecision.start:
        return appLocalizations.networkRulesDefaultTurnOn;
      case NetworkDecision.stop:
        return appLocalizations.networkRulesDefaultTurnOff;
      case NetworkDecision.leaveAsIs:
        return appLocalizations.networkRulesDefaultLeave;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(networkRulesSettingsProvider);
    if (!settings.enabled) return const SizedBox.shrink();
    final theme = context.textTheme;
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(lastNetworkRuleStatusProvider);

    final String text;
    final bool overridden;
    if (status != null) {
      text = status.reason;
      overridden = status.overridden;
    } else {
      // The resident service hasn't reported yet (just enabled / cold start):
      // show a local preview from the same engine so the line isn't blank.
      final rules = ref.watch(networkRulesStreamProvider).value ?? const [];
      final snapshot = ref.watch(currentNetworkSnapshotProvider);
      final decision = resolveNetworkDecision(
        rules: rules,
        snapshot: snapshot,
        defaultAction: settings.defaultAction,
      );
      text = _decisionLabel(decision);
      overridden = false;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${appLocalizations.networkRulesStatusLabel}: $text',
            style: theme.bodySmall,
          ),
          if (overridden)
            Text(
              appLocalizations.networkRulesOverrideActive,
              style: theme.bodySmall?.copyWith(color: scheme.primary),
            ),
        ],
      ),
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
