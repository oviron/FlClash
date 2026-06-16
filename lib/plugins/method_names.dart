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
  static const requestStop = 'requestStop';
  // Inbound (Kotlin → Dart)
  static const event = 'event';
  static const crash = 'crash';
}

abstract final class LibraryMethod {
  static const expectedBridgeAbi = 'expectedBridgeAbi';
  static const bundledVersions = 'bundledVersions';
  static const deviceAbi = 'deviceAbi';
  static const listInstalled = 'listInstalled';
  static const activeDirs = 'activeDirs';
  static const installFromAar = 'installFromAar';
  static const setActive = 'setActive';
  static const clearActive = 'clearActive';
  static const deleteInstalled = 'deleteInstalled';
}

abstract final class NetworkRulesMethod {
  static const setEnabled = 'setEnabled';
  static const getStatus = 'getStatus';
  static const reevaluate = 'reevaluate';
  // Inbound (Kotlin → Dart)
  static const statusChanged = 'statusChanged';
  static const switchProfile = 'switchProfile';
}

abstract final class AppMethod {
  static const exit = 'exit';
  static const moveTaskToBack = 'moveTaskToBack';
  static const getPackages = 'getPackages';
  static const getChinaPackageNames = 'getChinaPackageNames';
  static const requestNotificationsPermission =
      'requestNotificationsPermission';
  static const openFile = 'openFile';
  static const getPackageIcon = 'getPackageIcon';
  static const tip = 'tip';
  static const initShortcuts = 'initShortcuts';
  static const updateExcludeFromRecents = 'updateExcludeFromRecents';
  static const isAutoStartEnabled = 'isAutoStartEnabled';
  static const setAutoStartEnabled = 'setAutoStartEnabled';
  static const getLogDirectory = 'getLogDirectory';
}
