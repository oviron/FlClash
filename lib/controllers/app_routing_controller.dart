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
    final error = await coreController.validateConfigWithData(next);
    if (error.isNotEmpty) return error;
    await file.safeWriteAsString(next);
    if (profileId == _ref.read(currentProfileIdProvider)) {
      await applyProfile(force: true);
    }
    return null;
  }

  Future<List<String>> readExcludedPackages(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).excludedPackages;
  }

  /// Atomically sets an app's routing target and tunnel membership in one
  /// read-modify-write-apply. [outOfTunnel] true adds the app to
  /// tun.exclude-package and drops any PROCESS-NAME rule for it (it would be
  /// dead). A null/empty [target] leaves no routing rule. The routing part
  /// hot-applies; the tunnel part takes effect on the next VPN restart.
  Future<String?> setAppRouting(
    int profileId,
    String packageName, {
    String? target,
    required bool outOfTunnel,
  }) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final doc = ProfileRulesDocument(raw);

    final rules = doc.rules
        .where(
          (r) =>
              !(r is TypedRule &&
                  r.action == RuleAction.PROCESS_NAME &&
                  r.value == packageName),
        )
        .toList();
    if (!outOfTunnel && target != null && target.isNotEmpty) {
      rules.insert(
        0,
        TypedRule(
          action: RuleAction.PROCESS_NAME,
          value: packageName,
          target: target,
        ),
      );
    }

    final excluded = doc.excludedPackages.toList()..remove(packageName);
    if (outOfTunnel) excluded.insert(0, packageName);

    final String next;
    try {
      next = ProfileRulesDocument(
        doc.withRules(rules),
      ).withExcludedPackages(excluded);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    final error = await coreController.validateConfigWithData(next);
    if (error.isNotEmpty) return error;
    await file.safeWriteAsString(next);
    if (profileId == _ref.read(currentProfileIdProvider)) {
      await applyProfile(force: true);
    }
    return null;
  }
}
