import 'dart:async';

import 'package:fl_clash/controller.dart';
import 'package:fl_clash/library/library_plugin.dart';
import 'package:fl_clash/plugins/service.dart';

// Applies a core-version selection by recycling the :remote process so the new
// .so is loaded by a fresh onCreate. [dir] null means reset to the APK-bundled
// default (clears the active pointer). When [wasRunning] the VPN is gracefully
// stopped before the kill (so no foreground tunnel is orphaned) and restarted
// after the rebind. swapInProgress suppresses the kill's disconnect-as-crash.
Future<void> applyLibrarySelection({
  required String label,
  required String? dir,
  required bool wasRunning,
}) async {
  final svc = service;
  if (svc == null) return;
  svc.swapInProgress = true;
  try {
    if (dir == null) {
      await LibraryPlugin.instance.clearActive(label);
    } else {
      await LibraryPlugin.instance.setActive(label, dir);
    }
    if (wasRunning) {
      await appController.updateStatus(false);
    }
    await svc.requestStop();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Rebind to a fresh :remote; init() awaits the new connection internally.
    await svc.init();
    if (wasRunning) {
      await appController.updateStatus(true);
    }
  } finally {
    svc.swapInProgress = false;
  }
}

// Keeps the [keep] newest installed versions per label plus the active one;
// deletes the rest. The APK-bundled default lives outside filesDir/libs and is
// never touched, so a reset target always survives.
Future<void> gcInstalledLibraries(String label, {int keep = 2}) async {
  final plugin = LibraryPlugin.instance;
  final installed =
      (await plugin.listInstalled()).where((e) => e.label == label).toList()
        ..sort((a, b) => _compareVersion(b.version, a.version));
  final active = (await plugin.activeDirs())[label];
  final keepers = <String>{if (active != null) active};
  for (final e in installed) {
    if (keepers.length >= keep) break;
    keepers.add(e.dir);
  }
  for (final e in installed) {
    if (!keepers.contains(e.dir)) {
      await plugin.deleteInstalled(e.dir);
    }
  }
}

int _compareVersion(String a, String b) {
  final pa = a.split('.');
  final pb = b.split('.');
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final d = (int.tryParse(pa[i]) ?? 0).compareTo(int.tryParse(pb[i]) ?? 0);
    if (d != 0) return d;
  }
  return pa.length.compareTo(pb.length);
}
