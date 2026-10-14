import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/plugins/method_names.dart';
import 'package:flutter/services.dart';

/// The other local build of the app (release or dev) and its data.
class Transfer {
  final MethodChannel _channel = const MethodChannel('$packageName/transfer');

  Transfer._();

  static final Transfer instance = Transfer._();

  /// The other build's name, if it is installed and signed by us.
  Future<String?> sibling() =>
      _channel.invokeMethod<String>(TransferMethod.sibling);

  /// Writes the other build's data archive to [path]; false if the user
  /// declined there.
  Future<bool> pull(String path) async =>
      await _channel.invokeMethod<bool>(TransferMethod.pull, path) ?? false;
}

final transfer = system.isAndroid ? Transfer.instance : null;
