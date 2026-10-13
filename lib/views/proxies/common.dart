import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight + 2;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 6,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final groups = appController.groups;
  final selectedMap = appController.currentProfile?.selectedMap ?? {};
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.takeFirstValid([
    appController.getRealTestUrl(testUrl),
  ]);
  final delayTestUrl = getDelayTestUrl(
    proxyName: state.proxyName,
    testUrl: currentTestUrl,
  );
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(
    Delay(url: delayTestUrl, name: state.proxyName, value: 0),
  );
  globalState.delayTests++;
  try {
    appController.setDelay(
      await coreController.getDelay(delayTestUrl, state.proxyName),
    );
  } finally {
    globalState.delayTests--;
  }
}

/// Tests [groups] the way the core picks: one round for the whole tree, after
/// which an unpinned url-test group already sits on its fastest member.
Future<void> groupsDelayTest(List<Group> groups) async {
  if (groups.isEmpty) return;
  final allGroups = appController.groups;
  final selectedMap = appController.currentProfile?.selectedMap ?? {};
  final pending = <Delay>{};
  for (final group in groups) {
    for (final proxy in group.all) {
      final state = computeRealSelectedProxyState(
        proxy.name,
        groups: allGroups,
        selectedMap: selectedMap,
      );
      if (state.proxyName.isEmpty) continue;
      final url = state.testUrl.takeFirstValid([
        appController.getRealTestUrl(group.testUrl),
      ]);
      pending.add(
        Delay(
          name: state.proxyName,
          url: getDelayTestUrl(proxyName: state.proxyName, testUrl: url),
          value: 0,
        ),
      );
    }
  }
  appController.setDelays(pending);
  globalState.delayTests++;
  try {
    final results = await coreController
        .testGroups(
          groups.map((group) => group.name).toList(),
          appController.getRealTestUrl(null),
        )
        .catchError((e) {
          commonPrint.log('testGroups failed: $e', logLevel: LogLevel.warning);
          return const <Delay>[];
        });
    appController.setDelays(settleDelays(pending: pending, results: results));
    await appController.updateGroups();
  } finally {
    globalState.delayTests--;
  }
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final columns = appController.getProxiesColumns();
  final proxyCardType = appController.config.proxiesStyleProps.cardType;
  final selectedProxyName = appController.getSelectedProxyName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
