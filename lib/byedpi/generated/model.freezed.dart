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
mixin _$BypassProfile {

 int get id; String get name; bool get enabled; List<String> get domains; List<String> get apps;
/// Create a copy of BypassProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BypassProfileCopyWith<BypassProfile> get copyWith => _$BypassProfileCopyWithImpl<BypassProfile>(this as BypassProfile, _$identity);

  /// Serializes this BypassProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BypassProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.domains, domains)&&const DeepCollectionEquality().equals(other.apps, apps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enabled,const DeepCollectionEquality().hash(domains),const DeepCollectionEquality().hash(apps));

@override
String toString() {
  return 'BypassProfile(id: $id, name: $name, enabled: $enabled, domains: $domains, apps: $apps)';
}


}

/// @nodoc
abstract mixin class $BypassProfileCopyWith<$Res>  {
  factory $BypassProfileCopyWith(BypassProfile value, $Res Function(BypassProfile) _then) = _$BypassProfileCopyWithImpl;
@useResult
$Res call({
 int id, String name, bool enabled, List<String> domains, List<String> apps
});




}
/// @nodoc
class _$BypassProfileCopyWithImpl<$Res>
    implements $BypassProfileCopyWith<$Res> {
  _$BypassProfileCopyWithImpl(this._self, this._then);

  final BypassProfile _self;
  final $Res Function(BypassProfile) _then;

/// Create a copy of BypassProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? domains = null,Object? apps = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,domains: null == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as List<String>,apps: null == apps ? _self.apps : apps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [BypassProfile].
extension BypassProfilePatterns on BypassProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BypassProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BypassProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BypassProfile value)  $default,){
final _that = this;
switch (_that) {
case _BypassProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BypassProfile value)?  $default,){
final _that = this;
switch (_that) {
case _BypassProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  bool enabled,  List<String> domains,  List<String> apps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BypassProfile() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.domains,_that.apps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  bool enabled,  List<String> domains,  List<String> apps)  $default,) {final _that = this;
switch (_that) {
case _BypassProfile():
return $default(_that.id,_that.name,_that.enabled,_that.domains,_that.apps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  bool enabled,  List<String> domains,  List<String> apps)?  $default,) {final _that = this;
switch (_that) {
case _BypassProfile() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.domains,_that.apps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BypassProfile implements BypassProfile {
  const _BypassProfile({required this.id, this.name = '', this.enabled = true, final  List<String> domains = const [], final  List<String> apps = const []}): _domains = domains,_apps = apps;
  factory _BypassProfile.fromJson(Map<String, dynamic> json) => _$BypassProfileFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool enabled;
 final  List<String> _domains;
@override@JsonKey() List<String> get domains {
  if (_domains is EqualUnmodifiableListView) return _domains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_domains);
}

 final  List<String> _apps;
@override@JsonKey() List<String> get apps {
  if (_apps is EqualUnmodifiableListView) return _apps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_apps);
}


/// Create a copy of BypassProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BypassProfileCopyWith<_BypassProfile> get copyWith => __$BypassProfileCopyWithImpl<_BypassProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BypassProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BypassProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other._domains, _domains)&&const DeepCollectionEquality().equals(other._apps, _apps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enabled,const DeepCollectionEquality().hash(_domains),const DeepCollectionEquality().hash(_apps));

@override
String toString() {
  return 'BypassProfile(id: $id, name: $name, enabled: $enabled, domains: $domains, apps: $apps)';
}


}

/// @nodoc
abstract mixin class _$BypassProfileCopyWith<$Res> implements $BypassProfileCopyWith<$Res> {
  factory _$BypassProfileCopyWith(_BypassProfile value, $Res Function(_BypassProfile) _then) = __$BypassProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, bool enabled, List<String> domains, List<String> apps
});




}
/// @nodoc
class __$BypassProfileCopyWithImpl<$Res>
    implements _$BypassProfileCopyWith<$Res> {
  __$BypassProfileCopyWithImpl(this._self, this._then);

  final _BypassProfile _self;
  final $Res Function(_BypassProfile) _then;

/// Create a copy of BypassProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? domains = null,Object? apps = null,}) {
  return _then(_BypassProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,domains: null == domains ? _self._domains : domains // ignore: cast_nullable_to_non_nullable
as List<String>,apps: null == apps ? _self._apps : apps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ByeDpiSettings {

 bool get enabled; int get port; String get cliArgs; String get fallbackGroup;
/// Create a copy of ByeDpiSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ByeDpiSettingsCopyWith<ByeDpiSettings> get copyWith => _$ByeDpiSettingsCopyWithImpl<ByeDpiSettings>(this as ByeDpiSettings, _$identity);

  /// Serializes this ByeDpiSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ByeDpiSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.port, port) || other.port == port)&&(identical(other.cliArgs, cliArgs) || other.cliArgs == cliArgs)&&(identical(other.fallbackGroup, fallbackGroup) || other.fallbackGroup == fallbackGroup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,port,cliArgs,fallbackGroup);

@override
String toString() {
  return 'ByeDpiSettings(enabled: $enabled, port: $port, cliArgs: $cliArgs, fallbackGroup: $fallbackGroup)';
}


}

/// @nodoc
abstract mixin class $ByeDpiSettingsCopyWith<$Res>  {
  factory $ByeDpiSettingsCopyWith(ByeDpiSettings value, $Res Function(ByeDpiSettings) _then) = _$ByeDpiSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, int port, String cliArgs, String fallbackGroup
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
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? port = null,Object? cliArgs = null,Object? fallbackGroup = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,cliArgs: null == cliArgs ? _self.cliArgs : cliArgs // ignore: cast_nullable_to_non_nullable
as String,fallbackGroup: null == fallbackGroup ? _self.fallbackGroup : fallbackGroup // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int port,  String cliArgs,  String fallbackGroup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that.enabled,_that.port,_that.cliArgs,_that.fallbackGroup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int port,  String cliArgs,  String fallbackGroup)  $default,) {final _that = this;
switch (_that) {
case _ByeDpiSettings():
return $default(_that.enabled,_that.port,_that.cliArgs,_that.fallbackGroup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int port,  String cliArgs,  String fallbackGroup)?  $default,) {final _that = this;
switch (_that) {
case _ByeDpiSettings() when $default != null:
return $default(_that.enabled,_that.port,_that.cliArgs,_that.fallbackGroup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ByeDpiSettings implements ByeDpiSettings {
  const _ByeDpiSettings({this.enabled = false, this.port = 1080, this.cliArgs = '', this.fallbackGroup = 'VPN'});
  factory _ByeDpiSettings.fromJson(Map<String, dynamic> json) => _$ByeDpiSettingsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int port;
@override@JsonKey() final  String cliArgs;
@override@JsonKey() final  String fallbackGroup;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ByeDpiSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.port, port) || other.port == port)&&(identical(other.cliArgs, cliArgs) || other.cliArgs == cliArgs)&&(identical(other.fallbackGroup, fallbackGroup) || other.fallbackGroup == fallbackGroup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,port,cliArgs,fallbackGroup);

@override
String toString() {
  return 'ByeDpiSettings(enabled: $enabled, port: $port, cliArgs: $cliArgs, fallbackGroup: $fallbackGroup)';
}


}

/// @nodoc
abstract mixin class _$ByeDpiSettingsCopyWith<$Res> implements $ByeDpiSettingsCopyWith<$Res> {
  factory _$ByeDpiSettingsCopyWith(_ByeDpiSettings value, $Res Function(_ByeDpiSettings) _then) = __$ByeDpiSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int port, String cliArgs, String fallbackGroup
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
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? port = null,Object? cliArgs = null,Object? fallbackGroup = null,}) {
  return _then(_ByeDpiSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,cliArgs: null == cliArgs ? _self.cliArgs : cliArgs // ignore: cast_nullable_to_non_nullable
as String,fallbackGroup: null == fallbackGroup ? _self.fallbackGroup : fallbackGroup // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
