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
