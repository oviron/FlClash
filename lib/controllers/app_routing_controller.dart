part of '../controller.dart';

extension AppRoutingController on AppController {
  Future<List<RoutingRule>> readRoutingRules(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return const [];
    return ProfileRulesDocument(await file.readAsString()).rules;
  }

  /// Live-mirrors [rules] into `<id>.yaml` (rest preserved) and hot-applies on
  /// the active profile. Returns a validation error (file untouched) or null.
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
