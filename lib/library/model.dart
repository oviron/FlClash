const kLibMihomo = 'mihomo';
const kLibByedpi = 'byedpi';

String repoFor(String label) => label == kLibMihomo
    ? 'oviron/libmihomo-android'
    : 'oviron/libbyedpi-android';

// A wrapper release as advertised by its metadata.json GitHub release asset.
class LibraryRelease {
  final String label; // mihomo | byedpi (the wrapper repo)
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
