part of '../controller.dart';

typedef ProfileCacheEntry = ({Map<String, String> selectedMap, String name});

extension NetworkRulesCacheControllerExt on AppController {
  // Bake the final config.yaml for each rule-referenced profile into the dir
  // the resident reads, then return each profile's {selectedMap, name} for the
  // mirror. A profile that fails to build (e.g. deleted) is skipped; stale
  // cache files are pruned so the resident never reads an orphan. Reuses the
  // exact foreground generation path (getProfileWithId + ensureInboundAuth),
  // so a cached profile is byte-identical to one applied live.
  Future<Map<int, ProfileCacheEntry>> rebuildNetworkRulesCache(
    Set<int> profileIds,
  ) async {
    final dir = Directory(await appPath.networkRulesCacheDirPath);
    if (profileIds.isNotEmpty && !dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final entries = <int, ProfileCacheEntry>{};
    for (final id in profileIds) {
      final config = await getProfileWithId(id);
      if (config.isEmpty) {
        continue;
      }
      await ensureInboundAuth(
        config,
        systemProxy: _ref.read(vpnSettingProvider).systemProxy,
      );
      final yamlString = await encodeYamlTask(config);
      await File(
        await appPath.networkRulesCachePath(id),
      ).safeWriteAsString(yamlString);
      final profile = _ref.read(profileProvider(id));
      entries[id] = (
        selectedMap: profile?.selectedMap ?? const {},
        name: profile?.label ?? '$id',
      );
    }
    _pruneNetworkRulesCache(dir, profileIds);
    return entries;
  }

  void _pruneNetworkRulesCache(Directory dir, Set<int> keep) {
    if (!dir.existsSync()) {
      return;
    }
    for (final entity in dir.listSync()) {
      if (entity is! File) {
        continue;
      }
      final name = entity.uri.pathSegments.last;
      final id = name.endsWith('.yaml')
          ? int.tryParse(name.substring(0, name.length - 5))
          : null;
      if (id == null || !keep.contains(id)) {
        try {
          entity.deleteSync();
        } catch (_) {
          // Best-effort prune; a locked/again-missing file is harmless.
        }
      }
    }
  }
}
