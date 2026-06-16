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
}
