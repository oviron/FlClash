part of '../controller.dart';

extension InitControllerExt on AppController {
  Future<void> _init() async {
    FlutterError.onError = (details) {
      commonPrint.log(
        'exception: ${details.exception} stack: ${details.stack}',
        logLevel: LogLevel.warning,
      );
    };
    unawaited(autoUpdateProfiles());
    await _handleFailedPreference();
    await _handlerDisclaimer();
    await _connectCore();
    await seedGeositeIfMissing();
    await _initCore();
    await _initStatus();
    unawaited(autoUpdateGeo());
    _ref.read(initProvider.notifier).value = true;
  }

  Future<void> _handleFailedPreference() async {
    if (await preferences.isInit) {
      return;
    }
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    await handleExit();
  }

  Future<bool> showDisclaimer() async {
    return await globalState.showCommonDialog<bool>(
          dismissible: false,
          child: CommonDialog(
            title: appLocalizations.disclaimer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    globalState.navigatorKey.currentContext!,
                  ).pop<bool>(false);
                },
                child: Text(appLocalizations.exit),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    globalState.navigatorKey.currentContext!,
                  ).pop<bool>(true);
                },
                child: Text(appLocalizations.agree),
              ),
            ],
            child: Text(appLocalizations.disclaimerDesc),
          ),
        ) ??
        false;
  }

  Future<void> _handlerDisclaimer() async {
    if (_ref.read(
      appSettingProvider.select((state) => state.disclaimerAccepted),
    )) {
      return;
    }
    final isDisclaimerAccepted = await showDisclaimer();
    if (!isDisclaimerAccepted) {
      await handleExit();
    }
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(disclaimerAccepted: true));
    return;
  }

  Future<void> _initStatus() async {
    if (!globalState.needInitStatus) {
      commonPrint.log('init status cancel');
      return;
    }
    commonPrint.log('init status');
    if (system.isAndroid) {
      await globalState.updateStartTime();
    }
    final status = globalState.isStart == true
        ? true
        : _ref.read(appSettingProvider).autoRun;
    if (status == true) {
      await updateStatus(true, isInit: true);
    } else {
      await applyProfile(force: true);
    }
  }
}
