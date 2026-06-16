bool shouldScheduleVpnReestablish({
  required bool isStarted,
  required Object currentVpnState,
  required Object? lastVpnState,
}) {
  return isStarted && currentVpnState != lastVpnState;
}

bool shouldRunVpnReestablish({
  required bool isStarted,
  required bool forceReestablish,
  required Object currentVpnState,
  required Object? lastVpnState,
}) {
  if (forceReestablish) return isStarted;
  return shouldScheduleVpnReestablish(
    isStarted: isStarted,
    currentVpnState: currentVpnState,
    lastVpnState: lastVpnState,
  );
}
