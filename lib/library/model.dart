const kLibMihomo = 'mihomo';

String repoFor(String label) => 'oviron/libmihomo-android';

// A wrapper release as advertised by its metadata.json GitHub release asset.
class LibraryRelease {
  final String label; // mihomo (the wrapper repo)
  final String version; // wrapper tag without leading v, e.g. "0.1.4"
  final String coreName;
  final String coreVersion; // bundled core, e.g. v1.19.26
  final int bridgeAbi;
  final List<String> abis;
  final String aarUrl;
  final String ascUrl;
  final String sha256;

  const LibraryRelease({
    required this.label,
    required this.version,
    required this.coreName,
    required this.coreVersion,
    required this.bridgeAbi,
    required this.abis,
    required this.aarUrl,
    required this.ascUrl,
    required this.sha256,
  });

  bool compatibleWith({required int? expectedAbi, required String deviceAbi}) =>
      expectedAbi != null &&
      bridgeAbi == expectedAbi &&
      abis.contains(deviceAbi);
}

class InstalledLibrary {
  final String label;
  final String version;
  final String dir;
  final int sizeBytes;

  const InstalledLibrary({
    required this.label,
    required this.version,
    required this.dir,
    required this.sizeBytes,
  });

  factory InstalledLibrary.fromMap(Map<String, dynamic> m) => InstalledLibrary(
    label: m['label'] as String,
    version: m['version'] as String,
    dir: m['dir'] as String,
    sizeBytes: (m['sizeBytes'] as num?)?.toInt() ?? 0,
  );
}

// Where the core that answers JNI calls in :remote comes from (LoadedCore.kt).
enum RunningCoreSource { selected, bundled, unknown }

class RunningCore {
  final String? selectedDir; // dir the loader used; null = the APK copy
  final List<String>
  cores; // per mapped libclash.so: selected, bundled or a dir

  const RunningCore({required this.selectedDir, required this.cores});

  factory RunningCore.fromMap(Map<String, dynamic> m) => RunningCore(
    selectedDir: m['selected'] as String?,
    cores: (m['cores'] as List? ?? const []).map((e) => '$e').toList(),
  );

  // Two mapped copies mean the selected libclash.so has no DT_SONAME: it
  // loaded, but libmihomo-jni.so bound to the APK copy by name.
  RunningCoreSource get source {
    if (cores.contains('bundled')) return RunningCoreSource.bundled;
    if (cores.length == 1 && cores.single == 'selected') {
      return RunningCoreSource.selected;
    }
    return RunningCoreSource.unknown;
  }

  bool get selectionFailed =>
      selectedDir != null && source != RunningCoreSource.selected;
}

// filesDir/libs/<label>-v<version> → v<version>.
String libVersionFromDir(String dir) {
  final name = dir.split('/').last;
  final sep = name.indexOf('-v');
  return sep > 0 ? 'v${name.substring(sep + 2)}' : name;
}
