// Persisted master toggle for the rule engine. When `enabled` is false the
// runner skips evaluation entirely.
//
// Persistence goes through the existing `Config` aggregator (see
// `providers/config.dart` and `models/config.dart::NetworkRulesProps`) —
// the same JSON file that already stores AppSetting / Vpn / Theme / etc.
// No new persistence layer.

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
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
}
