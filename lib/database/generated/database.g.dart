// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, RawProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentGroupNameMeta = const VerificationMeta(
    'currentGroupName',
  );
  @override
  late final GeneratedColumn<String> currentGroupName = GeneratedColumn<String>(
    'current_group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateDateMeta = const VerificationMeta(
    'lastUpdateDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateDate =
      GeneratedColumn<DateTime>(
        'last_update_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<OverwriteType, String>
  overwriteType = GeneratedColumn<String>(
    'overwrite_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<OverwriteType>($ProfilesTable.$converteroverwriteType);
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<int> scriptId = GeneratedColumn<int>(
    'script_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoUpdateDurationMillisMeta =
      const VerificationMeta('autoUpdateDurationMillis');
  @override
  late final GeneratedColumn<int> autoUpdateDurationMillis =
      GeneratedColumn<int>(
        'auto_update_duration_millis',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  subscriptionInfo = GeneratedColumn<String>(
    'subscription_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<SubscriptionInfo?>($ProfilesTable.$convertersubscriptionInfo);
  static const VerificationMeta _autoUpdateMeta = const VerificationMeta(
    'autoUpdate',
  );
  @override
  late final GeneratedColumn<bool> autoUpdate = GeneratedColumn<bool>(
    'auto_update',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_update" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  selectedMap = GeneratedColumn<String>(
    'selected_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($ProfilesTable.$converterselectedMap);
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>, String> unfoldSet =
      GeneratedColumn<String>(
        'unfold_set',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<String>>($ProfilesTable.$converterunfoldSet);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccessControlProps?, String>
  accessControlProps =
      GeneratedColumn<String>(
        'access_control_props',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AccessControlProps?>(
        $ProfilesTable.$converteraccessControlProps,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    overwriteType,
    scriptId,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
    accessControlProps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('current_group_name')) {
      context.handle(
        _currentGroupNameMeta,
        currentGroupName.isAcceptableOrUnknown(
          data['current_group_name']!,
          _currentGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_update_date')) {
      context.handle(
        _lastUpdateDateMeta,
        lastUpdateDate.isAcceptableOrUnknown(
          data['last_update_date']!,
          _lastUpdateDateMeta,
        ),
      );
    }
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    }
    if (data.containsKey('auto_update_duration_millis')) {
      context.handle(
        _autoUpdateDurationMillisMeta,
        autoUpdateDurationMillis.isAcceptableOrUnknown(
          data['auto_update_duration_millis']!,
          _autoUpdateDurationMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateDurationMillisMeta);
    }
    if (data.containsKey('auto_update')) {
      context.handle(
        _autoUpdateMeta,
        autoUpdate.isAcceptableOrUnknown(data['auto_update']!, _autoUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      currentGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_group_name'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastUpdateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_date'],
      ),
      overwriteType: $ProfilesTable.$converteroverwriteType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}overwrite_type'],
        )!,
      ),
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}script_id'],
      ),
      autoUpdateDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_duration_millis'],
      )!,
      subscriptionInfo: $ProfilesTable.$convertersubscriptionInfo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subscription_info'],
        ),
      ),
      autoUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_update'],
      )!,
      selectedMap: $ProfilesTable.$converterselectedMap.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_map'],
        )!,
      ),
      unfoldSet: $ProfilesTable.$converterunfoldSet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unfold_set'],
        )!,
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
      accessControlProps: $ProfilesTable.$converteraccessControlProps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}access_control_props'],
        ),
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OverwriteType, String, String>
  $converteroverwriteType = const EnumNameConverter<OverwriteType>(
    OverwriteType.values,
  );
  static TypeConverter<SubscriptionInfo?, String?> $convertersubscriptionInfo =
      const SubscriptionInfoConverter();
  static TypeConverter<Map<String, String>, String> $converterselectedMap =
      const StringMapConverter();
  static TypeConverter<Set<String>, String> $converterunfoldSet =
      const StringSetConverter();
  static TypeConverter<AccessControlProps?, String?>
  $converteraccessControlProps = const AccessControlPropsConverter();
}

