import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/network_rules_settings.dart';
import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/providers/provider_quota.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/quickstart_verification.dart';
import 'package:fl_clash/providers/vpn_reestablish_signal.dart';
import 'package:fl_clash/services/profile_setup_service.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/services/routing_model.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/common.dart';
import 'database/database.dart';
import 'models/models.dart';
import 'providers/database.dart';

part 'controllers/init_controller.dart';
part 'controllers/state_controller.dart';
part 'controllers/profiles_controller.dart';
part 'controllers/logs_controller.dart';
part 'controllers/proxies_controller.dart';
part 'controllers/setup_controller.dart';
part 'controllers/network_rules_cache_controller.dart';
part 'controllers/core_controller.dart';
part 'controllers/system_controller.dart';
part 'controllers/backup_controller.dart';
part 'controllers/store_controller.dart';
part 'controllers/common_controller.dart';
part 'controllers/app_routing_controller.dart';
part 'controllers/routing_constructor_controller.dart';

class AppController {
  late WidgetRef _ref;
  bool isAttach = false;

  static AppController? _instance;

  AppController._internal();

  factory AppController() {
    _instance ??= AppController._internal();
    return _instance!;
  }

  Future<void> attach(WidgetRef ref) async {
    _ref = ref;
    await _init();
    isAttach = true;
  }
}

// Imperative dispatcher: each extension is a candidate Notifier; migrate
// incrementally starting from the smallest blocks.
final appController = AppController();
