// Network Rules v1: persisted master toggle and fallback action.
//
// Two settings live here, separated from the rules list (which is in drift):
//
//   * `enabled` — global on/off for the rule engine. When false, the engine
//     does not dispatch any auto-actions even if rules exist.
//   * `fallback` — what action to take when no rule matches the current
//     network snapshot. Default is `turnOn` so a user with the toggle off
//     and an empty list still gets the historical "VPN is on" behaviour.
//
// We persist via the existing `Config` aggregator (see `providers/config.dart`
// and `models/config.dart::NetworkRulesProps`) — the same JSON file that
// already stores AppSetting / Vpn / Theme / etc. No new persistence layer.

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/network_rules_settings.g.dart';

@riverpod
class NetworkRulesSettings extends _$NetworkRulesSettings
    with AutoDisposeNotifierMixin {
  @override
  NetworkRulesProps build() {
    return const NetworkRulesProps();
  }

  void setEnabled(bool value) {
    update((s) => s.copyWith(enabled: value));
  }

  void setFallback(NetworkAction action) {
    update((s) => s.copyWith(fallback: action));
  }
}
