import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/widgets/widgets.dart';
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
    switch (action.vpn) {
      case NetworkVpnMode.turnOn:
        return appLocalizations.networkRulesActionShortOn;
      case NetworkVpnMode.turnOff:
        return appLocalizations.networkRulesActionShortOff;
      case NetworkVpnMode.leave:
        return appLocalizations.networkRulesActionShortLeave;
    }
  }

  Color _actionColor(BuildContext context, NetworkAction action) {
    final scheme = Theme.of(context).colorScheme;
    switch (action.vpn) {
      case NetworkVpnMode.turnOn:
        return scheme.primary;
      case NetworkVpnMode.turnOff:
        return scheme.error;
      case NetworkVpnMode.leave:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionProvider);
    final hasPermission = permissionState == LocationPermissionState.granted;
    final scheme = Theme.of(context).colorScheme;

    // No valid conditions survived decoding (e.g. a rule authored by a newer
    // version): surface it as invalid instead of a silently-dead "active" row.
    final isInvalid = rule.conditions.isEmpty;
    final join = rule.matchMode == NetworkMatchMode.any
        ? appLocalizations.networkRulesJoinOr
        : appLocalizations.networkRulesJoinAnd;
    final chips = <Widget>[
      for (var i = 0; i < rule.conditions.length; i++) ...[
        if (i > 0)
          Text(
            join,
            style: context.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        _ConditionChip(
          condition: rule.conditions[i],
          hasPermission: hasPermission,
        ),
      ],
    ];

    // Per-rule dim is independent of the master toggle (which dims the list).
    return Opacity(
      key: ValueKey('rule-card-${rule.id}'),
      opacity: rule.enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: CommonCard(
          type: CommonCardType.filled,
          radius: 16,
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
                          children: isInvalid
                              ? [
                                  CommonChip(
                                    type: ChipType.tonal,
                                    tonalColor: scheme.error,
                                    avatar: Icon(
                                      Icons.error_outline,
                                      size: 18,
                                      color: scheme.error,
                                    ),
                                    label: appLocalizations
                                        .networkRulesInvalidRule,
                                  ),
                                ]
                              : [
                                  ...chips,
                                  const Icon(Icons.arrow_right_alt, size: 18),
                                  Text(
                                    _actionLabel(rule.action),
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                          color: _actionColor(
                                            context,
                                            rule.action,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ),
                  CommonPopupBox(
                    targetBuilder: (open) => IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => open(),
                    ),
                    popup: CommonPopupMenu(
                      items: [
                        PopupMenuItemData(
                          icon: Icons.edit_outlined,
                          label: appLocalizations.networkRulesEdit,
                          onPressed: onEdit,
                        ),
                        PopupMenuItemData(
                          icon: rule.enabled
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          label: rule.enabled
                              ? appLocalizations.networkRulesDisable
                              : appLocalizations.networkRulesEnableShort,
                          onPressed: onToggleEnabled,
                        ),
                        PopupMenuItemData(
                          icon: Icons.delete_outline,
                          label: appLocalizations.networkRulesDelete,
                          onPressed: onDelete,
                          danger: true,
                        ),
                      ],
                    ),
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

class _ConditionChip extends ConsumerWidget {
  final NetworkCondition condition;
  final bool hasPermission;

  const _ConditionChip({required this.condition, required this.hasPermission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final negated = condition is Not;
    final c = negated ? (condition as Not).inner : condition;
    final prefix = negated ? '¬ ' : '';
    if (c is ProfileIs) {
      final match = ref
          .watch(profilesProvider)
          .where((p) => p.id == c.profileId);
      final name = match.isNotEmpty && match.first.label.isNotEmpty
          ? match.first.label
          : '#${c.profileId}';
      return CommonChip(
        type: ChipType.tonal,
        avatar: const Icon(Icons.layers_outlined, size: 18),
        label: '$prefix${appLocalizations.networkRulesConditionProfileIs}$name',
      );
    }
    if (c is WifiNamed) {
      final showWarning = !hasPermission;
      final pattern = switch (c.match) {
        WifiMatch.exact => c.ssid,
        WifiMatch.prefix => '${c.ssid}…',
        WifiMatch.contains => '…${c.ssid}…',
      };
      return CommonChip(
        type: ChipType.tonal,
        tonalColor: showWarning ? scheme.error : null,
        avatar: Icon(
          showWarning ? Icons.warning_amber : Icons.wifi,
          size: 18,
          color: showWarning ? scheme.error : null,
        ),
        label: '$prefix$pattern',
      );
    }
    if (c is AnyWifi) {
      return CommonChip(
        type: ChipType.tonal,
        avatar: const Icon(Icons.wifi, size: 18),
        label: '$prefix${appLocalizations.networkRulesConditionAnyWifi}',
      );
    }
    if (c is AnyCellular) {
      return CommonChip(
        type: ChipType.tonal,
        avatar: const Icon(Icons.signal_cellular_alt, size: 18),
        label: '$prefix${appLocalizations.networkRulesConditionAnyCellular}',
      );
    }
    if (c is AnyEthernet) {
      return CommonChip(
        type: ChipType.tonal,
        avatar: const Icon(Icons.settings_ethernet, size: 18),
        label: '$prefix${appLocalizations.networkRulesConditionAnyEthernet}',
      );
    }
    return const SizedBox.shrink();
  }
}
