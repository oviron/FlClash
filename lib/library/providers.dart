import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/library/library_plugin.dart';
import 'package:fl_clash/library/model.dart';
import 'package:fl_clash/library/releases_client.dart';
import 'package:fl_clash/library/swap.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final libraryExpectedAbiProvider = FutureProvider<Map<String, int?>>(
  (ref) => LibraryPlugin.instance.expectedBridgeAbi(),
);

final libraryDeviceAbiProvider = FutureProvider<String>(
  (ref) => LibraryPlugin.instance.deviceAbi(),
);

final libraryBundledVersionsProvider = FutureProvider<Map<String, String>>(
  (ref) => LibraryPlugin.instance.bundledVersions(),
);

final installedLibrariesProvider = FutureProvider<List<InstalledLibrary>>(
  (ref) => LibraryPlugin.instance.listInstalled(),
);

final activeLibraryDirsProvider = FutureProvider<Map<String, String?>>(
  (ref) => LibraryPlugin.instance.activeDirs(),
);

// Re-read on each connect: a swap or a crash brings up a new :remote.
final runningCoreProvider = FutureProvider<RunningCore?>((ref) async {
  final connected = ref.watch(
    coreStatusProvider.select((s) => s == CoreStatus.connected),
  );
  if (!connected) return null;
  return LibraryPlugin.instance.runningCore();
});

final libraryReleasesProvider =
    FutureProvider.family<List<LibraryRelease>, String>(
      (ref, label) => ReleasesClient().fetch(label),
    );

final libraryControllerProvider = NotifierProvider<LibraryController, void>(
  LibraryController.new,
);

class LibraryController extends Notifier<void> {
  @override
  void build() {}

  Future<void> downloadAndInstall(LibraryRelease rel) async {
    final tmp = (await getTemporaryDirectory()).path;
    final files = await ReleasesClient().download(rel, tmp);
    await LibraryPlugin.instance.installFromAar(
      aarPath: files.aar,
      ascPath: files.asc,
      sha256: rel.sha256,
      label: rel.label,
      version: rel.version,
    );
    ref.invalidate(installedLibrariesProvider);
  }

  // Throws when the new :remote does not run the selected core, so the
  // picker reports it instead of showing the selection as done.
  Future<void> switchTo(
    InstalledLibrary lib, {
    required bool wasRunning,
  }) async {
    await applyLibrarySelection(
      label: lib.label,
      dir: lib.dir,
      wasRunning: wasRunning,
    );
    await gcInstalledLibraries(lib.label);
    ref.invalidate(installedLibrariesProvider);
    ref.invalidate(activeLibraryDirsProvider);
    ref.invalidate(runningCoreProvider);
    final running = await ref.read(runningCoreProvider.future);
    if (running?.source != RunningCoreSource.selected) {
      final failure = running?.loadFailure;
      throw failure != null
          ? '${appLocalizations.libLoadFailed(failure.version)}: ${failure.reason}'
          : appLocalizations.libNotAttached(libVersionFromDir(lib.dir));
    }
  }

  Future<void> resetToBundled(String label, {required bool wasRunning}) async {
    await applyLibrarySelection(
      label: label,
      dir: null,
      wasRunning: wasRunning,
    );
    ref.invalidate(activeLibraryDirsProvider);
    ref.invalidate(runningCoreProvider);
  }

  Future<void> dismissLoadFailure(String label) async {
    await LibraryPlugin.instance.clearLoadFailure(label);
    ref.invalidate(runningCoreProvider);
  }

  Future<void> delete(InstalledLibrary lib) async {
    await LibraryPlugin.instance.deleteInstalled(lib.dir);
    ref.invalidate(installedLibrariesProvider);
  }
}
