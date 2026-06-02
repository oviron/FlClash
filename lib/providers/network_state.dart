// Holds the latest NetworkSnapshot. Fed by the resident service's status push
// (NetworkRulesPlugin), surfaced for the editor and the SSID suggestions.

import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/network_rules/plugin.dart';
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

/// Latest decision + reason pushed by the resident service, for the editor's
/// "current network -> decision" status line.
@Riverpod(keepAlive: true)
class LastNetworkRuleStatus extends _$LastNetworkRuleStatus {
  @override
  NetworkRuleStatus? build() => null;

  void update(NetworkRuleStatus status) => state = status;
}
