import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/file.dart';
import 'package:fl_clash/common/string.dart';
import 'package:path/path.dart';

const _providerTypes = {
  'proxy-providers': 'proxies',
  'rule-providers': 'rules',
};
const _sidecar = '.remarks.json';

/// Where an http provider is cached. Every profile shares the cache, keyed by
/// what shapes the file: the request, and for a subscription the app converts
/// (`xray`), the conversion and the provider's name, which its nodes carry.
String providerCachePath(
  String providersPath,
  String type,
  String name,
  Map<Object?, Object?> provider, {
  required Object? userAgent,
}) {
  final xray = provider['xray'];
  final key = json.encode([
    provider['url'],
    provider['header'],
    userAgent,
    // mihomo stores a body cut at the limit; 0 is no limit.
    if (provider['size-limit'] case final limit? when '$limit' != '0') '$limit',
    if (xray != null) ...[xray, name],
  ]);
  return join(providersPath, type, key.toMd5());
}

// Index edits and the sweep run one at a time: two profiles applied at once
// would each sweep by an index missing the other's files.
Future<void> _lock = Future.value();

Future<T> _serial<T>(Future<T> Function() task) {
  final run = _lock.then((_) => task());
  _lock = run.then((_) {}, onError: (_) {});
  return run;
}

// Files of configs still on their way to the core: a sweep meanwhile keeps them.
final _held = <String, int>{};

/// Before a built [config] of [profileId] reaches the core: copies in its
/// files from versions that kept a cache per profile and records the files it
/// uses next to those it used before. Call the result once the config is
/// applied or given up, to end the hold that keeps its files from any sweep.
Future<void Function()> reserveProviderCache(
  String providersPath,
  int profileId,
  Map<String, dynamic> config,
) => _serial(() async {
  final (:used, legacyInUse: _) = await _scan(providersPath, profileId, config);
  for (final path in used) {
    _held[path] = (_held[path] ?? 0) + 1;
  }
  final index = await _readIndex(providersPath);
  index['$profileId'] = {...?index['$profileId'], ...used}.toList();
  await _writeIndex(providersPath, index);
  var done = false;
  return () {
    if (done) return;
    done = true;
    for (final path in used) {
      final left = (_held[path] ?? 1) - 1;
      left > 0 ? _held[path] = left : _held.remove(path);
    }
  };
});

/// Once the core applied [config] of [profileId]: records only the files it
/// uses, drops those no profile in [liveIds] uses, and the profile's folder
/// from versions that kept a cache per profile.
Future<void> claimProviderCache(
  String providersPath,
  int profileId,
  Map<String, dynamic> config,
  Iterable<int> liveIds,
) => _serial(() async {
  final (:used, :legacyInUse) = await _scan(providersPath, profileId, config);
  final index = await _readIndex(providersPath);
  index['$profileId'] = used;
  await _sweep(providersPath, index, liveIds);
  if (!legacyInUse) await _deleteDir(join(providersPath, '$profileId'));
});

/// Forgets a deleted profile's cache files, keeping those another uses.
Future<void> releaseProviderCache(
  String providersPath,
  int profileId,
  Iterable<int> liveIds,
) => _serial(() async {
  final index = await _readIndex(providersPath)
    ..remove('$profileId');
  await _sweep(providersPath, index, liveIds);
  await _deleteDir(join(providersPath, '$profileId'));
});

/// Takes in the cache the other local build of the app handed over in [from],
/// its index included; files only this build used go with the next sweep.
Future<void> importProviderCache(String providersPath, String from) => _serial(
  () async {
    if (!await Directory(from).exists()) return;
    await for (final file in Directory(from).list(recursive: true)) {
      if (file is! File) continue;
      final target = File(join(providersPath, relative(file.path, from: from)));
      await target.parent.create(recursive: true);
      await file.copy(target.path);
    }
  },
);

// The cache files [config] uses, whether a file provider still reads the old
// per-profile folder, and a copy of each old file the shared cache lacks.
Future<({List<String> used, bool legacyInUse})> _scan(
  String providersPath,
  int profileId,
  Map<String, dynamic> config,
) async {
  final legacyDir = join(providersPath, '$profileId');
  // The core resolves a relative path against its home, two levels up.
  final home = dirname(dirname(providersPath));
  final entries = [
    for (final MapEntry(:key, value: type) in _providerTypes.entries)
      if (config[key] case final Map<Object?, Object?> providers)
        for (final provider in providers.values)
          if (provider case final Map<Object?, Object?> provider
              when provider['path'] is String)
            (
              type: type,
              provider: provider,
              path: normalize(join(home, provider['path'] as String)),
            ),
  ];
  for (final (:type, :provider, :path) in entries) {
    if (provider['type'] != 'http' || provider['url'] is! String) continue;
    final legacy = join(legacyDir, type, (provider['url'] as String).toMd5());
    if (await File(path).exists() || !await File(legacy).exists()) continue;
    await File(path).parent.create(recursive: true);
    // A copy: the config the core runs now may still read the old file.
    for (final suffix in ['', _sidecar]) {
      final from = File('$legacy$suffix');
      if (await from.exists()) await from.copy('$path$suffix');
    }
  }
  return (
    // A materialized subscription is a file provider in the cache by now.
    used: [
      for (final (:type, provider: _, :path) in entries)
        if (isWithin(join(providersPath, type), path))
          relative(path, from: providersPath),
    ],
    legacyInUse: entries.any((entry) => isWithin(legacyDir, entry.path)),
  );
}

File _indexFile(String providersPath) =>
    File(join(providersPath, 'index.json'));

// A missing index is a fresh start; an unreadable one throws, as an empty one
// would make the sweep take every other profile's files.
Future<Map<String, List<String>>> _readIndex(String providersPath) async {
  final file = _indexFile(providersPath);
  if (!await file.exists()) return {};
  final decoded = json.decode(await file.readAsString());
  return {
    for (final MapEntry(:key, :value) in (decoded as Map).entries)
      '$key': [for (final path in value as List) '$path'],
  };
}

Future<void> _writeIndex(
  String providersPath,
  Map<String, List<String>> index,
) async {
  await _indexFile(providersPath).parent.create(recursive: true);
  await _indexFile(providersPath).safeWriteAsStringAtomic(json.encode(index));
}

Future<void> _deleteDir(String path) async {
  if (await Directory(path).exists()) {
    await Directory(path).delete(recursive: true);
  }
}

// Only cache files and their sidecars: a `.tmp` of a write still running stays.
final _cacheFile = RegExp(r'^[0-9a-f]{32}(\.remarks\.json)?$');

Future<void> _sweep(
  String providersPath,
  Map<String, List<String>> index,
  Iterable<int> liveIds,
) async {
  index.removeWhere((id, _) => !liveIds.contains(int.tryParse(id)));
  await _writeIndex(providersPath, index);
  final kept = {for (final paths in index.values) ...paths, ..._held.keys};
  for (final type in _providerTypes.values) {
    final dir = Directory(join(providersPath, type));
    if (!await dir.exists()) continue;
    await for (final file in dir.list()) {
      final name = basename(file.path);
      if (file is! File || !_cacheFile.hasMatch(name)) continue;
      if (!kept.contains(join(type, name.substring(0, 32)))) {
        await file.delete();
      }
    }
  }
}
