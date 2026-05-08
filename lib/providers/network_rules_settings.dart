// Persisted master toggle and fallback action for the rule engine.
//
//   * `enabled` — global on/off. When false, the runner skips evaluation
//     entirely and fallback never applies.
//   * `fallback` — action to take when no rule matches the current snapshot.
//     Only consulted while `enabled` is true.
//
// Persistence goes through the existing `Config` aggregator (see
// `providers/config.dart` and `models/config.dart::NetworkRulesProps`) —
// the same JSON file that already stores AppSetting / Vpn / Theme / etc.
// No new persistence layer.

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
