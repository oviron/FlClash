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
  }

  void putProfile(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (_ref.read(currentProfileIdProvider) != null) return;
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
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
      final newProfile = await profile.update();
      _ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == _ref.read(currentProfileIdProvider)) {
        applyProfileDebounce(silence: true);
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
    final url = await safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFormURL(url));
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
