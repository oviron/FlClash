import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/method_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App {
  static App? _instance;
  late MethodChannel methodChannel;
  Function()? onExit;

  App._internal() {
    methodChannel = const MethodChannel('$packageName/app');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case AppMethod.exit:
          if (onExit != null) {
            await onExit!();
          }
        default:
          throw MissingPluginException();
      }
    });
  }

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<bool?> moveTaskToBack() async {
    return await methodChannel.invokeMethod<bool>(AppMethod.moveTaskToBack);
  }

  Future<List<Package>> getPackages() async {
    final packagesString = await methodChannel.invokeMethod<String>(
      AppMethod.getPackages,
    );
    final List<dynamic> packagesRaw =
        (await packagesString?.commonToJSON<List<dynamic>>()) ?? [];
    return packagesRaw.map((e) => Package.fromJson(e)).toSet().toList();
  }

  Future<List<String>> getChinaPackageNames() async {
    final packageNamesString = await methodChannel.invokeMethod<String>(
      AppMethod.getChinaPackageNames,
    );
    final List<dynamic> packageNamesRaw =
        await packageNamesString?.commonToJSON<List<dynamic>>() ?? [];
    return packageNamesRaw.map((e) => e.toString()).toList();
  }

  Future<bool?> requestNotificationsPermission() async {
    return await methodChannel.invokeMethod<bool>(
      AppMethod.requestNotificationsPermission,
    );
  }

  Future<bool> openFile(String path) async {
    return await methodChannel.invokeMethod<bool>(AppMethod.openFile, {
          'path': path,
        }) ??
        false;
  }

  Future<ImageProvider?> getPackageIcon(String packageName) async {
    final path = await methodChannel.invokeMethod<String>(
      AppMethod.getPackageIcon,
      {'packageName': packageName},
    );
    if (path == null) {
      return null;
    }
    return FileImage(File(path));
  }

  Future<bool?> tip(String? message) async {
    return await methodChannel.invokeMethod<bool>(AppMethod.tip, {
      'message': '$message',
    });
  }

  Future<bool?> initShortcuts() async {
    return await methodChannel.invokeMethod<bool>(
      AppMethod.initShortcuts,
      appLocalizations.toggle,
    );
  }

  Future<bool?> updateExcludeFromRecents(bool value) async {
    return await methodChannel.invokeMethod<bool>(
      AppMethod.updateExcludeFromRecents,
      {'value': value},
    );
  }

  Future<bool?> isAutoStartEnabled() {
    return methodChannel.invokeMethod<bool>(AppMethod.isAutoStartEnabled);
  }

  Future<bool?> setAutoStartEnabled(bool enabled) {
    return methodChannel.invokeMethod<bool>(
      AppMethod.setAutoStartEnabled,
      enabled,
    );
  }

  Future<String?> getLogDirectory() async {
    return await methodChannel.invokeMethod<String>(AppMethod.getLogDirectory);
  }
}

final app = system.isAndroid ? App() : null;
