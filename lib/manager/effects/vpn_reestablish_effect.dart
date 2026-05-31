bool shouldScheduleVpnReestablish({
  required bool isStarted,
  required Object currentVpnState,
  required Object? lastVpnState,
  bool isReestablishing = false,
}) {
  return isStarted && !isReestablishing && currentVpnState != lastVpnState;
}

bool shouldRunVpnReestablish({
  required bool isStarted,
  required bool forceReestablish,
  required Object currentVpnState,
  required Object? lastVpnState,
  bool isReestablishing = false,
}) {
  if (forceReestablish) return isStarted && !isReestablishing;
  return shouldScheduleVpnReestablish(
    isStarted: isStarted,
    currentVpnState: currentVpnState,
    lastVpnState: lastVpnState,
    isReestablishing: isReestablishing,
  );
}

bool shouldReestablishVpnForByeDpiToggle({
  required bool isStarted,
  required bool? previousEnabled,
  required bool nextEnabled,
}) {
  return isStarted && previousEnabled != null && previousEnabled != nextEnabled;
}
