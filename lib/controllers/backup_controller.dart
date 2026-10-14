part of '../controller.dart';

extension BackupControllerExt on AppController {
  Future<void> shakingStore() async {
    final profileIds = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.id)),
    );
    final scriptIds = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.id),
      ),
    );
    await _deleteStoreFilesExcept(profileIds, scriptIds);
  }

  Future<void> _deleteStoreFilesExcept(
    Iterable<int> profileIds,
    Iterable<int> scriptIds,
  ) async {
    final pathsToDelete = await shakingProfileTask(VM2(profileIds, scriptIds));
    await Future.wait(
      pathsToDelete.map((path) async {
        final res = await coreController.deleteFile(path);
        if (res.isNotEmpty) throw res;
      }),
    );
  }

  Future<String> backup() async {
    final profileFileNames = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.fileName)),
    );
    final scriptFileNames = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.fileName),
      ),
    );
    final configMap = _ref.read(configProvider).toJson();
    configMap['version'] = await preferences.getVersion();
    final includeDavCreds = _ref.read(
      appSettingProvider.select((state) => state.includeDavCredsInBackup),
    );
    if (!includeDavCreds) {
      final davProps = configMap['davProps'];
      if (davProps is Map<String, Object?>) {
        davProps['user'] = '';
        davProps['password'] = '';
      }
    }
    return await backupTask(configMap, [
      ...profileFileNames,
      ...scriptFileNames,
    ]);
  }

  /// Replaces all of this build's data with the other local build's; false
  /// if the user declined there.
  Future<bool> transferFromSibling() async {
    final archive = File(await appPath.backupFilePath);
    try {
      if (await transfer?.pull(archive.path) != true) return false;
      await restore(RestoreOption.all, fromSibling: true);
      return true;
    } finally {
      await archive.safeDelete();
    }
  }

  Future<void> restore(RestoreOption option, {bool fromSibling = false}) async {
    final restoreDirPath = await appPath.restoreDirPath;
    final restoreDir = Directory(restoreDirPath);
    final restoreStrategy = _ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride =
        fromSibling || restoreStrategy == RestoreStrategy.override;
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw appLocalizations.restoreException;
      }
      if (fromSibling) await _importTransferExtras(restoreDirPath);
      await database.restore(
        migrationData.profiles,
        migrationData.scripts,
        migrationData.rules,
        migrationData.links,
        isOverride: isOverride,
        networkRules: migrationData.networkRules,
      );
      if (fromSibling) {
        // The files of the profiles and scripts the transfer replaced.
        await _deleteStoreFilesExcept(
          migrationData.profiles.map((item) => item.id),
          migrationData.scripts.map((item) => item.id),
        );
      }
      final configMap = migrationData.configMap;
      if (option == RestoreOption.onlyProfiles || configMap == null) {
        return;
      }
      migrateBackupConfig(configMap);
      final config = Config.fromJson(configMap);
      _ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
      _ref.read(appSettingProvider.notifier).value = config.appSettingProps;
      _ref.read(currentProfileIdProvider.notifier).value =
          config.currentProfileId;
      _ref.read(davSettingProvider.notifier).value = config.davProps;
      _ref.read(themeSettingProvider.notifier).value = config.themeProps;
      _ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
      _ref.read(proxiesStyleSettingProvider.notifier).value =
          config.proxiesStyleProps;
      _ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
      _ref.read(networkSettingProvider.notifier).value = config.networkProps;
      _ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      _ref.read(networkRulesSettingsProvider.notifier).value =
          config.networkRulesProps;
      return;
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }

  // What a backup leaves out: device values, Geo databases and the provider
  // cache, taken in before the restored config is applied so nothing is fetched.
  Future<void> _importTransferExtras(String restoreDirPath) async {
    final extras = File(join(restoreDirPath, 'transfer.json'));
    if (await extras.exists()) {
      final data = json.decode(await extras.readAsString());
      if (data case {'prefs': final Map<String, Object?> prefs}) {
        await preferences.importTransferred(prefs);
      }
    }
    final home = await appPath.homeDirPath;
    for (final name in [MMDB, ASN, GEOIP, GEOSITE]) {
      final file = File(join(restoreDirPath, name));
      if (!await file.exists()) continue;
      // A rename keeps the copy the core has mapped intact until it reloads.
      final copy = await file.copy(join(home, '$name.transfer'));
      await copy.rename(join(home, name));
    }
    await importProviderCache(
      await appPath.getProvidersRootPath(),
      join(restoreDirPath, profilesDirectoryName, 'providers'),
    );
  }
}
