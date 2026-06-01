part of '../controller.dart';

extension CommonControllerExt on AppController {
  void toPage(PageLabel pageLabel) {
    _ref.read(currentPageLabelProvider.notifier).value = pageLabel;
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
  }

  void updateStart() {
    updateStatus(!_ref.read(isStartProvider));
  }

  void updateMode() {
    _ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) {
        return null;
      }
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  void updateRunTime() {
    final startTime = globalState.startTime;
    if (startTime != null) {
      final startTimeStamp = startTime.millisecondsSinceEpoch;
      final nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
      final delta = nowTimeStamp - startTimeStamp;
      _ref.read(runTimeProvider.notifier).value = delta;
      if (delta < 1000) {
        commonPrint.log('updateRunTime delta=$delta startTime=$startTime');
      }
    } else {
      commonPrint.log('updateRunTime startTime=null (timer will hide)');
      _ref.read(runTimeProvider.notifier).value = null;
    }
  }

  Future<void> updateTraffic() async {
    final traffic = await coreController.getTraffic();
    _ref.read(trafficsProvider.notifier).addTraffic(traffic);
    _ref.read(totalTrafficProvider.notifier).value = await coreController
        .getTotalTraffic();
  }

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).start();
      },
      onEnd: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).stop();
      },
    );
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    bool silence = true,
    bool rethrowOnError = false,
  }) async {
    try {
      if (onStart != null) {
        onStart();
      }
      final res = await futureFunction();
      return res;
    } catch (e, s) {
      commonPrint.log(
        '$title ===> $e, $s',
        logLevel: rethrowOnError ? LogLevel.error : LogLevel.warning,
      );
      if (silence) {
        globalState.showNotifier(e.toString());
      } else {
        unawaited(
          globalState.showMessage(
            title: title ?? appLocalizations.tip,
            message: TextSpan(text: e.toString()),
          ),
        );
      }
      if (rethrowOnError) rethrow;
      return null;
    } finally {
      if (onEnd != null) {
        onEnd();
      }
    }
  }
}
