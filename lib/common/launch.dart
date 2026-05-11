import 'dart:async';
import 'dart:io';

import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    if (system.isDesktop) {
      launchAtStartup.setup(
        appName: appName,
        appPath: Platform.resolvedExecutable,
      );
    }
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  Future<bool> get isEnable async {
    if (system.isDesktop) {
      return await launchAtStartup.isEnabled();
    }
    return (await app?.isAutoStartEnabled()) ?? false;
  }

  Future<bool> enable() async {
    if (system.isDesktop) {
      return await launchAtStartup.enable();
    }
    return (await app?.setAutoStartEnabled(true)) ?? false;
  }

  Future<bool> disable() async {
    if (system.isDesktop) {
      return await launchAtStartup.disable();
    }
    return (await app?.setAutoStartEnabled(false)) ?? false;
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    if (await isEnable == isAutoLaunch) return;
    if (isAutoLaunch == true) {
      unawaited(enable());
    } else {
      unawaited(disable());
    }
  }
}

final autoLaunch = AutoLaunch();
