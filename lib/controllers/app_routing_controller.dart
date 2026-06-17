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

  /// Switches the profile's tunnel mode by moving the membership list under the
  /// other tun key: whitelist keeps the in-tunnel apps as include-package,
  /// blacklist keeps the bypassing apps as exclude-package. The current
  /// [packages] (installed apps) bound the membership so the inverted set stays
  /// finite. A null/equal target is a no-op. Hot-applies.
  Future<String?> setTunnelMode(
    int profileId,
    AccessControlMode mode, {
    required List<String> packages,
  }) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'tun: {}\n';
    final doc = ProfileRulesDocument(raw);
    final String next;
    try {
      if (mode == AccessControlMode.acceptSelected) {
        final included = doc.includedPackages.isNotEmpty
            ? doc.includedPackages
            : packages.where((p) => !doc.excludedPackages.contains(p)).toList();
        final cleared = ProfileRulesDocument(
          doc.withExcludedPackages(const []),
        );
        next = cleared.withIncludedPackages(included);
      } else {
        final excluded = doc.excludedPackages.isNotEmpty
            ? doc.excludedPackages
            : packages.where((p) => !doc.includedPackages.contains(p)).toList();
        final cleared = ProfileRulesDocument(
          doc.withIncludedPackages(const []),
        );
        next = cleared.withExcludedPackages(excluded);
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

  Future<List<GroupSpec>> readProxyGroups(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).proxyGroups;
  }

  /// Live-mirrors the whole `proxy-groups:` block; each group's unknown keys are
  /// preserved (see [GroupSpec]).
  Future<String?> writeProxyGroups(
    int profileId,
    List<GroupSpec> groups,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = ProfileRulesDocument(raw).withProxyGroups(groups);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  Future<Map<String, ProviderSpec>> readProxyProviders(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const {};
    return ProfileRulesDocument(await file.readAsString()).proxyProviders;
  }

  Future<Map<String, ProviderSpec>> readRuleProviders(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const {};
    return ProfileRulesDocument(await file.readAsString()).ruleProviders;
  }

  /// Live-mirrors the whole `proxy-providers:` block (an empty map removes the
  /// key); each provider's unknown keys are preserved (see [ProviderSpec]).
  Future<String?> writeProxyProviders(
    int profileId,
    Map<String, ProviderSpec> providers,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = ProfileRulesDocument(raw).withProxyProviders(providers);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  /// Live-mirrors the whole `rule-providers:` block; same semantics as
  /// [writeProxyProviders].
  Future<String?> writeRuleProviders(
    int profileId,
    Map<String, ProviderSpec> providers,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = ProfileRulesDocument(raw).withRuleProviders(providers);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  Future<List<({String name, String type, String? server})>> readProxyInfos(
    int profileId,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).proxyInfos;
  }

  /// Group/node/provider counts for a profile card stat line, from one read.
  Future<({int groups, int nodes, int providers})> readProfileStats(
    int profileId,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return (groups: 0, nodes: 0, providers: 0);
    final doc = ProfileRulesDocument(await file.readAsString());
    return (
      groups: doc.proxyGroups.length,
      nodes: doc.proxyNames.length,
      providers: doc.proxyProviders.length + doc.ruleProviders.length,
    );
  }

  /// Names a proxy group may legitimately list as members: every declared proxy
  /// plus every other group name.
  Future<List<String>> readGroupMemberCandidates(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    final doc = ProfileRulesDocument(await file.readAsString());
    return [...doc.proxyNames, for (final g in doc.proxyGroups) g.name];
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
