part of '../controller.dart';

extension AppRoutingController on AppController {
  Future<List<RoutingRule>> readRoutingRules(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).rules;
  }

  /// Live-mirrors [rules] into the profile's `<id>.yaml` (rest of the file
  /// preserved) and hot-applies when it is the active profile. Returns a
  /// validation error string on a rejected config (the file is left untouched),
  /// or null on success.
  Future<String?> writeRoutingRules(
    int profileId,
    List<RoutingRule> rules,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = ProfileRulesDocument(raw).withRules(rules);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  Future<List<String>> readExcludedPackages(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).excludedPackages;
  }

  Future<List<String>> readIncludedPackages(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).includedPackages;
  }

  Future<List<String>> readSubRuleNames(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).subRuleNames;
  }

  Future<Map<String, List<RoutingRule>>> readSubRules(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const {};
    return ProfileRulesDocument(await file.readAsString()).subRules;
  }

  /// Live-mirrors the whole `sub-rules:` block. An empty map removes the key.
  Future<String?> writeSubRules(
    int profileId,
    Map<String, List<RoutingRule>> subRules,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = ProfileRulesDocument(raw).withSubRules(subRules);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  /// Whitelist (tun.include-package present) vs blacklist (the default) for a
  /// profile, derived from which package key the file carries.
  Future<AccessControlMode> readTunnelMode(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return AccessControlMode.rejectSelected;
    final included = ProfileRulesDocument(
      await file.readAsString(),
    ).includedPackages;
    return included.isEmpty
        ? AccessControlMode.rejectSelected
        : AccessControlMode.acceptSelected;
  }

  /// Sets an app's routing target, replacing any existing app rule for
  /// [packageName]. When [isSubRule] the target is a sub-rule name and the rule
  /// is written as `SUB-RULE,(PROCESS-NAME,<pkg>),<target>`; otherwise it is a
  /// proxy/group and the rule is a flat `PROCESS-NAME,<pkg>,<target>`. A
  /// null/empty [target] drops the rule. Hot-applies.
  Future<String?> setAppTarget(
    int profileId,
    String packageName, {
    String? target,
    bool isSubRule = false,
  }) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final doc = ProfileRulesDocument(raw);
    final rules = doc.rules.where((r) => !_isAppRule(r, packageName)).toList();
    if (target != null && target.isNotEmpty) {
      rules.insert(
        0,
        isSubRule
            ? AppToSubRuleRoute(packageName: packageName, subRuleName: target)
            : TypedRule(
                action: RuleAction.PROCESS_NAME,
                value: packageName,
                target: target,
              ),
      );
    }
    final String next;
    try {
      next = doc.withRules(rules);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  /// Sets an app's tunnel membership for the profile's [mode]. Whitelist:
  /// [inTunnel] adds/removes the app from tun.include-package. Blacklist: the
  /// inverse on tun.exclude-package. Takes effect on the next VPN restart.
  Future<String?> setAppMembership(
    int profileId,
    String packageName, {
    required AccessControlMode mode,
    required bool inTunnel,
  }) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'tun: {}\n';
    final doc = ProfileRulesDocument(raw);
    final String next;
    try {
      if (mode == AccessControlMode.acceptSelected) {
        final list = doc.includedPackages.toList()..remove(packageName);
        if (inTunnel) list.insert(0, packageName);
        next = doc.withIncludedPackages(list);
      } else {
        final list = doc.excludedPackages.toList()..remove(packageName);
        if (!inTunnel) list.insert(0, packageName);
        next = doc.withExcludedPackages(list);
      }
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  /// One-time fold of a per-profile [Profile.accessControlProps] override into
  /// the YAML tun.*-package SSoT, then clears the drift override so the two no
  /// longer fight (effectiveAccessControl preferred the drift one). Returns the
  /// migrated app count, or null when there was nothing to migrate.
  Future<int?> migrateAccessControlToYaml(int profileId) async {
    final profile = _ref.read(profilesProvider).getProfile(profileId);
    final acl = profile?.accessControlProps;
    if (profile == null || acl == null || !acl.enable) return null;
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return null;
    final doc = ProfileRulesDocument(await file.readAsString());
    final String next;
    try {
      next = acl.mode == AccessControlMode.acceptSelected
          ? doc.withIncludedPackages(acl.acceptList)
          : doc.withExcludedPackages(acl.rejectList);
    } on ProfileRulesWriteException {
      return null;
    }
    final error = await coreController.validateConfigWithData(next);
    if (error.isNotEmpty) return null;
    await file.safeWriteAsString(next);
    putProfile(profile.copyWith(accessControlProps: null));
    if (profileId == _ref.read(currentProfileIdProvider)) {
      await applyProfile(force: true);
    }
    return acl.currentList.length;
  }

  bool _isAppRule(RoutingRule r, String packageName) =>
      (r is TypedRule &&
          r.action == RuleAction.PROCESS_NAME &&
          r.value == packageName) ||
      (r is AppToSubRuleRoute && r.packageName == packageName);

  Future<String?> _writeValidatedApply(
    File file,
    int profileId,
    String next,
  ) async {
    final error = await coreController.validateConfigWithData(next);
    if (error.isNotEmpty) return error;
    await file.safeWriteAsString(next);
    if (profileId == _ref.read(currentProfileIdProvider)) {
      await applyProfile(force: true);
    }
    return null;
  }
}
