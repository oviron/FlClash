// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ByeDpiSettings {

 bool get enabled; ByeDpiMode get mode; bool get fallbackEnabled; String get fallbackGroup; int get port; String get cliArgs;
/// Create a copy of ByeDpiSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ByeDpiSettingsCopyWith<ByeDpiSettings> get copyWith => _$ByeDpiSettingsCopyWithImpl<ByeDpiSettings>(this as ByeDpiSettings, _$identity);

  /// Serializes this ByeDpiSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ByeDpiSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fallbackEnabled, fallbackEnabled) || other.fallbackEnabled == fallbackEnabled)&&(identical(other.fallbackGroup, fallbackGroup) || other.fallbackGroup == fallbackGroup)&&(identical(other.port, port) || other.port == port)&&(identical(other.cliArgs, cliArgs) || other.cliArgs == cliArgs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,mode,fallbackEnabled,fallbackGroup,port,cliArgs);

@override
String toString() {
  return 'ByeDpiSettings(enabled: $enabled, mode: $mode, fallbackEnabled: $fallbackEnabled, fallbackGroup: $fallbackGroup, port: $port, cliArgs: $cliArgs)';
}


}

/// @nodoc
abstract mixin class $ByeDpiSettingsCopyWith<$Res>  {
  factory $ByeDpiSettingsCopyWith(ByeDpiSettings value, $Res Function(ByeDpiSettings) _then) = _$ByeDpiSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, ByeDpiMode mode, bool fallbackEnabled, String fallbackGroup, int port, String cliArgs
});




}
/// @nodoc
class _$ByeDpiSettingsCopyWithImpl<$Res>
    implements $ByeDpiSettingsCopyWith<$Res> {
  _$ByeDpiSettingsCopyWithImpl(this._self, this._then);

  final ByeDpiSettings _self;
  final $Res Function(ByeDpiSettings) _then;

/// Create a copy of ByeDpiSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? mode = null,Object? fallbackEnabled = null,Object? fallbackGroup = null,Object? port = null,Object? cliArgs = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ByeDpiMode,fallbackEnabled: null == fallbackEnabled ? _self.fallbackEnabled : fallbackEnabled // ignore: cast_nullable_to_non_nullable
as bool,fallbackGroup: null == fallbackGroup ? _self.fallbackGroup : fallbackGroup // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,cliArgs: null == cliArgs ? _self.cliArgs : cliArgs // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ByeDpiSettings].
extension ByeDpiSettingsPatterns on ByeDpiSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ByeDpiSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ByeDpiSettings value)  $default,){
final _that = this;
switch (_that) {
case _ByeDpiSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ByeDpiSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  ByeDpiMode mode,  bool fallbackEnabled,  String fallbackGroup,  int port,  String cliArgs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that.enabled,_that.mode,_that.fallbackEnabled,_that.fallbackGroup,_that.port,_that.cliArgs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  ByeDpiMode mode,  bool fallbackEnabled,  String fallbackGroup,  int port,  String cliArgs)  $default,) {final _that = this;
switch (_that) {
case _ByeDpiSettings():
return $default(_that.enabled,_that.mode,_that.fallbackEnabled,_that.fallbackGroup,_that.port,_that.cliArgs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  ByeDpiMode mode,  bool fallbackEnabled,  String fallbackGroup,  int port,  String cliArgs)?  $default,) {final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that.enabled,_that.mode,_that.fallbackEnabled,_that.fallbackGroup,_that.port,_that.cliArgs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ByeDpiSettings implements ByeDpiSettings {
  const _ByeDpiSettings({this.enabled = false, this.mode = ByeDpiMode.auto, this.fallbackEnabled = true, this.fallbackGroup = '', this.port = 1080, this.cliArgs = '--auto=tlsrec'});
  factory _ByeDpiSettings.fromJson(Map<String, dynamic> json) => _$ByeDpiSettingsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  ByeDpiMode mode;
@override@JsonKey() final  bool fallbackEnabled;
@override@JsonKey() final  String fallbackGroup;
@override@JsonKey() final  int port;
@override@JsonKey() final  String cliArgs;

/// Create a copy of ByeDpiSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ByeDpiSettingsCopyWith<_ByeDpiSettings> get copyWith => __$ByeDpiSettingsCopyWithImpl<_ByeDpiSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ByeDpiSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ByeDpiSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fallbackEnabled, fallbackEnabled) || other.fallbackEnabled == fallbackEnabled)&&(identical(other.fallbackGroup, fallbackGroup) || other.fallbackGroup == fallbackGroup)&&(identical(other.port, port) || other.port == port)&&(identical(other.cliArgs, cliArgs) || other.cliArgs == cliArgs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,mode,fallbackEnabled,fallbackGroup,port,cliArgs);

@override
String toString() {
  return 'ByeDpiSettings(enabled: $enabled, mode: $mode, fallbackEnabled: $fallbackEnabled, fallbackGroup: $fallbackGroup, port: $port, cliArgs: $cliArgs)';
}


}

/// @nodoc
abstract mixin class _$ByeDpiSettingsCopyWith<$Res> implements $ByeDpiSettingsCopyWith<$Res> {
  factory _$ByeDpiSettingsCopyWith(_ByeDpiSettings value, $Res Function(_ByeDpiSettings) _then) = __$ByeDpiSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, ByeDpiMode mode, bool fallbackEnabled, String fallbackGroup, int port, String cliArgs
});




}
/// @nodoc
class __$ByeDpiSettingsCopyWithImpl<$Res>
    implements _$ByeDpiSettingsCopyWith<$Res> {
  __$ByeDpiSettingsCopyWithImpl(this._self, this._then);

  final _ByeDpiSettings _self;
  final $Res Function(_ByeDpiSettings) _then;

/// Create a copy of ByeDpiSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? mode = null,Object? fallbackEnabled = null,Object? fallbackGroup = null,Object? port = null,Object? cliArgs = null,}) {
  return _then(_ByeDpiSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ByeDpiMode,fallbackEnabled: null == fallbackEnabled ? _self.fallbackEnabled : fallbackEnabled // ignore: cast_nullable_to_non_nullable
as bool,fallbackGroup: null == fallbackGroup ? _self.fallbackGroup : fallbackGroup // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,cliArgs: null == cliArgs ? _self.cliArgs : cliArgs // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
