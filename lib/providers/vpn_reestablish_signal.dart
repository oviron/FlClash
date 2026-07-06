import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monotonic tick bumped whenever the ACTIVE profile's per-app tun package set
/// changes on disk. `VpnManager` listens and force-re-establishes the tunnel:
/// `VpnService.Builder` allow/disallow lists are baked at establish and cannot
/// be hot-reloaded, and `vpnState` does not otherwise reflect a per-profile ACL
/// change, so nothing else would re-apply the new app list.
class VpnReestablishSignal extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final vpnReestablishSignalProvider =
    NotifierProvider<VpnReestablishSignal, int>(VpnReestablishSignal.new);
