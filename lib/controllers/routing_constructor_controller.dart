part of '../controller.dart';

// Constructor and Advanced editors share one validated hot-apply write path so
// they never diverge (docs/onboarding.md II.9).
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

  // Materializes [model] onto the live profile (rest preserved) and hot-applies
  // on the active profile. Returns a validation error (file untouched) or null.
  Future<String?> writeRoutingModel(int profileId, RoutingModel model) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    final raw = await file.exists() ? await file.readAsString() : 'rules: []\n';
    final String next;
    try {
      next = model.toYaml(raw);
    } on ProfileRulesWriteException catch (e) {
      return e.message;
    }
    final error = await _writeValidatedApply(file, profileId, next);
    if (error == null) _signalTunAclChanged(profileId, raw, next);
    return error;
  }

  // Establish-only ACL: the tunnel bakes the allow/disallow list at establish, a
  // hot-apply never re-applies it, and effectiveAccessControl reads YAML
  // off-graph -> invalidate it and re-establish on an active-profile tun change.
  void _signalTunAclChanged(int profileId, String before, String after) {
    if (profileId != _ref.read(currentProfileIdProvider)) return;
    if (!tunPackagesChanged(before, after)) return;
    _ref.invalidate(effectiveAccessControlProvider);
    _ref.read(vpnReestablishSignalProvider.notifier).bump();
  }

  // Switches tunnel mode, preserving each mode's app selection via the
  // per-profile stash so passing through `all` never loses a list. Returns a
  // validation error (nothing persisted) or null.
  Future<String?> applyTunnelModeSwitch(
    int profileId,
    TunnelMode newMode,
  ) async {
    final current = await readRoutingModel(profileId);
    if (current.tunnelMode == newMode) return null;
    final stash =
        _ref.read(profilesProvider).getProfile(profileId)?.appFilterStash ??
        const AppFilterStash();
    final result = switchTunnelMode(
      current: current,
      stashInclude: stash.include,
      stashExclude: stash.exclude,
      newMode: newMode,
    );
    final error = await writeRoutingModel(profileId, result.model);
    if (error != null) return error;
    _ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (p) => p.copyWith(
            appFilterStash: AppFilterStash(
              include: result.stashInclude,
              exclude: result.stashExclude,
            ),
          ),
        );
    return null;
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
