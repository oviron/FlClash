import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ingest/pipeline.dart';
import 'package:fl_clash/profile_routing/reapply.dart';
import 'package:fl_clash/profile_routing/target_validation.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';
import 'config.dart';
import 'state.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

@freezed
abstract class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    @Default(0) int upload,
    @Default(0) int download,
    @Default(0) int total,
    @Default(0) int expire,
  }) = _SubscriptionInfo;

  const SubscriptionInfo._();

  factory SubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$SubscriptionInfoFromJson(json);

  factory SubscriptionInfo.formHString(String? info) {
    if (info == null) return const SubscriptionInfo();
    final map = <String, int?>{};
    for (final part in info.split(';')) {
      final kv = part.trim().split('=');
      if (kv.length < 2) continue; // a bare token or the trailing ';'
      map[kv[0].trim()] = int.tryParse(kv[1].trim());
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }

  int get used => upload + download;

  int get remaining => total > used ? total - used : 0;
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required int id,
    @Default('') String label,
    String? currentGroupName,
    @Default('') String url,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    @Default(true) bool autoUpdate,
    // Fetch this subscription as the Happ client (UA + device id) so panels that
    // gate their full node set behind Happ serve it in full; off = honest fetch.
    @Default(false) bool happMode,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(OverwriteType.standard) OverwriteType overwriteType,
    int? scriptId,
    int? order,
    AccessControlProps? accessControlProps,
    AppFilterStash? appFilterStash,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({String? label, String url = ''}) {
    final id = snowflake.id;
    return Profile(
      label: label ?? '',
      url: url,
      id: id,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }
}

@freezed
abstract class ProfileRuleLink with _$ProfileRuleLink {
  const factory ProfileRuleLink({
    int? profileId,
    required int ruleId,
    RuleScene? scene,
    String? order,
  }) = _ProfileRuleLink;
}

extension ProfileRuleLinkExt on ProfileRuleLink {
  String get key {
    final splits = <String?>[
      profileId?.toString(),
      ruleId.toString(),
      scene?.name,
    ];
    return splits.where((item) => item != null).join('_');
  }
}

@freezed
abstract class StandardOverwrite with _$StandardOverwrite {
  const factory StandardOverwrite({
    @Default([]) List<Rule> addedRules,
    @Default([]) List<int> disabledRuleIds,
  }) = _StandardOverwrite;

  factory StandardOverwrite.fromJson(Map<String, Object?> json) =>
      _$StandardOverwriteFromJson(json);
}

@freezed
abstract class ScriptOverwrite with _$ScriptOverwrite {
  const factory ScriptOverwrite({int? scriptId}) = _ScriptOverwrite;

  factory ScriptOverwrite.fromJson(Map<String, Object?> json) =>
      _$ScriptOverwriteFromJson(json);
}

extension ProfilesExt on List<Profile> {
  Profile? getProfile(int? profileId) {
    final index = indexWhere((profile) => profile.id == profileId);
    return index == -1 ? null : this[index];
  }

  String _getLabel(String label, int id) {
    final realLabel = label.takeFirstValid([id.toString()]);
    final hasDup =
        indexWhere(
          (element) => element.label == realLabel && element.id != id,
        ) !=
        -1;
    if (hasDup) {
      return _getLabel(utils.getOverwriteLabel(realLabel), id);
    } else {
      return label;
    }
  }

  VM2<List<Profile>, Profile> copyAndAddProfile(Profile profile) {
    final List<Profile> profilesTemp = List.from(this);
    final index = profilesTemp.indexWhere(
      (element) => element.id == profile.id,
    );
    final updateProfile = profile.copyWith(
      label: _getLabel(profile.label, profile.id),
    );
    if (index == -1) {
      profilesTemp.add(updateProfile);
    } else {
      profilesTemp[index] = updateProfile;
    }
    return VM2(profilesTemp, updateProfile);
  }
}

extension ProfileExtension on Profile {
  ProfileType get type =>
      url.isEmpty == true ? ProfileType.file : ProfileType.url;

  bool get realAutoUpdate => url.isEmpty == true ? false : autoUpdate;

  String get realLabel => label.takeFirstValid([id.toString()]);

  String get fileName => '$id.yaml';

  String get updatingKey => 'profile_$id';

  Future<Profile?> checkAndUpdateAndCopy() async {
    final mFile = await _getFile(false);
    final isExists = await mFile.exists();
    if (isExists || url.isEmpty) {
      return null;
    }
    return update();
  }

  Future<File> _getFile([bool autoCreate = true]) async {
    final path = await appPath.getProfilePath(id.toString());
    final file = File(path);
    final isExists = await file.exists();
    if (!isExists && autoCreate) {
      return await file.create(recursive: true);
    }
    return file;
  }

  Future<File> get file async {
    return _getFile();
  }

  Future<Profile> update() async {
    // One ingestion path: resolve any wrapper, dual-fetch (honest + Happ, the
    // richer wins), and normalize. Convert to a self-contained config, or pass a
    // clash doc through so the native validateConfig surfaces an honest error.
    final ingested = await ingest(url);
    final meta = ingested.meta;
    final converted =
        await artifactToConfigBytes(ingested.body) ??
        Uint8List.fromList(utf8.encode(ingested.body));
    final bytes = await _reapplyAppRouting(converted);
    _notifyDanglingTargets(bytes);
    return await copyWith(
      label: label.takeFirstValid([
        utils.getFileNameForDisposition(meta.disposition),
        id.toString(),
      ]),
      subscriptionInfo: SubscriptionInfo.formHString(meta.userinfo),
      autoUpdateDuration: meta.updateHours != null && meta.updateHours! > 0
          ? Duration(hours: meta.updateHours!)
          : autoUpdateDuration,
    ).saveFile(bytes);
  }

  // A subscription refresh can rename/remove a proxy-group a routing rule
  // points at; warn (keep the rule, no auto-rewrite) so the user can re-target.
  void _notifyDanglingTargets(Uint8List bytes) {
    try {
      final content = utf8.decode(bytes);
      final dangling = danglingTargets(
        ProfileRulesDocument(content).rules,
        configTargets(content),
      );
      if (dangling.isNotEmpty) {
        globalState.showNotifier(
          appLocalizations.appRoutingDanglingTargets(dangling.length),
        );
      }
    } catch (e) {
      commonPrint.log('dangling-target check failed: $e');
    }
  }

  // Carry the user's per-app routing rules across a subscription refresh
  // (prefer-user); the raw download would otherwise drop them. Best-effort:
  // any failure falls back to the untouched download.
  Future<Uint8List> _reapplyAppRouting(Uint8List freshBytes) async {
    try {
      final mFile = await _getFile(false);
      if (!await mFile.exists()) return freshBytes;
      final result = reapplyAppRouting(
        previous: await mFile.readAsString(),
        fresh: utf8.decode(freshBytes),
      );
      if (!result.changed) return freshBytes;
      globalState.showNotifier(
        appLocalizations.appRoutingRulesReapplied(
          result.overlaid,
          result.conflicts,
        ),
      );
      return Uint8List.fromList(utf8.encode(result.content));
    } catch (e) {
      commonPrint.log('reapply app-routing failed: $e');
      return freshBytes;
    }
  }

  Future<Profile> saveFile(Uint8List bytes) async {
    final path = await appPath.tempFilePath;
    final tempFile = File(path);
    await tempFile.safeWriteAsBytes(bytes);
    try {
      final message = await coreController
          .validateConfig(path)
          .withTimeout(
            timeout: profileValidationTimeoutDuration,
            tag: 'validateConfig',
          );
      if (message.isNotEmpty) {
        throw message;
      }
      final mFile = await file;
      await tempFile.copy(mFile.path);
      return copyWith(lastUpdateDate: DateTime.now());
    } finally {
      await tempFile.safeDelete();
    }
  }
}
