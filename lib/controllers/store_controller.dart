part of '../controller.dart';

extension StoreControllerExt on AppController {
  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(config);
    });
  }

  Future<void> handleClear() async {
    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    await database.close();
    await File(await appPath.databasePath).safeDelete(recursive: true);
    final homeDir = Directory(await appPath.profilesPath);
    await for (final file in homeDir.list(recursive: true)) {
      await coreController.deleteFile(file.path);
    }
    await preferences.clearPreferences();
    unawaited(handleExit(false));
  }
}
