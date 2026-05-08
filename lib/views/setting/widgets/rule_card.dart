// Rule card. Disabled rules render at lowered opacity; that is independent
// of the master toggle (which dims the whole list at the screen level).

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RuleCard extends ConsumerWidget {
  final NetworkRule rule;
  final int dragIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleEnabled;

  const RuleCard({
    super.key,
    required this.rule,
    required this.dragIndex,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  String _actionLabel(NetworkAction action) {
    switch (action) {
      case NetworkAction.turnOn:
        return appLocalizations.networkRulesActionShortOn;
      case NetworkAction.turnOff:
        return appLocalizations.networkRulesActionShortOff;
      case NetworkAction.keep:
        // Legacy data only — UI never creates this any more. Render as a
        // muted dash so the user can tell the rule still exists and edit
        // it to a real action.
        return '—';
    }
  }

  Color _actionColor(BuildContext context, NetworkAction action) {
    final scheme = Theme.of(context).colorScheme;
    switch (action) {
      case NetworkAction.turnOn:
        return scheme.primary;
      case NetworkAction.turnOff:
        return scheme.error;
      case NetworkAction.keep:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionProvider);
    final hasPermission =
        permissionState == LocationPermissionState.granted;
    final scheme = Theme.of(context).colorScheme;

    final chips = <Widget>[
      for (final c in rule.conditions)
        _ConditionChip(condition: c, hasPermission: hasPermission),
    ];

    return Opacity(
      key: ValueKey('rule-card-${rule.id}'),
      opacity: rule.enabled ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: dragIndex,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rule.name != null && rule.name!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              rule.name!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...chips,
                            const Icon(Icons.arrow_right_alt, size: 18),
                            Text(
                              _actionLabel(rule.action),
                              style: context.textTheme.titleSmall?.copyWith(
                                color: _actionColor(context, rule.action),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_RuleMenu>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case _RuleMenu.edit:
                          onEdit();
                        case _RuleMenu.delete:
                          onDelete();
                        case _RuleMenu.toggle:
                          onToggleEnabled();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _RuleMenu.edit,
                        child: Text(appLocalizations.networkRulesEdit),
                      ),
                      PopupMenuItem(
                        value: _RuleMenu.toggle,
                        child: Text(
                          rule.enabled
                              ? appLocalizations.networkRulesDisable
                              : appLocalizations.networkRulesEnableShort,
                        ),
                      ),
                      PopupMenuItem(
                        value: _RuleMenu.delete,
                        child: Text(appLocalizations.networkRulesDelete),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RuleMenu { edit, toggle, delete }

class _ConditionChip extends StatelessWidget {
  final NetworkCondition condition;
  final bool hasPermission;

  const _ConditionChip({
    required this.condition,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = condition;
    if (c is WifiNamed) {
      final showWarning = !hasPermission;
      return Chip(
        avatar: Icon(
          showWarning ? Icons.warning_amber : Icons.wifi,
          size: 18,
          color: showWarning ? scheme.error : null,
        ),
        label: Text(
          showWarning
              ? '${c.ssid} (${appLocalizations.permissionRequiredHint})'
              : c.ssid,
        ),
        visualDensity: VisualDensity.compact,
      );
    }
    if (c is AnyWifi) {
      return Chip(
        avatar: const Icon(Icons.wifi, size: 18),
        label: Text(appLocalizations.networkRulesConditionAnyWifi),
        visualDensity: VisualDensity.compact,
      );
    }
    if (c is AnyCellular) {
      return Chip(
        avatar: const Icon(Icons.signal_cellular_alt, size: 18),
        label: Text(appLocalizations.networkRulesConditionAnyCellular),
        visualDensity: VisualDensity.compact,
      );
    }
    return const SizedBox.shrink();
  }
}
