import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

const kRoutingDefault = '';
const kRoutingDirect = 'DIRECT';
const kRoutingReject = 'REJECT';
const kRoutingGlobal = 'GLOBAL';

/// Color/role bucket for an app's routing-target chip. Drives both the chip
/// tint and the picker grouping (group vs sub-rule vs builtin vs default).
enum TargetChipKind { profileRules, direct, reject, global, group, subRule }

typedef AppTarget = ({String value, bool isSubRule});

/// Buckets an app's resolved target into a [TargetChipKind]. A null target
/// (no per-app rule) reads as [TargetChipKind.profileRules].
TargetChipKind targetChipKind(AppTarget? target) {
  if (target == null || target.value == kRoutingDefault) {
    return TargetChipKind.profileRules;
  }
  if (target.isSubRule) return TargetChipKind.subRule;
  return switch (target.value) {
    kRoutingDirect => TargetChipKind.direct,
    kRoutingReject => TargetChipKind.reject,
    kRoutingGlobal => TargetChipKind.global,
    _ => TargetChipKind.group,
  };
}

/// Whether [pkg] routes into the tunnel under the profile's [mode]: whitelist
/// counts the include-list, blacklist counts everything not excluded.
bool inTunnel(
  String pkg,
  AccessControlMode mode,
  Set<String> included,
  Set<String> excluded,
) => mode == AccessControlMode.acceptSelected
    ? included.contains(pkg)
    : !excluded.contains(pkg);

/// Splits [packages] (already filtered/sorted) into the apps that enter mihomo
/// and the apps that bypass it, per the active membership lists and [mode].
({List<Package> inTunnel, List<Package> bypass}) partitionApps(
  List<Package> packages,
  AccessControlMode mode,
  Set<String> included,
  Set<String> excluded,
) {
  final tunnel = <Package>[];
  final bypass = <Package>[];
  for (final p in packages) {
    (inTunnel(p.packageName, mode, included, excluded) ? tunnel : bypass).add(
      p,
    );
  }
  return (inTunnel: tunnel, bypass: bypass);
}

/// Apps for the routing list: optionally hide system apps, filter by a
/// case-insensitive [query] over label/package, then sort. With [configuredFirst]
/// the apps carrying a per-app target lead, each block kept name-sorted.
List<Package> filterRoutingApps(
  Iterable<Package> packages, {
  required String query,
  required bool showSystem,
  bool configuredFirst = false,
  Set<String> configured = const {},
}) {
  final q = query.toLowerCase();
  final list = packages
      .where((p) => showSystem || !p.system)
      .where(
        (p) =>
            q.isEmpty ||
            p.label.toLowerCase().contains(q) ||
            p.packageName.toLowerCase().contains(q),
      )
      .toList();
  int byLabel(Package a, Package b) =>
      a.label.toLowerCase().compareTo(b.label.toLowerCase());
  list.sort((a, b) {
    if (configuredFirst) {
      final ca = configured.contains(a.packageName);
      final cb = configured.contains(b.packageName);
      if (ca != cb) return ca ? -1 : 1;
    }
    return byLabel(a, b);
  });
  return list;
}
