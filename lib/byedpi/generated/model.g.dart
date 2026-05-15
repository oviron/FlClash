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
      cliArgs: json['cliArgs'] as String? ?? '--auto=tlsrec',
    );

Map<String, dynamic> _$ByeDpiSettingsToJson(_ByeDpiSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'mode': _$ByeDpiModeEnumMap[instance.mode]!,
      'fallbackEnabled': instance.fallbackEnabled,
      'fallbackGroup': instance.fallbackGroup,
      'port': instance.port,
      'cliArgs': instance.cliArgs,
    };

const _$ByeDpiModeEnumMap = {
  ByeDpiMode.manual: 'manual',
  ByeDpiMode.auto: 'auto',
};
