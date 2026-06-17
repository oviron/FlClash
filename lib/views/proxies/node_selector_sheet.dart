import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The group the dashboard node pill targets: the first visible selectable
/// group (selector or computed-selected), else the first visible group, else
/// null when there is nothing to pick.
Group? primaryGroup(List<Group> groups) {
  Group? firstVisible;
  for (final g in groups) {
    if (g.hidden == true) continue;
    firstVisible ??= g;
    if (g.type == GroupType.Selector || g.type.isComputedSelected) return g;
  }
  return firstVisible;
}

/// Follows the active selection from [start] through nested groups to the leaf
/// proxy, e.g. ["VPN", "Auto", "qde-direct"]. Stops at a non-group name, an
/// empty selection, or a cycle (self-referencing configs never loop).
List<String> resolveChain(List<Group> groups, String start) {
  final out = <String>[];
  final seen = <String>{};
  var name = start;
  while (!seen.contains(name)) {
    seen.add(name);
    out.add(name);
    final group = groups.getGroup(name);
    if (group == null || group.realNow.isEmpty) break;
    name = group.realNow;
  }
  return out;
}

/// Switches the selected member of one proxy group, mirroring the Proxies card
/// selection (computed-selected toggles off, selector picks). Shared by the
/// dashboard node pill and any compact group switcher.
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

  void _select(BuildContext context, WidgetRef ref) {
    final type = group.type;
    if (!type.isComputedSelected && type != GroupType.Selector) {
      globalState.showNotifier(appLocalizations.notSelectedTip);
      return;
    }
    final current = ref.read(getProxyNameProvider(group.name));
    final next = type.isComputedSelected
        ? (current == proxy.name ? '' : proxy.name)
        : proxy.name;
    appController.updateCurrentSelectedMap(group.name, next);
    appController.changeProxyDebounce(group.name, next);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        ref.watch(getProxyNameProvider(group.name)) == proxy.name;
    final delay = ref.watch(getDelayProvider(proxyName: proxy.name));
    return ListTile(
      selected: isSelected,
      selectedTileColor: context.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      onTap: () => _select(context, ref),
    );
  }
}
