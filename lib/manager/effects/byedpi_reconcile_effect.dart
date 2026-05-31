import 'package:fl_clash/byedpi/model.dart';

class ByeDpiReconcileRequest {
  final bool core;
  final bool engine;

  const ByeDpiReconcileRequest({required this.core, required this.engine});

  static const none = ByeDpiReconcileRequest(core: false, engine: false);

  bool get isEmpty => !core && !engine;
}

ByeDpiReconcileRequest byeDpiSettingsReconcileRequest(
  ByeDpiSettings? previous,
  ByeDpiSettings next,
) {
  if (previous == null) {
    return ByeDpiReconcileRequest.none;
  }
  return ByeDpiReconcileRequest(
    core:
        previous.enabled != next.enabled ||
        previous.mode != next.mode ||
        previous.fallbackEnabled != next.fallbackEnabled ||
        previous.fallbackGroup != next.fallbackGroup ||
        previous.port != next.port,
    engine:
        previous.enabled != next.enabled ||
        previous.port != next.port ||
        previous.preset != next.preset ||
        previous.cliArgs != next.cliArgs,
  );
}
