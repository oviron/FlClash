import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/group_chain.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tells a url-test/fallback group apart from a node pinned inside it, and
/// gives the pin a visible way out.
class GroupModeBar extends StatelessWidget {
  final List<String> chain;
  final bool pinned;
  final VoidCallback onAuto;
  final int? delay;

  const GroupModeBar({
    super.key,
    required this.chain,
    required this.pinned,
    required this.onAuto,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: pinned ? scheme.secondaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            pinned ? Icons.push_pin : Icons.auto_mode,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            pinned ? appLocalizations.pinned : appLocalizations.auto,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              chain.isEmpty ? '—' : chain.join('  →  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          LatencyBadge(delay),
          if (pinned)
            TextButton(
              onPressed: onAuto,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(appLocalizations.auto),
            ),
        ],
      ),
    );
  }
}

class GroupModeBarView extends ConsumerWidget {
  final String groupName;

  const GroupModeBarView({super.key, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final group = groups.getGroup(groupName);
    if (group == null || !group.type.isComputedSelected) {
      return const SizedBox.shrink();
    }
    final pinnedName = ref.watch(getProxyNameProvider(groupName)) ?? '';
    final chain = group.realNow.isEmpty
        ? const <String>[]
        : resolveChain(groups, group.realNow);
    final delay = ref.watch(
      getDelayProvider(
        proxyName: chain.isEmpty ? group.name : chain.last,
        testUrl: group.testUrl,
      ),
    );
    return GroupModeBar(
      chain: chain,
      pinned: pinnedName.isNotEmpty,
      delay: delay,
      onAuto: () => appController.selectGroupMember(
        groupName: groupName,
        proxyName: pinnedName,
        groupType: group.type,
      ),
    );
  }
}
