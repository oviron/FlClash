part of '../controller.dart';

extension ProxiesControllerExt on AppController {
  void updateGroupsDebounce([Duration? duration]) {
    debouncer.call(FunctionTag.updateGroups, updateGroups, duration: duration);
  }

  void changeProxyDebounce(String groupName, String proxyName) {
    debouncer.call(FunctionTag.changeProxy, (
      String groupName,
      String proxyName,
    ) async {
      await changeProxy(groupName: groupName, proxyName: proxyName);
      updateGroupsDebounce();
    }, args: [groupName, proxyName]);
  }

  Future<void> updateGroups() async {
    try {
      commonPrint.log('updateGroups');
      _ref.read(groupsProvider.notifier).value = await retry(
        task: () async {
          final sortType = _ref.read(
            proxiesStyleSettingProvider.select((state) => state.sortType),
          );
          final delayMap = _ref.read(delayDataSourceProvider);
          final testUrl = _ref.read(
            appSettingProvider.select((state) => state.testUrl),
          );
          final selectedMap = _ref.read(
            currentProfileProvider.select((state) => state?.selectedMap ?? {}),
          );
          return await coreController.getProxiesGroups(
            selectedMap: selectedMap,
            sortType: sortType,
            delayMap: delayMap,
            defaultTestUrl: testUrl,
          );
        },
        retryIf: (res) => res.isEmpty,
      );
    } catch (e) {
      commonPrint.log('updateGroups error: $e');
      _ref.read(groupsProvider.notifier).value = [];
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      _ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(currentProfile.copyWith(unfoldSet: value));
  }

  void setDelay(Delay delay) {
    _ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await coreController.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (_ref.read(appSettingProvider).closeConnections) {
      coreController.closeAllConnections();
    } else {
      coreController.resetConnections();
    }
    addCheckIp();
  }

  // Computed-selected group: tapping the active node clears the pin (toggle
  // off). Returns false (with a notice) for a group whose selection is fixed.
  bool selectGroupMember({
    required String groupName,
    required String proxyName,
    required GroupType groupType,
  }) {
    final isComputedSelected = groupType.isComputedSelected;
    if (!isComputedSelected && groupType != GroupType.Selector) {
      globalState.showNotifier(appLocalizations.notSelectedTip);
      return false;
    }
    final current = _ref.read(getProxyNameProvider(groupName));
    final next = isComputedSelected
        ? (current == proxyName ? '' : proxyName)
        : proxyName;
    updateCurrentSelectedMap(groupName, next);
    changeProxyDebounce(groupName, next);
    return true;
  }

  void setProvider(ExternalProvider? provider) {
    _ref.read(providersProvider.notifier).setProvider(provider);
  }

  Future<void> updateProviders() async {
    _ref.read(providersProvider.notifier).value = await coreController
        .getExternalProviders();
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        _ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
            true;
      }
      final message = await coreController.updateExternalProvider(
        name: provider.name,
        type: provider.type,
      );
      if (message.isNotEmpty) return message;
      setProvider(
        await coreController.getExternalProvider(provider.name, provider.type),
      );
      return '';
    } finally {
      _ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
          false;
    }
  }

  int addSortNum() {
    return _ref.read(sortNumProvider.notifier).add();
  }
}
