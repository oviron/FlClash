// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ByeDpiSettings _$ByeDpiSettingsFromJson(
  Map<String, dynamic> json,
) => _ByeDpiSettings(
  enabled: json['enabled'] as bool? ?? false,
  mode:
      $enumDecodeNullable(_$ByeDpiModeEnumMap, json['mode']) ?? ByeDpiMode.auto,
  fallbackEnabled: json['fallbackEnabled'] as bool? ?? true,
  fallbackGroup: json['fallbackGroup'] as String? ?? '',
  port: (json['port'] as num?)?.toInt() ?? 1080,
  preset:
      $enumDecodeNullable(_$ByeDpiPresetEnumMap, json['preset']) ??
      ByeDpiPreset.universal,
  cliArgs:
      json['cliArgs'] as String? ?? '--disorder 1 --auto=t,r,s --tlsrec 1+s',
);

Map<String, dynamic> _$ByeDpiSettingsToJson(_ByeDpiSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'mode': _$ByeDpiModeEnumMap[instance.mode]!,
      'fallbackEnabled': instance.fallbackEnabled,
      'fallbackGroup': instance.fallbackGroup,
      'port': instance.port,
      'preset': _$ByeDpiPresetEnumMap[instance.preset]!,
      'cliArgs': instance.cliArgs,
    };

const _$ByeDpiModeEnumMap = {
  ByeDpiMode.manual: 'manual',
  ByeDpiMode.auto: 'auto',
};

const _$ByeDpiPresetEnumMap = {
  ByeDpiPreset.universal: 'universal',
  ByeDpiPreset.tele2: 'tele2',
  ByeDpiPreset.mrDrone: 'mrDrone',
  ByeDpiPreset.antiGgc: 'antiGgc',
  ByeDpiPreset.custom: 'custom',
};
