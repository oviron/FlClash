import 'dart:async';

import 'package:fl_clash/controller.dart';
import 'package:fl_clash/library/library_plugin.dart';
import 'package:fl_clash/plugins/service.dart';

// Applies a core-version selection by recycling the :remote process so the new
// .so is loaded by a fresh onCreate. [dir] null means reset to the APK-bundled
// default (clears the active pointer). When [wasRunning] the VPN is gracefully
// stopped before the kill (so no foreground tunnel is orphaned) and restarted
// with the new core. swapInProgress suppresses the kill's disconnect-as-crash.
Future<void> applyLibrarySelection({
  required String label,
  required String? dir,
  required bool wasRunning,
}) async {
  final svc = service;
  if (svc == null) return;
  if (dir == null) {
    await LibraryPlugin.instance.clearActive(label);
  } else {
    await LibraryPlugin.instance.setActive(label, dir);
  }
  if (wasRunning) {
    await appController.updateStatus(false);
  }
  // Only the deliberate kill reads as intentional: a crash of the new core
  // while it starts must still reach the crash handling.
  svc.swapInProgress = true;
  try {
    await svc.requestStop();
    await Future<void>.delayed(const Duration(milliseconds: 500));
  } finally {
    svc.swapInProgress = false;
  }
  // The fresh :remote holds no core state: a plain rebind left initClash
  // unsent and every setupConfig answered "not initialized". Reconnect and
  // init it the way a core restart does, which also restarts the tunnel.
  await appController.restartCore(wasRunning);
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
