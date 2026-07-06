part of '../controller.dart';

extension ProfilesControllerExt on AppController {
  Future<void> deleteProfile(int id) async {
    _ref.read(profilesProvider.notifier).del(id);
    unawaited(clearEffect(id));
    final currentProfileId = _ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = _ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        _ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        _ref.read(currentProfileIdProvider.notifier).value = null;
        unawaited(updateStatus(false));
      }
    }
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
    // A local (file) profile embedding xray providers has no URL to re-pull, so
    // the loop above skips it; re-applying re-runs the provider prefetch.
    if (await _currentProfileHasXrayProviders()) {
      applyProfileDebounce(silence: true);
    }
  }

  Future<bool> _currentProfileHasXrayProviders() async {
    final id = _ref.read(currentProfileIdProvider);
    if (id == null) return false;
    try {
      final raw = await File(
        await appPath.getProfilePath(id.toString()),
      ).readAsString();
      return ProfileRulesDocument(
        raw,
      ).proxyProviders.values.any((p) => p.raw['xray'] != null);
    } catch (_) {
      return false;
    }
  }

  void putProfile(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (_ref.read(currentProfileIdProvider) != null) return;
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<String> _readProfileYaml(int profileId) async {
    try {
      return await File(
        await appPath.getProfilePath(profileId.toString()),
      ).readAsString();
    } catch (_) {
      return '';
    }
  }

  // Establish-only ACL guard for the file-rewriting paths outside the routing
  // constructor (raw editor, upload, url re-download, sync): the per-app tun
  // allow/disallow list is baked at establish, so a plain hot-apply never
  // re-applies it. Re-establish when the active profile's package set changed.
  Future<void> _reestablishIfTunChanged(
    int profileId,
    String beforeYaml,
  ) async {
    if (profileId != _ref.read(currentProfileIdProvider)) return;
    final after = await _readProfileYaml(profileId);
    if (tunPackagesChanged(beforeYaml, after)) {
      _ref.read(vpnReestablishSignalProvider.notifier).bump();
    }
  }

  /// Persists new profile bytes (raw editor / upload) and re-establishes the
  /// tunnel when the active profile's app ACL changed.
  Future<void> saveProfileFile(Profile profile, Uint8List bytes) async {
    final before = await _readProfileYaml(profile.id);
    putProfile(await profile.saveFile(bytes));
    await _reestablishIfTunChanged(profile.id, before);
  }

  Future<void> updateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) {
        continue;
      }
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            true;
      }
      final before = await _readProfileYaml(profile.id);
      final newProfile = await profile.update();
      _ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == _ref.read(currentProfileIdProvider)) {
        applyProfileDebounce(silence: true);
        await _reestablishIfTunChanged(profile.id, before);
      }
    } finally {
      _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  String _getLabelFromURL(String url, {int maxLength = 50}) {
    String label;
    try {
      final uri = Uri.parse(url);

      if (uri.queryParameters.containsKey('url')) {
        return _getLabelFromURL(
          uri.queryParameters['url']!,
          maxLength: maxLength,
        );
      }

      final isShortLink =
          (uri.host.split('.').length <= 2 && uri.pathSegments.length <= 2) ||
          url.length < 30;

      if (uri.host.contains('githubusercontent.com') &&
          uri.pathSegments.length > 1) {
        final owner = uri.pathSegments[0];
        final file = uri.pathSegments.last;
        label = '$owner-${file.split('.').first}';
      } else if (isShortLink) {
        label = '${uri.host}-${uri.pathSegments.join('-')}';
      } else if (uri.pathSegments.isNotEmpty) {
        final fileName = uri.pathSegments.last;
        label = '${uri.host}-${fileName.split('.').first}';
      } else {
        label = uri.host;
      }
    } catch (_) {
      label = url
          .replaceAll(RegExp(r'https?://'), '')
          .replaceAll(RegExp(r'[/\?&=]'), '-')
          .replaceAll(RegExp(r'[^0-9a-zA-Z\-_]'), '')
          .replaceAll(RegExp(r'-+'), '-');
    }

    if (label.length > maxLength) {
      label = label.substring(0, maxLength);
    }

    return label;
  }

  Future<void> addProfileFormURL(String url) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      return await Profile.normal(
        url: url,
        label: _getLabelFromURL(url),
      ).update();
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
    }
  }

  /// Single funnel for any pasted/scanned artifact (bare share link, base64
  /// v2ray list, subscription URL, clash YAML). A subscription URL keeps the
  /// existing http/quota path; everything else is converted in-app to a
  /// self-contained config and saved as a local profile.
  Future<void> addProfileFromText(String raw) async {
    final text = raw.trim();
    final kind = classifyArtifact(text);
    if (kind == ArtifactKind.subscriptionUrl) {
      return addProfileFormURL(text);
    }
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      final bytes = await _quickStartBytes(text, kind);
      if (bytes == null) {
        throw appLocalizations.quickStartNoServers;
      }
      return await Profile.normal(
        label: _quickStartLabel(text, kind),
      ).saveFile(bytes);
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
      await _connectAndVerifyQuickStart(profile);
    }
  }

  // Quick-start onboarding: a freshly pasted key auto-connects and the 204
  // honesty gate probes the tunnel, so the user sees a real "verified" (or an
  // honest failure) instead of a green light that never loads a page.
  Future<void> _connectAndVerifyQuickStart(Profile profile) async {
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
    await applyProfile(force: true);
    await updateStatus(true);
    unawaited(_ref.read(quickStartVerificationProvider.notifier).run());
  }

  Future<Uint8List?> _quickStartBytes(String text, ArtifactKind kind) async {
    if (kind == ArtifactKind.clashYaml) {
      return Uint8List.fromList(utf8.encode(text));
    }
    return artifactToConfigBytes(text, kind);
  }

  String _quickStartLabel(String text, ArtifactKind kind) {
    if (kind == ArtifactKind.shareLink) {
      final name = (parseShareLink(text)?['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return appLocalizations.quickStartImported;
  }

  void setProfileAndAutoApply(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == _ref.read(currentProfileIdProvider)) {
      applyProfileDebounce();
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await safeRun(picker.pickerFile);
    final bytes = platformFile?.bytes;
    if (bytes == null) {
      return;
    }
    if (globalState.navigatorKey.currentContext?.mounted != true) return;
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      return await Profile.normal(label: platformFile?.name).saveFile(bytes);
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
    }
  }

  Future<void> addProfileFormQrCode() async {
    final text = await safeRun(picker.pickerConfigQRCode);
    if (text == null) return;
    unawaited(addProfileFromText(text));
  }

  void reorder(List<Profile> profiles) {
    _ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final providersDirPath = await appPath.getProvidersDirPath(
      profileId.toString(),
    );
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    await coreController.deleteFile(providersDirPath);
  }
}
