import 'package:fl_clash/library/library_plugin.dart';
import 'package:fl_clash/library/model.dart';
import 'package:fl_clash/library/releases_client.dart';
import 'package:fl_clash/library/swap.dart';
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

  Future<void> switchTo(InstalledLibrary lib, {required bool wasRunning}) async {
    await applyLibrarySelection(
      label: lib.label,
      dir: lib.dir,
      wasRunning: wasRunning,
    );
    await gcInstalledLibraries(lib.label);
    ref.invalidate(installedLibrariesProvider);
    ref.invalidate(activeLibraryDirsProvider);
  }

  Future<void> resetToBundled(String label, {required bool wasRunning}) async {
    await applyLibrarySelection(label: label, dir: null, wasRunning: wasRunning);
    ref.invalidate(activeLibraryDirsProvider);
  }

  Future<void> delete(InstalledLibrary lib) async {
    await LibraryPlugin.instance.deleteInstalled(lib.dir);
    ref.invalidate(installedLibrariesProvider);
  }
}
