part of '../controller.dart';

extension SetupControllerExt on AppController {
  void fullSetup() {
    if (!_ref.read(initProvider)) {
      return;
    }
    _ref.read(delayDataSourceProvider.notifier).value = {};
    applyProfile(force: true);
    _ref.read(logsProvider.notifier).value = FixedList(500);
    _ref.read(requestsProvider.notifier).value = FixedList(500);
  }

  Future<void> updateStatus(bool isStart, {bool isInit = false}) async {
    if (isStart) {
      if (!isInit) {
        final res = await tryStartCore(true);
        if (res) {
          return;
        }
        if (!_ref.read(initProvider)) {
          return;
        }
        await globalState.handleStart([updateRunTime, updateTraffic]);
        applyProfileDebounce(force: true, silence: true);
      } else {
        globalState.needInitStatus = false;
        await applyProfile(
          force: true,
          preloadInvoke: () async {
            await globalState.handleStart([updateRunTime, updateTraffic]);
          },
        );
      }
    } else {
      await globalState.handleStop();
      coreController.resetTraffic();
      _ref.read(trafficsProvider.notifier).clear();
      _ref.read(totalTrafficProvider.notifier).value = const Traffic();
      _ref.read(runTimeProvider.notifier).value = null;
      addCheckIp();
    }
  }

