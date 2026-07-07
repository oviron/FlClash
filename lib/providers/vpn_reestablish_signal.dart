import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bumped when the active profile's tun package set changes: VpnService.Builder
// allow/disallow is baked at establish (not hot-reloadable) and vpnState doesn't
// reflect a per-profile ACL change, so VpnManager watches this to re-establish.
class VpnReestablishSignal extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final vpnReestablishSignalProvider =
    NotifierProvider<VpnReestablishSignal, int>(VpnReestablishSignal.new);
