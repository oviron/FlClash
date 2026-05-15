import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

@freezed
abstract class BypassProfile with _$BypassProfile {
  const factory BypassProfile({
    required int id,
    @Default('') String name,
    @Default(true) bool enabled,
    @Default([]) List<String> domains,
    @Default([]) List<String> apps,
  }) = _BypassProfile;

  factory BypassProfile.fromJson(Map<String, Object?> json) =>
      _$BypassProfileFromJson(json);
}

@freezed
abstract class ByeDpiSettings with _$ByeDpiSettings {
  const factory ByeDpiSettings({
    @Default(false) bool enabled,
    @Default(1080) int port,
    @Default('') String cliArgs,
    @Default('VPN') String fallbackGroup,
  }) = _ByeDpiSettings;

  factory ByeDpiSettings.fromJson(Map<String, Object?> json) =>
      _$ByeDpiSettingsFromJson(json);
}