  Future<bool> needSetup() async {
    final profileId = _ref.read(currentProfileIdProvider);
    if (profileId == null) {
      return false;
    }
    final setupState = await _ref.read(setupStateProvider(profileId).future);
    return setupState.needSetup(globalState.lastSetupState) == true;
  }

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, () async {
      await safeRun(() async {
        final updateParams = _ref.read(updateParamsProvider);
        final res = await _requestAdmin(updateParams.tun.enable);
        if (res.isError) {
          return;
        }
        final realTunEnable = _ref.read(realTunEnableProvider);
        final message = await coreController.updateConfig(
          updateParams.copyWith.tun(enable: realTunEnable),
        );
        if (message.isNotEmpty) throw message;
      });
    });
  }

  void addCheckIp() {
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void tryCheckIp() {
    final isTimeout = _ref.read(
      networkDetectionProvider.select(
        (state) => state.ipInfo == null && state.isLoading == false,
      ),
    );
    if (!isTimeout) {
      return;
    }
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    debouncer.call(FunctionTag.applyProfile, (silence, force) {
      applyProfile(silence: silence, force: force);
    }, args: [silence, force]);
  }

  void changeMode(Mode mode) {
    _ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      updateCurrentGroupName(GroupName.GLOBAL.name);
    }
    addCheckIp();
  }

  void autoApplyProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyProfile();
    });
  }

  Future<void> applyProfile({
    bool silence = false,
    bool force = false,
    VoidCallback? preloadInvoke,
  }) async {
    if (!force && !await needSetup()) {
      return;
    }
    await loadingRun(
      () async {
        await _setupConfig(preloadInvoke);
        await updateGroups();
        await updateProviders();
      },
      silence: true,
      tag: !silence ? LoadingTag.proxies : null,
    );
  }

  Future<Map<String, dynamic>> getProfile({
    required SetupState setupState,
    required ClashConfig patchConfig,
  }) async {
    if (setupState.profileId == null) {
      return {};
    }
    final networkVM2 = _ref.read(
      networkSettingProvider.select(
        (state) => VM2(state.appendSystemDns, state.routeMode),
      ),
    );
    final overrideDns = _ref.read(overrideDnsProvider);
    final appendSystemDns = networkVM2.a;
    final routeMode = networkVM2.b;
    final service = ProfileSetupService(
      loadRawProfile: coreController.getConfig,
      evaluateScript: globalState.handleEvaluate,
      loadScriptContent: (script) => script.content,
    );
    return service.buildConfig(
      ProfileSetupRequest(
        setupState: setupState,
        patchConfig: patchConfig,
        routeMode: routeMode,
        overrideDns: overrideDns,
        appendSystemDns: appendSystemDns,
        profilesPath: await appPath.profilesPath,
        defaultUserAgent: globalState.packageInfo.ua,
      ),
    );
  }

  Future<Map<String, dynamic>> getProfileWithId(int profileId) async {
    var res = <String, dynamic>{};
    try {
      final setupState = await _ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = _ref.read(patchClashConfigProvider);
      res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
    } catch (e) {
      globalState.showNotifier(e.toString());
    }
    return res;
  }

  Future<void> _setupConfig([VoidCallback? preloadInvoke]) async {
    commonPrint.log('setup ===>');
    var profile = _ref.read(currentProfileProvider);
    final nextProfile = await profile?.checkAndUpdateAndCopy();
    if (nextProfile != null) {
      profile = nextProfile;
      _ref.read(profilesProvider.notifier).put(nextProfile);
    }
    final patchConfig = _ref.read(patchClashConfigProvider);
    final res = await _requestAdmin(patchConfig.tun.enable);
    if (res.isError) {
      return;
    }
    final realTunEnable = _ref.read(realTunEnableProvider);
    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    final setupState = await _ref.read(setupStateProvider(profile?.id).future);
    globalState.lastSetupState = setupState;
    if (system.isAndroid) {
      // Per-app ACL is off-graph (getConfig) and baked only at establish; resolve
      // it before snapshotting sharedState, or a just-edited (invalidated) set
      // reads a stale `.value` and the tunnel re-establishes with the old list.
      await _ref.read(effectiveAccessControlProvider.future);
      globalState.lastVpnState = _ref.read(vpnStateProvider);
      unawaited(preferences.saveShareState(this.sharedState));
    }
    final config = await getProfile(
      setupState: setupState,
      patchConfig: realPatchConfig,
    );
    await ensureInboundAuth(config);
    await _prefetchXrayProviders(config, profile);
    final configFilePath = await appPath.configFilePath;
    final yamlString = await encodeYamlTask(config);
    await File(configFilePath).safeWriteAsStringAtomic(yamlString);
    final selectedMap = _ref.read(selectedMapProvider);
    final testUrl = _ref.read(
      appSettingProvider.select((state) => state.testUrl),
    );
    final message = await coreController.setupConfig(
      setupState: setupState,
      params: SetupParams(selectedMap: selectedMap, testUrl: testUrl),
      preloadInvoke: preloadInvoke,
    );
    if (message.isNotEmpty) {
      final lower = message.toLowerCase();
      final geoWarning =
          lower.contains('geosite data error') ||
          lower.contains('geoip data error') ||
          (lower.contains('decode') && lower.contains('geo'));
      if (!geoWarning) throw message;
      // A GeoSite/GeoIP rule couldn't resolve (missing/stale/corrupt database);
      // the rest of the config still applied, so heal the geo data in the
      // background instead of alarming the user with the raw core error.
      commonPrint.log(
        'geo data warning on setup: $message',
        logLevel: LogLevel.warning,
      );
      unawaited(seedGeositeIfMissing().then((_) => updateGeoDatabases()));
    }
    addCheckIp();
  }

  // Happ/xray proxy-providers can't be fetched by the core (it can't parse
  // xray-JSON). Detect them from the on-disk profile (the runtime map may be
  // core-stripped), fetch+convert here, write a `proxies:` file, and flip the
  // provider to `type: file` so the core just reads it. Markers never reach it.
  Future<void> _prefetchXrayProviders(
    Map<String, dynamic> config,
    Profile? profile,
  ) async {
    if (profile == null) return;
    final providers = config['proxy-providers'];
    if (providers is! Map || providers.isEmpty) return;

    final String rawYaml;
    try {
      rawYaml = await File(
        await appPath.getProfilePath(profile.id.toString()),
      ).readAsString();
    } catch (_) {
      return;
    }
    final onDisk = ProfileRulesDocument(rawYaml).proxyProviders;
    final keys = onDisk.keys
        .where(
          (k) => onDisk[k]!.raw['xray'] != null && providers.containsKey(k),
        )
        .toList();
    if (keys.isEmpty) return;

    // Single-writer group injection: mutating the shared config['proxy-groups']
    // concurrently would race, so collect per-provider remarks and inject after.
    final injects = await Future.wait(
      keys.map(
        (k) =>
            _prefetchOneXrayProvider(providers[k], onDisk[k]!, k, profile.id),
      ),
    );
    for (final inj in injects) {
      if (inj != null) injectRemarkGroups(config, inj.key, inj.remarks);
    }
  }

  Future<({String key, List<RemarkGroup> remarks})?> _prefetchOneXrayProvider(
    dynamic entry,
    ProviderSpec spec,
    String key,
    int profileId,
  ) async {
    if (entry is! Map) return null;
    final path = (entry['path'] ?? spec.path)?.toString();
    if (path == null) return null;

    final buckets = <String, List<String>>{};
    var fingerprint = 'upstream';
    var dropUnmatched = false;
    final xray = spec.raw['xray'];
    final byRemark = xray is Map && '${xray['groups'] ?? ''}' == 'by-remark';
    if (xray is Map) {
      final b = xray['buckets'];
      if (b is Map) {
        b.forEach((k, v) {
          if (v is List) buckets['$k'] = v.map((e) => '$e').toList();
        });
      }
      if (xray['fingerprint'] != null) fingerprint = '${xray['fingerprint']}';
      dropUnmatched = xray['drop-unmatched'] == true;
    }

    final base = <String, String>{};
    final rawHeader = spec.raw['header'];
    if (rawHeader is Map) {
      rawHeader.forEach((k, v) {
        base['$k'] = v is List && v.isNotEmpty ? '${v.first}' : '$v';
      });
    }
    final headers = await happHeaders(base: base);

    var proxies = const <Map<String, dynamic>>[];
    var remarks = const <RemarkGroup>[];
    final url = spec.url;
    if (url != null && url.isNotEmpty) {
      try {
        final resp = await request.getTextResponseForUrl(url, headers: headers);
        final userinfo = resp.headers.value('subscription-userinfo');
        if (userinfo != null) {
          _ref
              .read(providerQuotaProvider.notifier)
              .set(profileId, key, SubscriptionInfo.formHString(userinfo));
        }
        if (byRemark) {
          final slugged = slugXrayGroups(
            resp.data ?? '',
            key,
            fingerprint: fingerprint,
          );
          proxies = slugged.proxies;
          remarks = slugged.remarks;
        } else {
          proxies = parseXrayJson(
            resp.data ?? '',
            prefix: key,
            buckets: buckets,
            fingerprint: fingerprint,
            dropUnmatched: dropUnmatched,
          );
        }
      } catch (e) {
        commonPrint.log('xray provider $key fetch failed: $e');
      }
    }

    final file = File(path);
    final metaFile = File('$path.remarks.json');
    if (proxies.isNotEmpty) {
      await file.safeWriteAsStringAtomic(
        await encodeYamlTask({'proxies': proxies}),
      );
      if (byRemark) {
        // Config is rebuilt each apply; persist the group descriptors so a later
        // apply whose fetch fails restores them from cache instead of reverting
        // Go to a flat list (mirrors the node sidecar's cache failover).
        await metaFile.safeWriteAsStringAtomic(
          jsonEncode([
            for (final r in remarks)
              {'label': r.label, 'slug': r.slug, 'count': r.count},
          ]),
        );
      }
    } else if (!await file.exists()) {
      // First fetch failed with no cache: write a valid empty provider (never a
      // dangling path) and surface the failure rather than a silent empty group.
      await file.safeWriteAsStringAtomic('proxies: []\n');
      globalState.showNotifier('$key: ${appLocalizations.networkException}');
    } // else: upstream unreachable but a cache exists -> serve it (failover).

    // Failed/empty by-remark fetch but a cached sidecar exists: recover the
    // remark descriptors from the meta cache so the grouping survives.
    if (byRemark && remarks.isEmpty) {
      remarks = await _readCachedRemarks(metaFile);
    }

    entry['type'] = 'file';
    entry
      ..remove('url')
      ..remove('proxy')
      ..remove('header')
      ..remove('xray')
      ..remove('format');

    return remarks.isEmpty ? null : (key: key, remarks: remarks);
  }

  Future<List<RemarkGroup>> _readCachedRemarks(File metaFile) async {
    try {
      final decoded = jsonDecode(await metaFile.readAsString());
      if (decoded is! List) return const [];
      return [
        for (final e in decoded)
          if (e is Map)
            (
              label: '${e['label']}',
              slug: '${e['slug']}',
              count: (e['count'] as num?)?.toInt() ?? 0,
            ),
      ];
    } catch (_) {
      return const [];
    }
  }
}
