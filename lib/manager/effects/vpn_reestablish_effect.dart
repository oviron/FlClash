bool shouldScheduleVpnReestablish({
  required bool isStarted,
  required Object currentVpnState,
  required Object? lastVpnState,
  bool isReestablishing = false,
}) {
  return isStarted && !isReestablishing && currentVpnState != lastVpnState;
}

bool shouldReestablishVpnForByeDpiToggle({
  required bool isStarted,
  required bool? previousEnabled,
  required bool nextEnabled,
}) {
  return isStarted && previousEnabled != null && previousEnabled != nextEnabled;
}
