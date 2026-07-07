part of '../controller.dart';

extension GeoControllerExt on AppController {
  // Refreshes every geo database via the core; stamps the freshness timestamp
  // only when at least one succeeded, so a total failure (e.g. an RKN-blocked
  // CDN) retries next launch instead of being suppressed for a whole interval.
  Future<void> updateGeoDatabases() async {
    var anySucceeded = false;
    for (final item in geoItems) {
      try {
        final message = await coreController.updateGeoData(
          UpdateGeoDataParams(geoName: item.fileName, geoType: item.label),
        );
        if (message.isEmpty) {
          anySucceeded = true;
        } else {
          commonPrint.log(
            'geo update ${item.label}: $message',
            logLevel: LogLevel.warning,
          );
        }
      } catch (e) {
        commonPrint.log(
          'geo update ${item.label}: $e',
          logLevel: LogLevel.warning,
        );
      }
    }
    if (anySucceeded) {
      _ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(lastGeoUpdate: DateTime.now()));
    }
  }

  Future<void> autoUpdateGeo() async {
    final setting = _ref.read(appSettingProvider);
    final refresh = shouldRefreshGeo(
      interval: setting.geoUpdateInterval,
      lastGeoUpdate: setting.lastGeoUpdate,
      now: DateTime.now(),
      geoMissing: !(await geositeReady()),
    );
    if (!refresh) return;
    await updateGeoDatabases();
  }
}
