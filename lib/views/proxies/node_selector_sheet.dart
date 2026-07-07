import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeSelectorSheet extends ConsumerWidget {
  final SheetType type;
  final String groupName;

  const NodeSelectorSheet({
    super.key,
    required this.type,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(
      currentGroupsStateProvider.select((s) => s.value.getGroup(groupName)),
    );
    return AdaptiveSheetScaffold(
      type: type,
      title: group?.name ?? appLocalizations.proxyGroup,
      body: group == null
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.proxies),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: group.all.length,
              itemBuilder: (_, i) =>
                  _NodeRow(group: group, proxy: group.all[i]),
            ),
    );
  }
}

class _NodeRow extends ConsumerWidget {
  final Group group;
  final Proxy proxy;

  const _NodeRow({required this.group, required this.proxy});

  void _select(BuildContext context) {
    final selected = appController.selectGroupMember(
      groupName: group.name,
      proxyName: proxy.name,
      groupType: group.type,
    );
    if (selected) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        ref.watch(getSelectedProxyNameProvider(group.name)) == proxy.name;
    final delay = ref.watch(getDelayProvider(proxyName: proxy.name));
    return ListItem(
      color: isSelected ? context.colorScheme.secondaryContainer : null,
      title: Text(proxy.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: proxy.type.isEmpty ? null : Text(proxy.type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LatencyBadge(delay),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check, size: 18, color: context.colorScheme.primary),
          ],
        ],
      ),
      onTap: () => _select(context),
    );
  }
}
