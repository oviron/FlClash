part of '../controller.dart';

/// Bridges the human-language [RoutingModel] to persistence. Reads a profile
/// into the model and writes an edited model back through the same validated
/// hot-apply path the raw editors use, so the constructor and the Advanced
/// editors never diverge (docs/onboarding.md II.9).
extension RoutingConstructorController on AppController {
  Future<RoutingModel> readRoutingModel(int profileId) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) {
      return const RoutingModel(
        exitGroup: quickStartExitGroup,
        lists: [],
        scenarios: [],
        apps: [],
      );
    }
    return RoutingModel.fromYaml(await file.readAsString());
  }

  /// Materializes [model] onto the live profile (rest preserved) and hot-applies
  /// on the active profile. Returns a validation error (file untouched) or null.
  Future<String?> writeRoutingModel(int profileId, RoutingModel model) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = model.toYaml(raw);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    return _writeValidatedApply(file, profileId, next);
  }

  // Validate the candidate config, persist it, and hot-apply when it targets the
  // active profile. Returns a validation error (file untouched) or null.
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
