import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/library/model.dart';
import 'package:fl_clash/plugins/method_names.dart';
import 'package:flutter/services.dart';

// Dart side of the com.follow.clash/library channel (LibraryPlugin.kt, main process).
class LibraryPlugin {
  static final LibraryPlugin instance = LibraryPlugin._();

  LibraryPlugin._();

  final MethodChannel _channel = const MethodChannel('$packageName/library');

  Future<Map<String, int?>> expectedBridgeAbi() async {
    final m =
        await _channel.invokeMapMethod<String, dynamic>(
          LibraryMethod.expectedBridgeAbi,
        ) ??
        const {};
    return m.map((k, v) => MapEntry(k, (v as num?)?.toInt()));
  }

  Future<String> deviceAbi() async =>
      await _channel.invokeMethod<String>(LibraryMethod.deviceAbi) ?? '';

  /// Wrapper version of each core compiled into the APK, keyed by lib label.
  /// Lets the picker mark the bundled core and distinguish it from an update.
  Future<Map<String, String>> bundledVersions() async {
    final m =
        await _channel.invokeMapMethod<String, dynamic>(
          LibraryMethod.bundledVersions,
        ) ??
        const {};
    return m.map((k, v) => MapEntry(k, '$v'));
  }

  Future<List<InstalledLibrary>> listInstalled() async {
    final list =
        await _channel.invokeListMethod<dynamic>(LibraryMethod.listInstalled) ??
        const [];
    return list
        .map(
          (e) => InstalledLibrary.fromMap((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<Map<String, String?>> activeDirs() async {
    final m =
        await _channel.invokeMapMethod<String, dynamic>(
          LibraryMethod.activeDirs,
        ) ??
        const {};
    return m.map((k, v) => MapEntry(k, v as String?));
  }

  // Verifies SHA-256 + GPG, extracts the per-ABI .so. Returns the installed dir.
  Future<String> installFromAar({
    required String aarPath,
    required String ascPath,
    required String sha256,
    required String label,
    required String version,
  }) async {
    final dir = await _channel
        .invokeMethod<String>(LibraryMethod.installFromAar, {
          'aarPath': aarPath,
          'ascPath': ascPath,
          'sha256': sha256,
          'label': label,
          'version': version,
        });
    if (dir == null) throw StateError('installFromAar returned null');
    return dir;
  }

  Future<void> setActive(String label, String dir) => _channel.invokeMethod(
    LibraryMethod.setActive,
    {'label': label, 'dir': dir},
  );

  Future<void> clearActive(String label) =>
      _channel.invokeMethod(LibraryMethod.clearActive, {'label': label});

  Future<bool> deleteInstalled(String dir) async =>
      await _channel.invokeMethod<bool>(LibraryMethod.deleteInstalled, {
        'dir': dir,
      }) ??
      false;
}
