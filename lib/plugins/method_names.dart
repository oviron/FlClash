// Shared MethodChannel method-name constants for the Dart→Kotlin bridges.
// Kotlin side: see ServicePlugin.kt and AppPlugin.kt.

abstract final class ServiceMethod {
  static const init = 'init';
  static const shutdown = 'shutdown';
  static const invokeAction = 'invokeAction';
  static const getRunTime = 'getRunTime';
  static const syncState = 'syncState';
  static const start = 'start';
  static const stop = 'stop';
  static const restartByeDpi = 'restartByeDpi';
  // Inbound (Kotlin → Dart)
  static const event = 'event';
  static const crash = 'crash';
}

abstract final class AppMethod {
  static const exit = 'exit';
  static const moveTaskToBack = 'moveTaskToBack';
  static const getPackages = 'getPackages';
  static const getChinaPackageNames = 'getChinaPackageNames';
  static const requestNotificationsPermission = 'requestNotificationsPermission';
  static const openFile = 'openFile';
  static const getPackageIcon = 'getPackageIcon';
  static const tip = 'tip';
  static const initShortcuts = 'initShortcuts';
  static const updateExcludeFromRecents = 'updateExcludeFromRecents';
  static const isAutoStartEnabled = 'isAutoStartEnabled';
  static const setAutoStartEnabled = 'setAutoStartEnabled';
  static const getLogDirectory = 'getLogDirectory';
}
