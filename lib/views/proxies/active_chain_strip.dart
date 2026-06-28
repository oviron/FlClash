import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/group_chain.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin strip above the proxy list showing the active outbound chain
/// (entry group → … → leaf node) with the leaf's latency and a connected dot.
class ActiveChainStrip extends ConsumerWidget {
  const ActiveChainStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(
      currentGroupsStateProvider.select((s) {
        final start = primaryGroup(s.value);
        return start == null
            ? const <String>[]
            : resolveChain(s.value, start.name);
      }),
    );
    if (chain.isEmpty) return const SizedBox.shrink();
    // VPN running, not core status (the core stays "connected" while the
    // tunnel is off).
    final connected = ref.watch(isStartProvider);
    final leafDelay = ref.watch(getDelayProvider(proxyName: chain.last));
    final scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 9,
            color: connected ? scheme.success : scheme.outline,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              chain.join('  →  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          LatencyBadge(leafDelay),
        ],
      ),
    );
  }
}
