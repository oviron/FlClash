import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppPath {
  static AppPath? _instance;
  late final Future<Directory> _dataDir = getApplicationSupportDirectory();
  late final Future<Directory?> _downloadDir = getDownloadsDirectory();
  late final Future<Directory> _tempDir = getTemporaryDirectory();

  AppPath._internal();

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  String get executableExtension => '';

  String get executableDirPath {
    final currentExecutablePath = Platform.resolvedExecutable;
    return dirname(currentExecutablePath);
  }

  String get corePath {
    return join(executableDirPath, 'FlClashCore$executableExtension');
  }

  Future<String?> get downloadDirPath async {
    final directory = await _downloadDir;
    return directory?.path;
  }

  Future<String> get homeDirPath async {
    final directory = await _dataDir;
    return directory.path;
  }

  Future<String> get databasePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'database.sqlite');
  }

  Future<String> get backupFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'backup.zip');
  }

  Future<String> get restoreDirPath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'restore');
  }

  Future<String> get tempFilePath async {
    final mTempDir = await _tempDir;
    return join(mTempDir.path, 'temp${utils.id}');
  }

  Future<String> get lockFilePath async {
    final homeDirPath = await appPath.homeDirPath;
    return join(homeDirPath, 'FlClash.lock');
  }

  Future<String> get configFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'config.yaml');
  }

  Future<String> get networkRulesCacheDirPath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'network-rules-cache');
  }

  Future<String> networkRulesCachePath(int profileId) async {
    final dir = await networkRulesCacheDirPath;
    return join(dir, '$profileId.yaml');
  }

  Future<String> get sharedPreferencesPath async {
    final directory = await _dataDir;
    return join(directory.path, 'shared_preferences.json');
  }

  Future<String> get profilesPath async {
    final directory = await _dataDir;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String> getProfilePath(String fileName) async {
    return join(await profilesPath, '$fileName.yaml');
  }

  Future<String> get scriptsDirPath async {
    final path = await homeDirPath;
    return join(path, 'scripts');
  }

  Future<String> getScriptPath(String fileName) async {
    final path = await scriptsDirPath;
    return join(path, '$fileName.js');
  }

  Future<String> getProvidersRootPath() async {
    final directory = await profilesPath;
    return join(directory, 'providers');
  }

  Future<String> getProvidersDirPath(String id) async {
    final directory = await profilesPath;
    return join(directory, 'providers', id);
  }
}

final appPath = AppPath();
