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
///
/// [chain] is what the group actually routes through, which a pin does not
/// always match: mihomo skips a pinned node until it passes a health check.
class GroupModeBar extends StatelessWidget {
  final List<String> chain;
  final String pinnedName;
  final VoidCallback onAuto;
  final int? delay;

  const GroupModeBar({
    super.key,
    required this.chain,
    required this.pinnedName,
    required this.onAuto,
    this.delay,
  });

  bool get _pinned => pinnedName.isNotEmpty;

  bool get _pinTakenUp => chain.isNotEmpty && chain.first == pinnedName;

  Widget _label(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _pinned ? Icons.push_pin : Icons.auto_mode,
          size: 16,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          _pinned ? appLocalizations.pinned : appLocalizations.auto,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _path(BuildContext context, {required String text, bool dim = false}) {
    final style = dim
        ? context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          )
        : context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
    return EmojiText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final path = chain.isEmpty ? '—' : chain.join('  →  ');
    final split = _pinned && !_pinTakenUp;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: _pinned ? scheme.secondaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _label(context),
              const SizedBox(width: 10),
              Expanded(child: _path(context, text: split ? pinnedName : path)),
              const SizedBox(width: 8),
              if (!split) LatencyBadge(delay),
              if (_pinned)
                TextButton(
                  onPressed: onAuto,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(appLocalizations.auto),
                ),
            ],
          ),
          if (split)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${appLocalizations.inUse}  ',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Flexible(child: _path(context, text: path, dim: true)),
                  const SizedBox(width: 8),
                  LatencyBadge(delay),
                ],
              ),
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
      pinnedName: pinnedName,
      delay: delay,
      onAuto: () => appController.selectGroupMember(
        groupName: groupName,
        proxyName: pinnedName,
        groupType: group.type,
      ),
    );
  }
}
