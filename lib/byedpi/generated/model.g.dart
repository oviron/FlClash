// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ByeDpiSettings _$ByeDpiSettingsFromJson(Map<String, dynamic> json) =>
    _ByeDpiSettings(
      enabled: json['enabled'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$ByeDpiModeEnumMap, json['mode']) ??
          ByeDpiMode.auto,
      fallbackEnabled: json['fallbackEnabled'] as bool? ?? true,
      fallbackGroup: json['fallbackGroup'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 1080,
      preset: json['preset'] as String? ?? kByeDpiDefaultId,
      cliArgs: json['cliArgs'] as String? ?? kByeDpiDefaultArgs,
    );

Map<String, dynamic> _$ByeDpiSettingsToJson(_ByeDpiSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'mode': _$ByeDpiModeEnumMap[instance.mode]!,
      'fallbackEnabled': instance.fallbackEnabled,
      'fallbackGroup': instance.fallbackGroup,
      'port': instance.port,
      'preset': instance.preset,
      'cliArgs': instance.cliArgs,
    };

const _$ByeDpiModeEnumMap = {
  ByeDpiMode.manual: 'manual',
  ByeDpiMode.auto: 'auto',
};
