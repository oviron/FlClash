part of '../controller.dart';

extension GeoControllerExt on AppController {
  /// Refreshes every geo database via the core and records the timestamp.
  /// Best-effort: a failing file is logged and skipped, others still update.
  Future<void> updateGeoDatabases() async {
    for (final (label, fileName) in geoFileItems) {
      try {
        await coreController.updateGeoData(
          UpdateGeoDataParams(geoName: fileName, geoType: label),
        );
      } catch (e) {
        commonPrint.log('geo update $label: $e', logLevel: LogLevel.warning);
      }
    }
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(lastGeoUpdate: DateTime.now()));
  }

  /// Startup background geo refresh, gated by [shouldRefreshGeo]: heals a
  /// missing database and honours the user's chosen interval.
  Future<void> autoUpdateGeo() async {
    final setting = _ref.read(appSettingProvider);
    final refresh = shouldRefreshGeo(
      interval: setting.geoUpdateInterval,
      lastGeoUpdate: setting.lastGeoUpdate,
      now: DateTime.now(),
      geoMissing: (await loadGeositeCategories()).isEmpty,
    );
    if (!refresh) return;
    await updateGeoDatabases();
  }
}
