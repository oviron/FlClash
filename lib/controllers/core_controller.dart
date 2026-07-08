part of '../controller.dart';

extension CoreControllerExt on AppController {
  Future<void> _initCore() async {
    final isInit = await coreController.isInit;
    final version = _ref.read(versionProvider);
    if (!isInit) {
      await coreController.init(version);
    } else {
      await updateGroups();
    }
  }

  Future<void> _connectCore() async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final result = await Future.wait([
      coreController.preload(),
      Future.delayed(const Duration(milliseconds: 300)),
    ]);
    final String message = result[0];
    if (message.isNotEmpty) {
      _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      final ctx = globalState.navigatorKey.currentContext;
      if (ctx?.mounted == true) {
        ctx!.showNotifier(message);
      }
      return;
    }
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  }

  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    _ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> restartCore([bool start = false]) async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await coreController.shutdown(true);
    clearDelay();
    await _connectCore();
    await _initCore();
    if (start || _ref.read(isStartProvider)) {
      await updateStatus(true, isInit: true);
    } else {
      await applyProfile(force: true);
    }
  }

  Future<bool> tryStartCore([bool start = false]) async {
    if (coreController.isCompleted) {
      return false;
    }
    await restartCore(start);
    return true;
  }

  void handleCoreDisconnected() {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
  }
}
