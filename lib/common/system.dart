import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/services.dart';

class System {
  static System? _instance;

  System._internal();

  factory System() {
    _instance ??= System._internal();
    return _instance!;
  }

  bool get isAndroid => Platform.isAndroid;

  Future<int> get version async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    if (Platform.isAndroid) {
      return (deviceInfo as AndroidDeviceInfo).version.sdkInt;
    }
    return 0;
  }

  Future<void> back() async {
    await app?.moveTaskToBack();
  }

  Future<void> exit() async {
    if (isAndroid) {
      await SystemNavigator.pop();
    }
  }
}

final system = System();
