// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BypassProfile _$BypassProfileFromJson(Map<String, dynamic> json) =>
    _BypassProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      domains:
          (json['domains'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      apps:
          (json['apps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$BypassProfileToJson(_BypassProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enabled': instance.enabled,
      'domains': instance.domains,
      'apps': instance.apps,
    };

_ByeDpiSettings _$ByeDpiSettingsFromJson(Map<String, dynamic> json) =>
    _ByeDpiSettings(
      enabled: json['enabled'] as bool? ?? false,
      port: (json['port'] as num?)?.toInt() ?? 1080,
      cliArgs: json['cliArgs'] as String? ?? '',
      fallbackGroup: json['fallbackGroup'] as String? ?? 'VPN',
    );

Map<String, dynamic> _$ByeDpiSettingsToJson(_ByeDpiSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'port': instance.port,
      'cliArgs': instance.cliArgs,
      'fallbackGroup': instance.fallbackGroup,
    };
