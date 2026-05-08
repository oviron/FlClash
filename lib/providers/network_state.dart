// Holds the latest NetworkSnapshot from the probe. The dispatcher
// subscribes here.

import 'package:fl_clash/network_rules/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'recent_ssids.dart';

part 'generated/network_state.g.dart';

@Riverpod(keepAlive: true)
class CurrentNetworkSnapshot extends _$CurrentNetworkSnapshot {
  @override
  NetworkSnapshot build() => const NetworkSnapshot.none();

  /// Replace the current snapshot. If the new snapshot is a Wi-Fi with a
  /// non-null SSID, also feed it into the recent-SSIDs list so the editor
  /// can suggest it later.
  void update(NetworkSnapshot snapshot) {
    state = snapshot;
    final ssid = snapshot.ssid;
    if (snapshot.type == NetworkType.wifi && ssid != null) {
      ref.read(recentSsidsProvider.notifier).observe(ssid);
    }
  }
}