class RawProfile extends DataClass implements Insertable<RawProfile> {
  final int id;
  final String label;
  final String? currentGroupName;
  final String url;
  final DateTime? lastUpdateDate;
  final OverwriteType overwriteType;
  final int? scriptId;
  final int autoUpdateDurationMillis;
  final SubscriptionInfo? subscriptionInfo;
  final bool autoUpdate;
  final Map<String, String> selectedMap;
  final Set<String> unfoldSet;
  final int? order;
  final AccessControlProps? accessControlProps;
  const RawProfile({
    required this.id,
    required this.label,
    this.currentGroupName,
    required this.url,
    this.lastUpdateDate,
    required this.overwriteType,
    this.scriptId,
    required this.autoUpdateDurationMillis,
    this.subscriptionInfo,
    required this.autoUpdate,
    required this.selectedMap,
    required this.unfoldSet,
    this.order,
    this.accessControlProps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || currentGroupName != null) {
      map['current_group_name'] = Variable<String>(currentGroupName);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || lastUpdateDate != null) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate);
    }
    {
      map['overwrite_type'] = Variable<String>(
        $ProfilesTable.$converteroverwriteType.toSql(overwriteType),
      );
    }
    if (!nullToAbsent || scriptId != null) {
      map['script_id'] = Variable<int>(scriptId);
    }
    map['auto_update_duration_millis'] = Variable<int>(
      autoUpdateDurationMillis,
    );
    if (!nullToAbsent || subscriptionInfo != null) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo),
      );
    }
    map['auto_update'] = Variable<bool>(autoUpdate);
    {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap),
      );
    }
    {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    if (!nullToAbsent || accessControlProps != null) {
      map['access_control_props'] = Variable<String>(
        $ProfilesTable.$converteraccessControlProps.toSql(accessControlProps),
      );
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      label: Value(label),
      currentGroupName: currentGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(currentGroupName),
      url: Value(url),
      lastUpdateDate: lastUpdateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateDate),
      overwriteType: Value(overwriteType),
      scriptId: scriptId == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptId),
      autoUpdateDurationMillis: Value(autoUpdateDurationMillis),
      subscriptionInfo: subscriptionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionInfo),
      autoUpdate: Value(autoUpdate),
      selectedMap: Value(selectedMap),
      unfoldSet: Value(unfoldSet),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
      accessControlProps: accessControlProps == null && nullToAbsent
          ? const Value.absent()
          : Value(accessControlProps),
    );
  }

  factory RawProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfile(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      currentGroupName: serializer.fromJson<String?>(json['currentGroupName']),
      url: serializer.fromJson<String>(json['url']),
      lastUpdateDate: serializer.fromJson<DateTime?>(json['lastUpdateDate']),
      overwriteType: $ProfilesTable.$converteroverwriteType.fromJson(
        serializer.fromJson<String>(json['overwriteType']),
      ),
      scriptId: serializer.fromJson<int?>(json['scriptId']),
      autoUpdateDurationMillis: serializer.fromJson<int>(
        json['autoUpdateDurationMillis'],
      ),
      subscriptionInfo: serializer.fromJson<SubscriptionInfo?>(
        json['subscriptionInfo'],
      ),
      autoUpdate: serializer.fromJson<bool>(json['autoUpdate']),
      selectedMap: serializer.fromJson<Map<String, String>>(
        json['selectedMap'],
      ),
      unfoldSet: serializer.fromJson<Set<String>>(json['unfoldSet']),
      order: serializer.fromJson<int?>(json['order']),
      accessControlProps: serializer.fromJson<AccessControlProps?>(
        json['accessControlProps'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'currentGroupName': serializer.toJson<String?>(currentGroupName),
      'url': serializer.toJson<String>(url),
      'lastUpdateDate': serializer.toJson<DateTime?>(lastUpdateDate),
      'overwriteType': serializer.toJson<String>(
        $ProfilesTable.$converteroverwriteType.toJson(overwriteType),
      ),
      'scriptId': serializer.toJson<int?>(scriptId),
      'autoUpdateDurationMillis': serializer.toJson<int>(
        autoUpdateDurationMillis,
      ),
      'subscriptionInfo': serializer.toJson<SubscriptionInfo?>(
        subscriptionInfo,
      ),
      'autoUpdate': serializer.toJson<bool>(autoUpdate),
      'selectedMap': serializer.toJson<Map<String, String>>(selectedMap),
      'unfoldSet': serializer.toJson<Set<String>>(unfoldSet),
      'order': serializer.toJson<int?>(order),
      'accessControlProps': serializer.toJson<AccessControlProps?>(
        accessControlProps,
      ),
    };
  }

  RawProfile copyWith({
    int? id,
    String? label,
    Value<String?> currentGroupName = const Value.absent(),
    String? url,
    Value<DateTime?> lastUpdateDate = const Value.absent(),
    OverwriteType? overwriteType,
    Value<int?> scriptId = const Value.absent(),
    int? autoUpdateDurationMillis,
    Value<SubscriptionInfo?> subscriptionInfo = const Value.absent(),
    bool? autoUpdate,
    Map<String, String>? selectedMap,
    Set<String>? unfoldSet,
    Value<int?> order = const Value.absent(),
    Value<AccessControlProps?> accessControlProps = const Value.absent(),
  }) => RawProfile(
    id: id ?? this.id,
    label: label ?? this.label,
    currentGroupName: currentGroupName.present
        ? currentGroupName.value
        : this.currentGroupName,
    url: url ?? this.url,
    lastUpdateDate: lastUpdateDate.present
        ? lastUpdateDate.value
        : this.lastUpdateDate,
    overwriteType: overwriteType ?? this.overwriteType,
    scriptId: scriptId.present ? scriptId.value : this.scriptId,
    autoUpdateDurationMillis:
        autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
    subscriptionInfo: subscriptionInfo.present
        ? subscriptionInfo.value
        : this.subscriptionInfo,
    autoUpdate: autoUpdate ?? this.autoUpdate,
    selectedMap: selectedMap ?? this.selectedMap,
    unfoldSet: unfoldSet ?? this.unfoldSet,
    order: order.present ? order.value : this.order,
    accessControlProps: accessControlProps.present
        ? accessControlProps.value
        : this.accessControlProps,
  );
  RawProfile copyWithCompanion(ProfilesCompanion data) {
    return RawProfile(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      currentGroupName: data.currentGroupName.present
          ? data.currentGroupName.value
          : this.currentGroupName,
      url: data.url.present ? data.url.value : this.url,
      lastUpdateDate: data.lastUpdateDate.present
          ? data.lastUpdateDate.value
          : this.lastUpdateDate,
      overwriteType: data.overwriteType.present
          ? data.overwriteType.value
          : this.overwriteType,
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      autoUpdateDurationMillis: data.autoUpdateDurationMillis.present
          ? data.autoUpdateDurationMillis.value
          : this.autoUpdateDurationMillis,
      subscriptionInfo: data.subscriptionInfo.present
          ? data.subscriptionInfo.value
          : this.subscriptionInfo,
      autoUpdate: data.autoUpdate.present
          ? data.autoUpdate.value
          : this.autoUpdate,
      selectedMap: data.selectedMap.present
          ? data.selectedMap.value
          : this.selectedMap,
      unfoldSet: data.unfoldSet.present ? data.unfoldSet.value : this.unfoldSet,
      order: data.order.present ? data.order.value : this.order,
      accessControlProps: data.accessControlProps.present
          ? data.accessControlProps.value
          : this.accessControlProps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfile(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('overwriteType: $overwriteType, ')
          ..write('scriptId: $scriptId, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order, ')
          ..write('accessControlProps: $accessControlProps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    overwriteType,
    scriptId,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
    accessControlProps,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfile &&
          other.id == this.id &&
          other.label == this.label &&
          other.currentGroupName == this.currentGroupName &&
          other.url == this.url &&
          other.lastUpdateDate == this.lastUpdateDate &&
          other.overwriteType == this.overwriteType &&
          other.scriptId == this.scriptId &&
          other.autoUpdateDurationMillis == this.autoUpdateDurationMillis &&
          other.subscriptionInfo == this.subscriptionInfo &&
          other.autoUpdate == this.autoUpdate &&
          other.selectedMap == this.selectedMap &&
          other.unfoldSet == this.unfoldSet &&
          other.order == this.order &&
          other.accessControlProps == this.accessControlProps);
}

class ProfilesCompanion extends UpdateCompanion<RawProfile> {
  final Value<int> id;
  final Value<String> label;
  final Value<String?> currentGroupName;
  final Value<String> url;
  final Value<DateTime?> lastUpdateDate;
  final Value<OverwriteType> overwriteType;
  final Value<int?> scriptId;
  final Value<int> autoUpdateDurationMillis;
  final Value<SubscriptionInfo?> subscriptionInfo;
  final Value<bool> autoUpdate;
  final Value<Map<String, String>> selectedMap;
  final Value<Set<String>> unfoldSet;
  final Value<int?> order;
  final Value<AccessControlProps?> accessControlProps;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.currentGroupName = const Value.absent(),
    this.url = const Value.absent(),
    this.lastUpdateDate = const Value.absent(),
    this.overwriteType = const Value.absent(),
    this.scriptId = const Value.absent(),
    this.autoUpdateDurationMillis = const Value.absent(),
    this.subscriptionInfo = const Value.absent(),
    this.autoUpdate = const Value.absent(),
    this.selectedMap = const Value.absent(),
    this.unfoldSet = const Value.absent(),
    this.order = const Value.absent(),
    this.accessControlProps = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    this.currentGroupName = const Value.absent(),
    required String url,
    this.lastUpdateDate = const Value.absent(),
    required OverwriteType overwriteType,
    this.scriptId = const Value.absent(),
    required int autoUpdateDurationMillis,
    this.subscriptionInfo = const Value.absent(),
    required bool autoUpdate,
    required Map<String, String> selectedMap,
    required Set<String> unfoldSet,
    this.order = const Value.absent(),
    this.accessControlProps = const Value.absent(),
  }) : label = Value(label),
       url = Value(url),
       overwriteType = Value(overwriteType),
       autoUpdateDurationMillis = Value(autoUpdateDurationMillis),
       autoUpdate = Value(autoUpdate),
       selectedMap = Value(selectedMap),
       unfoldSet = Value(unfoldSet);
  static Insertable<RawProfile> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? currentGroupName,
    Expression<String>? url,
    Expression<DateTime>? lastUpdateDate,
    Expression<String>? overwriteType,
    Expression<int>? scriptId,
    Expression<int>? autoUpdateDurationMillis,
    Expression<String>? subscriptionInfo,
    Expression<bool>? autoUpdate,
    Expression<String>? selectedMap,
    Expression<String>? unfoldSet,
    Expression<int>? order,
    Expression<String>? accessControlProps,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (currentGroupName != null) 'current_group_name': currentGroupName,
      if (url != null) 'url': url,
      if (lastUpdateDate != null) 'last_update_date': lastUpdateDate,
      if (overwriteType != null) 'overwrite_type': overwriteType,
      if (scriptId != null) 'script_id': scriptId,
      if (autoUpdateDurationMillis != null)
        'auto_update_duration_millis': autoUpdateDurationMillis,
      if (subscriptionInfo != null) 'subscription_info': subscriptionInfo,
      if (autoUpdate != null) 'auto_update': autoUpdate,
      if (selectedMap != null) 'selected_map': selectedMap,
      if (unfoldSet != null) 'unfold_set': unfoldSet,
      if (order != null) 'order': order,
      if (accessControlProps != null)
        'access_control_props': accessControlProps,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String?>? currentGroupName,
    Value<String>? url,
    Value<DateTime?>? lastUpdateDate,
    Value<OverwriteType>? overwriteType,
    Value<int?>? scriptId,
    Value<int>? autoUpdateDurationMillis,
    Value<SubscriptionInfo?>? subscriptionInfo,
    Value<bool>? autoUpdate,
    Value<Map<String, String>>? selectedMap,
    Value<Set<String>>? unfoldSet,
    Value<int?>? order,
    Value<AccessControlProps?>? accessControlProps,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      url: url ?? this.url,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      overwriteType: overwriteType ?? this.overwriteType,
      scriptId: scriptId ?? this.scriptId,
      autoUpdateDurationMillis:
          autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      selectedMap: selectedMap ?? this.selectedMap,
      unfoldSet: unfoldSet ?? this.unfoldSet,
      order: order ?? this.order,
      accessControlProps: accessControlProps ?? this.accessControlProps,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (currentGroupName.present) {
      map['current_group_name'] = Variable<String>(currentGroupName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastUpdateDate.present) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate.value);
    }
    if (overwriteType.present) {
      map['overwrite_type'] = Variable<String>(
        $ProfilesTable.$converteroverwriteType.toSql(overwriteType.value),
      );
    }
    if (scriptId.present) {
      map['script_id'] = Variable<int>(scriptId.value);
    }
    if (autoUpdateDurationMillis.present) {
      map['auto_update_duration_millis'] = Variable<int>(
        autoUpdateDurationMillis.value,
      );
    }
    if (subscriptionInfo.present) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo.value),
      );
    }
    if (autoUpdate.present) {
      map['auto_update'] = Variable<bool>(autoUpdate.value);
    }
    if (selectedMap.present) {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap.value),
      );
    }
    if (unfoldSet.present) {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (accessControlProps.present) {
      map['access_control_props'] = Variable<String>(
        $ProfilesTable.$converteraccessControlProps.toSql(
          accessControlProps.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('overwriteType: $overwriteType, ')
          ..write('scriptId: $scriptId, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order, ')
          ..write('accessControlProps: $accessControlProps')
          ..write(')'))
        .toString();
  }
}

class $ScriptsTable extends Scripts with TableInfo<$ScriptsTable, RawScript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateTimeMeta = const VerificationMeta(
    'lastUpdateTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateTime =
      GeneratedColumn<DateTime>(
        'last_update_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [id, label, lastUpdateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawScript> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
        _lastUpdateTimeMeta,
        lastUpdateTime.isAcceptableOrUnknown(
          data['last_update_time']!,
          _lastUpdateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdateTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawScript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawScript(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      lastUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_time'],
      )!,
    );
  }

  @override
  $ScriptsTable createAlias(String alias) {
    return $ScriptsTable(attachedDatabase, alias);
  }
}

class RawScript extends DataClass implements Insertable<RawScript> {
  final int id;
  final String label;
  final DateTime lastUpdateTime;
  const RawScript({
    required this.id,
    required this.label,
    required this.lastUpdateTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['last_update_time'] = Variable<DateTime>(lastUpdateTime);
    return map;
  }

  ScriptsCompanion toCompanion(bool nullToAbsent) {
    return ScriptsCompanion(
      id: Value(id),
      label: Value(label),
      lastUpdateTime: Value(lastUpdateTime),
    );
  }

  factory RawScript.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawScript(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      lastUpdateTime: serializer.fromJson<DateTime>(json['lastUpdateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'lastUpdateTime': serializer.toJson<DateTime>(lastUpdateTime),
    };
  }

  RawScript copyWith({int? id, String? label, DateTime? lastUpdateTime}) =>
      RawScript(
        id: id ?? this.id,
        label: label ?? this.label,
        lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      );
  RawScript copyWithCompanion(ScriptsCompanion data) {
    return RawScript(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawScript(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, lastUpdateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawScript &&
          other.id == this.id &&
          other.label == this.label &&
          other.lastUpdateTime == this.lastUpdateTime);
}

class ScriptsCompanion extends UpdateCompanion<RawScript> {
  final Value<int> id;
  final Value<String> label;
  final Value<DateTime> lastUpdateTime;
  const ScriptsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
  });
  ScriptsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required DateTime lastUpdateTime,
  }) : label = Value(label),
       lastUpdateTime = Value(lastUpdateTime);
  static Insertable<RawScript> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<DateTime>? lastUpdateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
    });
  }

  ScriptsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<DateTime>? lastUpdateTime,
  }) {
    return ScriptsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<DateTime>(lastUpdateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScriptsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RawRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class RawRule extends DataClass implements Insertable<RawRule> {
  final int id;
  final String value;
  const RawRule({required this.id, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<String>(value);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(id: Value(id), value: Value(value));
  }

  factory RawRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawRule(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<String>(value),
    };
  }

  RawRule copyWith({int? id, String? value}) =>
      RawRule(id: id ?? this.id, value: value ?? this.value);
  RawRule copyWithCompanion(RulesCompanion data) {
    return RawRule(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawRule(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawRule && other.id == this.id && other.value == this.value);
}

class RulesCompanion extends UpdateCompanion<RawRule> {
  final Value<int> id;
  final Value<String> value;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
  });
  RulesCompanion.insert({this.id = const Value.absent(), required String value})
    : value = Value(value);
  static Insertable<RawRule> custom({
    Expression<int>? id,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
    });
  }

  RulesCompanion copyWith({Value<int>? id, Value<String>? value}) {
    return RulesCompanion(id: id ?? this.id, value: value ?? this.value);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ProfileRuleLinksTable extends ProfileRuleLinks
    with TableInfo<$ProfileRuleLinksTable, RawProfileRuleLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRuleLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rules (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleScene?, String> scene =
      GeneratedColumn<String>(
        'scene',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RuleScene?>($ProfileRuleLinksTable.$converterscenen);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, ruleId, scene, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_rule_mapping';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfileRuleLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfileRuleLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfileRuleLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      scene: $ProfileRuleLinksTable.$converterscenen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scene'],
        ),
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProfileRuleLinksTable createAlias(String alias) {
    return $ProfileRuleLinksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleScene, String, String> $converterscene =
      const EnumNameConverter<RuleScene>(RuleScene.values);
  static JsonTypeConverter2<RuleScene?, String?, String?> $converterscenen =
      JsonTypeConverter2.asNullable($converterscene);
}

class RawProfileRuleLink extends DataClass
    implements Insertable<RawProfileRuleLink> {
  final String id;
  final int? profileId;
  final int ruleId;
  final RuleScene? scene;
  final String? order;
  const RawProfileRuleLink({
    required this.id,
    this.profileId,
    required this.ruleId,
    this.scene,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['rule_id'] = Variable<int>(ruleId);
    if (!nullToAbsent || scene != null) {
      map['scene'] = Variable<String>(
        $ProfileRuleLinksTable.$converterscenen.toSql(scene),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    return map;
  }

  ProfileRuleLinksCompanion toCompanion(bool nullToAbsent) {
    return ProfileRuleLinksCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      ruleId: Value(ruleId),
      scene: scene == null && nullToAbsent
          ? const Value.absent()
          : Value(scene),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProfileRuleLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfileRuleLink(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      scene: $ProfileRuleLinksTable.$converterscenen.fromJson(
        serializer.fromJson<String?>(json['scene']),
      ),
      order: serializer.fromJson<String?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'ruleId': serializer.toJson<int>(ruleId),
      'scene': serializer.toJson<String?>(
        $ProfileRuleLinksTable.$converterscenen.toJson(scene),
      ),
      'order': serializer.toJson<String?>(order),
    };
  }

  RawProfileRuleLink copyWith({
    String? id,
    Value<int?> profileId = const Value.absent(),
    int? ruleId,
    Value<RuleScene?> scene = const Value.absent(),
    Value<String?> order = const Value.absent(),
  }) => RawProfileRuleLink(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    ruleId: ruleId ?? this.ruleId,
    scene: scene.present ? scene.value : this.scene,
    order: order.present ? order.value : this.order,
  );
  RawProfileRuleLink copyWithCompanion(ProfileRuleLinksCompanion data) {
    return RawProfileRuleLink(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      scene: data.scene.present ? data.scene.value : this.scene,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfileRuleLink(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId, ')
          ..write('scene: $scene, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, ruleId, scene, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfileRuleLink &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.ruleId == this.ruleId &&
          other.scene == this.scene &&
          other.order == this.order);
}

class ProfileRuleLinksCompanion extends UpdateCompanion<RawProfileRuleLink> {
  final Value<String> id;
  final Value<int?> profileId;
  final Value<int> ruleId;
  final Value<RuleScene?> scene;
  final Value<String?> order;
  final Value<int> rowid;
  const ProfileRuleLinksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.scene = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileRuleLinksCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required int ruleId,
    this.scene = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId);
  static Insertable<RawProfileRuleLink> custom({
    Expression<String>? id,
    Expression<int>? profileId,
    Expression<int>? ruleId,
    Expression<String>? scene,
    Expression<String>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (ruleId != null) 'rule_id': ruleId,
      if (scene != null) 'scene': scene,
      if (order != null) 'order': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileRuleLinksCompanion copyWith({
    Value<String>? id,
    Value<int?>? profileId,
    Value<int>? ruleId,
    Value<RuleScene?>? scene,
    Value<String?>? order,
    Value<int>? rowid,
  }) {
    return ProfileRuleLinksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ruleId: ruleId ?? this.ruleId,
      scene: scene ?? this.scene,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (scene.present) {
      map['scene'] = Variable<String>(
        $ProfileRuleLinksTable.$converterscenen.toSql(scene.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRuleLinksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId, ')
          ..write('scene: $scene, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetworkRulesTable extends NetworkRules
    with TableInfo<$NetworkRulesTable, RawNetworkRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetworkRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<int> action = GeneratedColumn<int>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    conditions,
    action,
    priority,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'network_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawNetworkRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    } else if (isInserting) {
      context.missing(_conditionsMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawNetworkRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawNetworkRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      conditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $NetworkRulesTable createAlias(String alias) {
    return $NetworkRulesTable(attachedDatabase, alias);
  }
}

class RawNetworkRule extends DataClass implements Insertable<RawNetworkRule> {
  final int id;
  final String? name;

  /// JSON-encoded `List<NetworkCondition>`.
  final String conditions;

  /// Stored as `NetworkAction.index` (0=turnOn, 1=turnOff).
  final int action;
  final int priority;
  final bool enabled;
  const RawNetworkRule({
    required this.id,
    this.name,
    required this.conditions,
    required this.action,
    required this.priority,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['conditions'] = Variable<String>(conditions);
    map['action'] = Variable<int>(action);
    map['priority'] = Variable<int>(priority);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  NetworkRulesCompanion toCompanion(bool nullToAbsent) {
    return NetworkRulesCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      conditions: Value(conditions),
      action: Value(action),
      priority: Value(priority),
      enabled: Value(enabled),
    );
  }

  factory RawNetworkRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawNetworkRule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      conditions: serializer.fromJson<String>(json['conditions']),
      action: serializer.fromJson<int>(json['action']),
      priority: serializer.fromJson<int>(json['priority']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'conditions': serializer.toJson<String>(conditions),
      'action': serializer.toJson<int>(action),
      'priority': serializer.toJson<int>(priority),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  RawNetworkRule copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    String? conditions,
    int? action,
    int? priority,
    bool? enabled,
  }) => RawNetworkRule(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    conditions: conditions ?? this.conditions,
    action: action ?? this.action,
    priority: priority ?? this.priority,
    enabled: enabled ?? this.enabled,
  );
  RawNetworkRule copyWithCompanion(NetworkRulesCompanion data) {
    return RawNetworkRule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      action: data.action.present ? data.action.value : this.action,
      priority: data.priority.present ? data.priority.value : this.priority,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawNetworkRule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conditions: $conditions, ')
          ..write('action: $action, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, conditions, action, priority, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawNetworkRule &&
          other.id == this.id &&
          other.name == this.name &&
          other.conditions == this.conditions &&
          other.action == this.action &&
          other.priority == this.priority &&
          other.enabled == this.enabled);
}

class NetworkRulesCompanion extends UpdateCompanion<RawNetworkRule> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String> conditions;
  final Value<int> action;
  final Value<int> priority;
  final Value<bool> enabled;
  const NetworkRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.conditions = const Value.absent(),
    this.action = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  NetworkRulesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String conditions,
    required int action,
    required int priority,
    this.enabled = const Value.absent(),
  }) : conditions = Value(conditions),
       action = Value(action),
       priority = Value(priority);
  static Insertable<RawNetworkRule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? conditions,
    Expression<int>? action,
    Expression<int>? priority,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (conditions != null) 'conditions': conditions,
      if (action != null) 'action': action,
      if (priority != null) 'priority': priority,
      if (enabled != null) 'enabled': enabled,
    });
  }

  NetworkRulesCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<String>? conditions,
    Value<int>? action,
    Value<int>? priority,
    Value<bool>? enabled,
  }) {
    return NetworkRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      conditions: conditions ?? this.conditions,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (action.present) {
      map['action'] = Variable<int>(action.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworkRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conditions: $conditions, ')
          ..write('action: $action, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ScriptsTable scripts = $ScriptsTable(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $ProfileRuleLinksTable profileRuleLinks = $ProfileRuleLinksTable(
    this,
  );
  late final $NetworkRulesTable networkRules = $NetworkRulesTable(this);
  late final Index idxProfileSceneOrder = Index(
    'idx_profile_scene_order',
    'CREATE INDEX idx_profile_scene_order ON profile_rule_mapping (profile_id, scene, "order")',
  );
  late final ProfilesDao profilesDao = ProfilesDao(this as Database);
  late final ScriptsDao scriptsDao = ScriptsDao(this as Database);
  late final RulesDao rulesDao = RulesDao(this as Database);
  late final NetworkRulesDao networkRulesDao = NetworkRulesDao(
    this as Database,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    scripts,
    rules,
    profileRuleLinks,
    networkRules,
    idxProfileSceneOrder,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('profile_rule_mapping', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('profile_rule_mapping', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String label,
      Value<String?> currentGroupName,
      required String url,
      Value<DateTime?> lastUpdateDate,
      required OverwriteType overwriteType,
      Value<int?> scriptId,
      required int autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      required bool autoUpdate,
      required Map<String, String> selectedMap,
      required Set<String> unfoldSet,
      Value<int?> order,
      Value<AccessControlProps?> accessControlProps,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String?> currentGroupName,
      Value<String> url,
      Value<DateTime?> lastUpdateDate,
      Value<OverwriteType> overwriteType,
      Value<int?> scriptId,
      Value<int> autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      Value<bool> autoUpdate,
      Value<Map<String, String>> selectedMap,
      Value<Set<String>> unfoldSet,
      Value<int?> order,
      Value<AccessControlProps?> accessControlProps,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$Database, $ProfilesTable, RawProfile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileRuleLinksTable, List<RawProfileRuleLink>>
  _profileRuleLinksRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.profileRuleLinks,
    aliasName: $_aliasNameGenerator(
      db.profiles.id,
      db.profileRuleLinks.profileId,
    ),
  );

  $$ProfileRuleLinksTableProcessedTableManager get profileRuleLinksRefs {
    final manager = $$ProfileRuleLinksTableTableManager(
      $_db,
      $_db.profileRuleLinks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileRuleLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OverwriteType, OverwriteType, String>
  get overwriteType => $composableBuilder(
    column: $table.overwriteType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubscriptionInfo?, SubscriptionInfo, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<String>, Set<String>, String>
  get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    AccessControlProps?,
    AccessControlProps,
    String
  >
  get accessControlProps => $composableBuilder(
    column: $table.accessControlProps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> profileRuleLinksRefs(
    Expression<bool> Function($$ProfileRuleLinksTableFilterComposer f) f,
  ) {
    final $$ProfileRuleLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableFilterComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overwriteType => $composableBuilder(
    column: $table.overwriteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessControlProps => $composableBuilder(
    column: $table.accessControlProps,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OverwriteType, String> get overwriteType =>
      $composableBuilder(
        column: $table.overwriteType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get scriptId =>
      $composableBuilder(column: $table.scriptId, builder: (column) => column);

  GeneratedColumn<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<String>, String> get unfoldSet =>
      $composableBuilder(column: $table.unfoldSet, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccessControlProps?, String>
  get accessControlProps => $composableBuilder(
    column: $table.accessControlProps,
    builder: (column) => column,
  );

  Expression<T> profileRuleLinksRefs<T extends Object>(
    Expression<T> Function($$ProfileRuleLinksTableAnnotationComposer a) f,
  ) {
    final $$ProfileRuleLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfilesTable,
          RawProfile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (RawProfile, $$ProfilesTableReferences),
          RawProfile,
          PrefetchHooks Function({bool profileRuleLinksRefs})
        > {
  $$ProfilesTableTableManager(_$Database db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> currentGroupName = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                Value<OverwriteType> overwriteType = const Value.absent(),
                Value<int?> scriptId = const Value.absent(),
                Value<int> autoUpdateDurationMillis = const Value.absent(),
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                Value<bool> autoUpdate = const Value.absent(),
                Value<Map<String, String>> selectedMap = const Value.absent(),
                Value<Set<String>> unfoldSet = const Value.absent(),
                Value<int?> order = const Value.absent(),
                Value<AccessControlProps?> accessControlProps =
                    const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                overwriteType: overwriteType,
                scriptId: scriptId,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
                accessControlProps: accessControlProps,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                Value<String?> currentGroupName = const Value.absent(),
                required String url,
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                required OverwriteType overwriteType,
                Value<int?> scriptId = const Value.absent(),
                required int autoUpdateDurationMillis,
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                required bool autoUpdate,
                required Map<String, String> selectedMap,
                required Set<String> unfoldSet,
                Value<int?> order = const Value.absent(),
                Value<AccessControlProps?> accessControlProps =
                    const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                overwriteType: overwriteType,
                scriptId: scriptId,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
                accessControlProps: accessControlProps,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileRuleLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileRuleLinksRefs) db.profileRuleLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileRuleLinksRefs)
                    await $_getPrefetchedData<
                      RawProfile,
                      $ProfilesTable,
                      RawProfileRuleLink
                    >(
                      currentTable: table,
                      referencedTable: $$ProfilesTableReferences
                          ._profileRuleLinksRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProfilesTableReferences(
                        db,
                        table,
                        p0,
                      ).profileRuleLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfilesTable,
      RawProfile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (RawProfile, $$ProfilesTableReferences),
      RawProfile,
      PrefetchHooks Function({bool profileRuleLinksRefs})
    >;
typedef $$ScriptsTableCreateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      required String label,
      required DateTime lastUpdateTime,
    });
typedef $$ScriptsTableUpdateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<DateTime> lastUpdateTime,
    });

class $$ScriptsTableFilterComposer extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScriptsTableOrderingComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScriptsTableAnnotationComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => column,
  );
}

class $$ScriptsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ScriptsTable,
          RawScript,
          $$ScriptsTableFilterComposer,
          $$ScriptsTableOrderingComposer,
          $$ScriptsTableAnnotationComposer,
          $$ScriptsTableCreateCompanionBuilder,
          $$ScriptsTableUpdateCompanionBuilder,
          (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
          RawScript,
          PrefetchHooks Function()
        > {
  $$ScriptsTableTableManager(_$Database db, $ScriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> lastUpdateTime = const Value.absent(),
              }) => ScriptsCompanion(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required DateTime lastUpdateTime,
              }) => ScriptsCompanion.insert(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ScriptsTable,
      RawScript,
      $$ScriptsTableFilterComposer,
      $$ScriptsTableOrderingComposer,
      $$ScriptsTableAnnotationComposer,
      $$ScriptsTableCreateCompanionBuilder,
      $$ScriptsTableUpdateCompanionBuilder,
      (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
      RawScript,
      PrefetchHooks Function()
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({Value<int> id, required String value});
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({Value<int> id, Value<String> value});

final class $$RulesTableReferences
    extends BaseReferences<_$Database, $RulesTable, RawRule> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileRuleLinksTable, List<RawProfileRuleLink>>
  _profileRuleLinksRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.profileRuleLinks,
    aliasName: $_aliasNameGenerator(db.rules.id, db.profileRuleLinks.ruleId),
  );

  $$ProfileRuleLinksTableProcessedTableManager get profileRuleLinksRefs {
    final manager = $$ProfileRuleLinksTableTableManager(
      $_db,
      $_db.profileRuleLinks,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileRuleLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RulesTableFilterComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profileRuleLinksRefs(
    Expression<bool> Function($$ProfileRuleLinksTableFilterComposer f) f,
  ) {
    final $$ProfileRuleLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableFilterComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableOrderingComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesTableAnnotationComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  Expression<T> profileRuleLinksRefs<T extends Object>(
    Expression<T> Function($$ProfileRuleLinksTableAnnotationComposer a) f,
  ) {
    final $$ProfileRuleLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileRuleLinks,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileRuleLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.profileRuleLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $RulesTable,
          RawRule,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RawRule, $$RulesTableReferences),
          RawRule,
          PrefetchHooks Function({bool profileRuleLinksRefs})
        > {
  $$RulesTableTableManager(_$Database db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => RulesCompanion(id: id, value: value),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String value}) =>
                  RulesCompanion.insert(id: id, value: value),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RulesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profileRuleLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileRuleLinksRefs) db.profileRuleLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileRuleLinksRefs)
                    await $_getPrefetchedData<
                      RawRule,
                      $RulesTable,
                      RawProfileRuleLink
                    >(
                      currentTable: table,
                      referencedTable: $$RulesTableReferences
                          ._profileRuleLinksRefsTable(db),
                      managerFromTypedResult: (p0) => $$RulesTableReferences(
                        db,
                        table,
                        p0,
                      ).profileRuleLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ruleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $RulesTable,
      RawRule,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RawRule, $$RulesTableReferences),
      RawRule,
      PrefetchHooks Function({bool profileRuleLinksRefs})
    >;
typedef $$ProfileRuleLinksTableCreateCompanionBuilder =
    ProfileRuleLinksCompanion Function({
      required String id,
      Value<int?> profileId,
      required int ruleId,
      Value<RuleScene?> scene,
      Value<String?> order,
      Value<int> rowid,
    });
typedef $$ProfileRuleLinksTableUpdateCompanionBuilder =
    ProfileRuleLinksCompanion Function({
      Value<String> id,
      Value<int?> profileId,
      Value<int> ruleId,
      Value<RuleScene?> scene,
      Value<String?> order,
      Value<int> rowid,
    });

final class $$ProfileRuleLinksTableReferences
    extends
        BaseReferences<_$Database, $ProfileRuleLinksTable, RawProfileRuleLink> {
  $$ProfileRuleLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.profileRuleLinks.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RulesTable _ruleIdTable(_$Database db) => db.rules.createAlias(
    $_aliasNameGenerator(db.profileRuleLinks.ruleId, db.rules.id),
  );

  $$RulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileRuleLinksTableFilterComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RuleScene?, RuleScene, String> get scene =>
      $composableBuilder(
        column: $table.scene,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableFilterComposer get ruleId {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableOrderingComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scene => $composableBuilder(
    column: $table.scene,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableOrderingComposer get ruleId {
    final $$RulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableOrderingComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableAnnotationComposer
    extends Composer<_$Database, $ProfileRuleLinksTable> {
  $$ProfileRuleLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleScene?, String> get scene =>
      $composableBuilder(column: $table.scene, builder: (column) => column);

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableAnnotationComposer get ruleId {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileRuleLinksTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfileRuleLinksTable,
          RawProfileRuleLink,
          $$ProfileRuleLinksTableFilterComposer,
          $$ProfileRuleLinksTableOrderingComposer,
          $$ProfileRuleLinksTableAnnotationComposer,
          $$ProfileRuleLinksTableCreateCompanionBuilder,
          $$ProfileRuleLinksTableUpdateCompanionBuilder,
          (RawProfileRuleLink, $$ProfileRuleLinksTableReferences),
          RawProfileRuleLink,
          PrefetchHooks Function({bool profileId, bool ruleId})
        > {
  $$ProfileRuleLinksTableTableManager(
    _$Database db,
    $ProfileRuleLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileRuleLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileRuleLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileRuleLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<RuleScene?> scene = const Value.absent(),
                Value<String?> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRuleLinksCompanion(
                id: id,
                profileId: profileId,
                ruleId: ruleId,
                scene: scene,
                order: order,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> profileId = const Value.absent(),
                required int ruleId,
                Value<RuleScene?> scene = const Value.absent(),
                Value<String?> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRuleLinksCompanion.insert(
                id: id,
                profileId: profileId,
                ruleId: ruleId,
                scene: scene,
                order: order,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileRuleLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileRuleLinksTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileRuleLinksTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ruleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ruleId,
                                referencedTable:
                                    $$ProfileRuleLinksTableReferences
                                        ._ruleIdTable(db),
                                referencedColumn:
                                    $$ProfileRuleLinksTableReferences
                                        ._ruleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileRuleLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfileRuleLinksTable,
      RawProfileRuleLink,
      $$ProfileRuleLinksTableFilterComposer,
      $$ProfileRuleLinksTableOrderingComposer,
      $$ProfileRuleLinksTableAnnotationComposer,
      $$ProfileRuleLinksTableCreateCompanionBuilder,
      $$ProfileRuleLinksTableUpdateCompanionBuilder,
      (RawProfileRuleLink, $$ProfileRuleLinksTableReferences),
      RawProfileRuleLink,
      PrefetchHooks Function({bool profileId, bool ruleId})
    >;
typedef $$NetworkRulesTableCreateCompanionBuilder =
    NetworkRulesCompanion Function({
      Value<int> id,
      Value<String?> name,
      required String conditions,
      required int action,
      required int priority,
      Value<bool> enabled,
    });
typedef $$NetworkRulesTableUpdateCompanionBuilder =
    NetworkRulesCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<String> conditions,
      Value<int> action,
      Value<int> priority,
      Value<bool> enabled,
    });

class $$NetworkRulesTableFilterComposer
    extends Composer<_$Database, $NetworkRulesTable> {
  $$NetworkRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetworkRulesTableOrderingComposer
    extends Composer<_$Database, $NetworkRulesTable> {
  $$NetworkRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetworkRulesTableAnnotationComposer
    extends Composer<_$Database, $NetworkRulesTable> {
  $$NetworkRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$NetworkRulesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $NetworkRulesTable,
          RawNetworkRule,
          $$NetworkRulesTableFilterComposer,
          $$NetworkRulesTableOrderingComposer,
          $$NetworkRulesTableAnnotationComposer,
          $$NetworkRulesTableCreateCompanionBuilder,
          $$NetworkRulesTableUpdateCompanionBuilder,
          (
            RawNetworkRule,
            BaseReferences<_$Database, $NetworkRulesTable, RawNetworkRule>,
          ),
          RawNetworkRule,
          PrefetchHooks Function()
        > {
  $$NetworkRulesTableTableManager(_$Database db, $NetworkRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetworkRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetworkRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetworkRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<int> action = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => NetworkRulesCompanion(
                id: id,
                name: name,
                conditions: conditions,
                action: action,
                priority: priority,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String conditions,
                required int action,
                required int priority,
                Value<bool> enabled = const Value.absent(),
              }) => NetworkRulesCompanion.insert(
                id: id,
                name: name,
                conditions: conditions,
                action: action,
                priority: priority,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetworkRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $NetworkRulesTable,
      RawNetworkRule,
      $$NetworkRulesTableFilterComposer,
      $$NetworkRulesTableOrderingComposer,
      $$NetworkRulesTableAnnotationComposer,
      $$NetworkRulesTableCreateCompanionBuilder,
      $$NetworkRulesTableUpdateCompanionBuilder,
      (
        RawNetworkRule,
        BaseReferences<_$Database, $NetworkRulesTable, RawNetworkRule>,
      ),
      RawNetworkRule,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db, _db.scripts);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$ProfileRuleLinksTableTableManager get profileRuleLinks =>
      $$ProfileRuleLinksTableTableManager(_db, _db.profileRuleLinks);
  $$NetworkRulesTableTableManager get networkRules =>
      $$NetworkRulesTableTableManager(_db, _db.networkRules);
}

mixin _$ProfilesDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
}
mixin _$ScriptsDaoMixin on DatabaseAccessor<Database> {
  $ScriptsTable get scripts => attachedDatabase.scripts;
}
mixin _$RulesDaoMixin on DatabaseAccessor<Database> {
  $RulesTable get rules => attachedDatabase.rules;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProfileRuleLinksTable get profileRuleLinks =>
      attachedDatabase.profileRuleLinks;
}
mixin _$NetworkRulesDaoMixin on DatabaseAccessor<Database> {
  $NetworkRulesTable get networkRules => attachedDatabase.networkRules;
}
