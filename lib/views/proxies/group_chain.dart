import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';

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

/// The chain the Proxies strip shows: the entry group comes from the
/// mode-filtered list, the hops from the full one — `currentGroupsState`
/// blanks `now`, so resolving inside it would stop at the entry name.
List<String> activeChain(List<Group> visible, List<Group> all) {
  final start = primaryGroup(visible);
  if (start == null) return const [];
  return resolveChain(all, start.name);
}
