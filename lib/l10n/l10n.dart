// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `IPv6`
  String get ipv6 {
    return Intl.message('IPv6', name: 'ipv6', desc: '', args: []);
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Engine`
  String get engine {
    return Intl.message('Engine', name: 'engine', desc: '', args: []);
  }

  /// `VPN settings`
  String get vpnSettings {
    return Intl.message(
      'VPN settings',
      name: 'vpnSettings',
      desc: '',
      args: [],
    );
  }

  /// `Routing rules`
  String get routingRules {
    return Intl.message(
      'Routing rules',
      name: 'routingRules',
      desc: '',
      args: [],
    );
  }

  /// `Ports, IPv6, hosts, find-process, geodata loader, test URL`
  String get coreDesc {
    return Intl.message(
      'Ports, IPv6, hosts, find-process, geodata loader, test URL',
      name: 'coreDesc',
      desc: '',
      args: [],
    );
  }

  /// `Behavior`
  String get dnsBehaviorSection {
    return Intl.message(
      'Behavior',
      name: 'dnsBehaviorSection',
      desc: '',
      args: [],
    );
  }

  /// `Launch & background`
  String get launchAndBackground {
    return Intl.message(
      'Launch & background',
      name: 'launchAndBackground',
      desc: '',
      args: [],
    );
  }

  /// `User interface`
  String get userInterface {
    return Intl.message(
      'User interface',
      name: 'userInterface',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get resetSection {
    return Intl.message('Reset', name: 'resetSection', desc: '', args: []);
  }

  /// `Privacy & Security`
  String get privacyAndSecurity {
    return Intl.message(
      'Privacy & Security',
      name: 'privacyAndSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Adds a Developer screen with diagnostic actions.`
  String get developerModeDesc {
    return Intl.message(
      'Adds a Developer screen with diagnostic actions.',
      name: 'developerModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Crash reporting`
  String get crashReporting {
    return Intl.message(
      'Crash reporting',
      name: 'crashReporting',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Not used in Bypass private mode`
  String get routeAddressBypassPrivateHint {
    return Intl.message(
      'Not used in Bypass private mode',
      name: 'routeAddressBypassPrivateHint',
      desc: '',
      args: [],
    );
  }

  /// `Delete WebDAV configuration?`
  String get confirmDeleteWebDAV {
    return Intl.message(
      'Delete WebDAV configuration?',
      name: 'confirmDeleteWebDAV',
      desc: '',
      args: [],
    );
  }

  /// `Prefer H3`
  String get preferH3 {
    return Intl.message('Prefer H3', name: 'preferH3', desc: '', args: []);
  }

  /// `VPN`
  String get vpn {
    return Intl.message('VPN', name: 'vpn', desc: '', args: []);
  }

  /// `Hosts`
  String get hosts {
    return Intl.message('Hosts', name: 'hosts', desc: '', args: []);
  }

  /// `Rule`
  String get rule {
    return Intl.message('Rule', name: 'rule', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Proxies`
  String get proxies {
    return Intl.message('Proxies', name: 'proxies', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Profiles`
  String get profiles {
    return Intl.message('Profiles', name: 'profiles', desc: '', args: []);
  }

  /// `Tools`
  String get tools {
    return Intl.message('Tools', name: 'tools', desc: '', args: []);
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Resources`
  String get resources {
    return Intl.message('Resources', name: 'resources', desc: '', args: []);
  }

  /// `Traffic usage`
  String get trafficUsage {
    return Intl.message(
      'Traffic usage',
      name: 'trafficUsage',
      desc: '',
      args: [],
    );
  }

  /// `Network speed`
  String get networkSpeed {
    return Intl.message(
      'Network speed',
      name: 'networkSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Outbound mode`
  String get outboundMode {
    return Intl.message(
      'Outbound mode',
      name: 'outboundMode',
      desc: '',
      args: [],
    );
  }

  /// `Network detection`
  String get networkDetection {
    return Intl.message(
      'Network detection',
      name: 'networkDetection',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `No profile, Please add a profile`
  String get nullProfileDesc {
    return Intl.message(
      'No profile, Please add a profile',
      name: 'nullProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Default`
  String get defaultText {
    return Intl.message('Default', name: 'defaultText', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `English`
  String get en {
    return Intl.message('English', name: 'en', desc: '', args: []);
  }

  /// `Japanese`
  String get ja {
    return Intl.message('Japanese', name: 'ja', desc: '', args: []);
  }

  /// `Russian`
  String get ru {
    return Intl.message('Russian', name: 'ru', desc: '', args: []);
  }

  /// `Simplified Chinese`
  String get zh_CN {
    return Intl.message(
      'Simplified Chinese',
      name: 'zh_CN',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Set dark mode,adjust the color`
  String get themeDesc {
    return Intl.message(
      'Set dark mode,adjust the color',
      name: 'themeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Override`
  String get override {
    return Intl.message('Override', name: 'override', desc: '', args: []);
  }

  /// `AllowLan`
  String get allowLan {
    return Intl.message('AllowLan', name: 'allowLan', desc: '', args: []);
  }

  /// `Allow access proxy through the LAN`
  String get allowLanDesc {
    return Intl.message(
      'Allow access proxy through the LAN',
      name: 'allowLanDesc',
      desc: '',
      args: [],
    );
  }

  /// `Minimize instead of exit`
  String get minimizeOnExit {
    return Intl.message(
      'Minimize instead of exit',
      name: 'minimizeOnExit',
      desc: '',
      args: [],
    );
  }

  /// `Back button sends the app to background instead of closing it`
  String get minimizeOnExitDesc {
    return Intl.message(
      'Back button sends the app to background instead of closing it',
      name: 'minimizeOnExitDesc',
      desc: '',
      args: [],
    );
  }

  /// `Connect on app open`
  String get autoRun {
    return Intl.message(
      'Connect on app open',
      name: 'autoRun',
      desc: '',
      args: [],
    );
  }

  /// `Tunnel comes up immediately when the app is launched`
  String get autoRunDesc {
    return Intl.message(
      'Tunnel comes up immediately when the app is launched',
      name: 'autoRunDesc',
      desc: '',
      args: [],
    );
  }

  /// `In-app log buffer`
  String get inAppLogBuffer {
    return Intl.message(
      'In-app log buffer',
      name: 'inAppLogBuffer',
      desc: '',
      args: [],
    );
  }

  /// `Keep recent events in the Logs view (internal buffer, separate from adb logcat)`
  String get inAppLogBufferDesc {
    return Intl.message(
      'Keep recent events in the Logs view (internal buffer, separate from adb logcat)',
      name: 'inAppLogBufferDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logging`
  String get loggingTitle {
    return Intl.message('Logging', name: 'loggingTitle', desc: '', args: []);
  }

  /// `Logcat verbosity, file sink, in-app buffer`
  String get loggingDesc {
    return Intl.message(
      'Logcat verbosity, file sink, in-app buffer',
      name: 'loggingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Quick Settings tile`
  String get quickTileTitle {
    return Intl.message(
      'Quick Settings tile',
      name: 'quickTileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a FlClash toggle next to the flashlight`
  String get quickTileDesc {
    return Intl.message(
      'Add a FlClash toggle next to the flashlight',
      name: 'quickTileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Tile is in Quick Settings`
  String get quickTileAdded {
    return Intl.message(
      'Tile is in Quick Settings',
      name: 'quickTileAdded',
      desc: '',
      args: [],
    );
  }

  /// `Tile was not added`
  String get quickTileNotAdded {
    return Intl.message(
      'Tile was not added',
      name: 'quickTileNotAdded',
      desc: '',
      args: [],
    );
  }

  /// `Add it from the Quick Settings editor: pull the shade down fully, tap the pencil, drag FlClash in`
  String get quickTileManual {
    return Intl.message(
      'Add it from the Quick Settings editor: pull the shade down fully, tap the pencil, drag FlClash in',
      name: 'quickTileManual',
      desc: '',
      args: [],
    );
  }

  /// `Collapse Quick Settings after tap`
  String get quickTileCollapsePanel {
    return Intl.message(
      'Collapse Quick Settings after tap',
      name: 'quickTileCollapsePanel',
      desc: '',
      args: [],
    );
  }

  /// `Turn off to toggle the tile without closing the panel`
  String get quickTileCollapsePanelDesc {
    return Intl.message(
      'Turn off to toggle the tile without closing the panel',
      name: 'quickTileCollapsePanelDesc',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Resource usage`
  String get resourceUsageTitle {
    return Intl.message(
      'Resource usage',
      name: 'resourceUsageTitle',
      desc: '',
      args: [],
    );
  }

  /// `CPU, wake lock and traffic this app actually used`
  String get resourceUsageDesc {
    return Intl.message(
      'CPU, wake lock and traffic this app actually used',
      name: 'resourceUsageDesc',
      desc: '',
      args: [],
    );
  }

  /// `Since this connection`
  String get resourceUsageSinceConnect {
    return Intl.message(
      'Since this connection',
      name: 'resourceUsageSinceConnect',
      desc: '',
      args: [],
    );
  }

  /// `Since device boot`
  String get resourceUsageSinceBoot {
    return Intl.message(
      'Since device boot',
      name: 'resourceUsageSinceBoot',
      desc: '',
      args: [],
    );
  }

  /// `The system did not return usage data for this app.`
  String get resourceUsageUnavailable {
    return Intl.message(
      'The system did not return usage data for this app.',
      name: 'resourceUsageUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `CPU time`
  String get resourceUsageCpu {
    return Intl.message(
      'CPU time',
      name: 'resourceUsageCpu',
      desc: '',
      args: [],
    );
  }

  /// `Wake lock`
  String get resourceUsageWakeLock {
    return Intl.message(
      'Wake lock',
      name: 'resourceUsageWakeLock',
      desc: '',
      args: [],
    );
  }

  /// `Held only while the screen is on, released in Doze`
  String get resourceUsageWakeLockDesc {
    return Intl.message(
      'Held only while the screen is on, released in Doze',
      name: 'resourceUsageWakeLockDesc',
      desc: '',
      args: [],
    );
  }

  /// `Traffic`
  String get resourceUsageTraffic {
    return Intl.message(
      'Traffic',
      name: 'resourceUsageTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi and mobile, as billed to this app`
  String get resourceUsageTrafficDesc {
    return Intl.message(
      'Wi-Fi and mobile, as billed to this app',
      name: 'resourceUsageTrafficDesc',
      desc: '',
      args: [],
    );
  }

  /// `Measured window`
  String get resourceUsageWindow {
    return Intl.message(
      'Measured window',
      name: 'resourceUsageWindow',
      desc: '',
      args: [],
    );
  }

  /// `Time on battery this report covers`
  String get resourceUsageWindowDesc {
    return Intl.message(
      'Time on battery this report covers',
      name: 'resourceUsageWindowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Android's battery screen shows little for a VPN: tunnelled traffic is billed to the app that originated it, not to the tunnel, and this app releases its wake lock once the screen goes off. The numbers here come from the system's own per-app counters.`
  String get resourceUsageExplainer {
    return Intl.message(
      'Android\'s battery screen shows little for a VPN: tunnelled traffic is billed to the app that originated it, not to the tunnel, and this app releases its wake lock once the screen goes off. The numbers here come from the system\'s own per-app counters.',
      name: 'resourceUsageExplainer',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get loggingSourceSection {
    return Intl.message(
      'Source',
      name: 'loggingSourceSection',
      desc: '',
      args: [],
    );
  }

  /// `Source log level`
  String get loggingSourceLevel {
    return Intl.message(
      'Source log level',
      name: 'loggingSourceLevel',
      desc: '',
      args: [],
    );
  }

  /// `Maximum verbosity mihomo emits. Per-sink filters below cannot raise above this.`
  String get loggingSourceLevelDesc {
    return Intl.message(
      'Maximum verbosity mihomo emits. Per-sink filters below cannot raise above this.',
      name: 'loggingSourceLevelDesc',
      desc: '',
      args: [],
    );
  }

  /// `Android logcat (adb)`
  String get loggingLogcatSection {
    return Intl.message(
      'Android logcat (adb)',
      name: 'loggingLogcatSection',
      desc: '',
      args: [],
    );
  }

  /// `Logcat level`
  String get loggingLogcatLevel {
    return Intl.message(
      'Logcat level',
      name: 'loggingLogcatLevel',
      desc: '',
      args: [],
    );
  }

  /// `Filter for the always-on logcat sink. View via: adb logcat -s libclash:V libclash-stderr:V proxy:V FlClash:V flutter:V`
  String get loggingLogcatLevelDesc {
    return Intl.message(
      'Filter for the always-on logcat sink. View via: adb logcat -s libclash:V libclash-stderr:V proxy:V FlClash:V flutter:V',
      name: 'loggingLogcatLevelDesc',
      desc: '',
      args: [],
    );
  }

  /// `Persistent file`
  String get loggingFileSection {
    return Intl.message(
      'Persistent file',
      name: 'loggingFileSection',
      desc: '',
      args: [],
    );
  }

  /// `Write log file`
  String get loggingFileEnabled {
    return Intl.message(
      'Write log file',
      name: 'loggingFileEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Append events to a rotated file under the app's external dir`
  String get loggingFileEnabledDesc {
    return Intl.message(
      'Append events to a rotated file under the app\'s external dir',
      name: 'loggingFileEnabledDesc',
      desc: '',
      args: [],
    );
  }

  /// `File level`
  String get loggingFileLevel {
    return Intl.message(
      'File level',
      name: 'loggingFileLevel',
      desc: '',
      args: [],
    );
  }

  /// `Filter for the persistent file sink`
  String get loggingFileLevelDesc {
    return Intl.message(
      'Filter for the persistent file sink',
      name: 'loggingFileLevelDesc',
      desc: '',
      args: [],
    );
  }

  /// `File path`
  String get loggingFilePathLabel {
    return Intl.message(
      'File path',
      name: 'loggingFilePathLabel',
      desc: '',
      args: [],
    );
  }

  /// `Rotates at 5 MB, keeps 5 files (.log + .1 .. .4)`
  String get loggingFileRotationHint {
    return Intl.message(
      'Rotates at 5 MB, keeps 5 files (.log + .1 .. .4)',
      name: 'loggingFileRotationHint',
      desc: '',
      args: [],
    );
  }

  /// `In-app viewer`
  String get loggingInAppSection {
    return Intl.message(
      'In-app viewer',
      name: 'loggingInAppSection',
      desc: '',
      args: [],
    );
  }

  /// `Open log viewer`
  String get loggingOpenViewer {
    return Intl.message(
      'Open log viewer',
      name: 'loggingOpenViewer',
      desc: '',
      args: [],
    );
  }

  /// `ADB tip: adb pull <file path> to fetch the log to your machine without root`
  String get loggingHintAdb {
    return Intl.message(
      'ADB tip: adb pull <file path> to fetch the log to your machine without root',
      name: 'loggingHintAdb',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message('Application', name: 'application', desc: '', args: []);
  }

  /// `Modify application related settings`
  String get applicationDesc {
    return Intl.message(
      'Modify application related settings',
      name: 'applicationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message('Advanced', name: 'advanced', desc: '', args: []);
  }

  /// `Details`
  String get detailsSection {
    return Intl.message('Details', name: 'detailsSection', desc: '', args: []);
  }

  /// `Diagnostics`
  String get diagnostics {
    return Intl.message('Diagnostics', name: 'diagnostics', desc: '', args: []);
  }

  /// `Core`
  String get dnsCoreSection {
    return Intl.message('Core', name: 'dnsCoreSection', desc: '', args: []);
  }

  /// `Servers`
  String get dnsServersSection {
    return Intl.message(
      'Servers',
      name: 'dnsServersSection',
      desc: '',
      args: [],
    );
  }

  /// `Fake-IP`
  String get dnsFakeIpSection {
    return Intl.message(
      'Fake-IP',
      name: 'dnsFakeIpSection',
      desc: '',
      args: [],
    );
  }

  /// `Geo databases`
  String get geoDatabases {
    return Intl.message(
      'Geo databases',
      name: 'geoDatabases',
      desc: '',
      args: [],
    );
  }

  /// `GeoIP, GeoSite, MMDB, ASN updaters`
  String get geoDatabasesDesc {
    return Intl.message(
      'GeoIP, GeoSite, MMDB, ASN updaters',
      name: 'geoDatabasesDesc',
      desc: '',
      args: [],
    );
  }

  /// `General settings`
  String get generalSettings {
    return Intl.message(
      'General settings',
      name: 'generalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Legal & disclaimer`
  String get legalAndDisclaimer {
    return Intl.message(
      'Legal & disclaimer',
      name: 'legalAndDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `QR code`
  String get qrcode {
    return Intl.message('QR code', name: 'qrcode', desc: '', args: []);
  }

  /// `Scan QR code to obtain profile`
  String get qrcodeDesc {
    return Intl.message(
      'Scan QR code to obtain profile',
      name: 'qrcodeDesc',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get url {
    return Intl.message('URL', name: 'url', desc: '', args: []);
  }

  /// `Obtain profile through URL`
  String get urlDesc {
    return Intl.message(
      'Obtain profile through URL',
      name: 'urlDesc',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Directly upload profile`
  String get fileDesc {
    return Intl.message(
      'Directly upload profile',
      name: 'fileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Please input the profile name`
  String get profileNameNullValidationDesc {
    return Intl.message(
      'Please input the profile name',
      name: 'profileNameNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input the profile URL`
  String get profileUrlNullValidationDesc {
    return Intl.message(
      'Please input the profile URL',
      name: 'profileUrlNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input a valid profile URL`
  String get profileUrlInvalidValidationDesc {
    return Intl.message(
      'Please input a valid profile URL',
      name: 'profileUrlInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto update`
  String get autoUpdate {
    return Intl.message('Auto update', name: 'autoUpdate', desc: '', args: []);
  }

  /// `No available proxies`
  String get noProxy {
    return Intl.message(
      'No available proxies',
      name: 'noProxy',
      desc: '',
      args: [],
    );
  }

  /// `Script updated`
  String get scriptUpdated {
    return Intl.message(
      'Script updated',
      name: 'scriptUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Auto update interval (minutes)`
  String get autoUpdateInterval {
    return Intl.message(
      'Auto update interval (minutes)',
      name: 'autoUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the auto update interval time`
  String get profileAutoUpdateIntervalNullValidationDesc {
    return Intl.message(
      'Please enter the auto update interval time',
      name: 'profileAutoUpdateIntervalNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input a valid interval time format`
  String get profileAutoUpdateIntervalInvalidValidationDesc {
    return Intl.message(
      'Please input a valid interval time format',
      name: 'profileAutoUpdateIntervalInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme mode`
  String get themeMode {
    return Intl.message('Theme mode', name: 'themeMode', desc: '', args: []);
  }

  /// `Theme color`
  String get themeColor {
    return Intl.message('Theme color', name: 'themeColor', desc: '', args: []);
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Import from URL`
  String get importFromURL {
    return Intl.message(
      'Import from URL',
      name: 'importFromURL',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Do you want to pass`
  String get doYouWantToPass {
    return Intl.message(
      'Do you want to pass',
      name: 'doYouWantToPass',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `No QR code found in that image`
  String get qrNotRecognized {
    return Intl.message(
      'No QR code found in that image',
      name: 'qrNotRecognized',
      desc: '',
      args: [],
    );
  }

  /// `QR code read, but it is not a subscription, link or config`
  String get qrNotImportable {
    return Intl.message(
      'QR code read, but it is not a subscription, link or config',
      name: 'qrNotImportable',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message('Select all', name: 'selectAll', desc: '', args: []);
  }

  /// `Port`
  String get port {
    return Intl.message('Port', name: 'port', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `System proxy`
  String get systemProxy {
    return Intl.message(
      'System proxy',
      name: 'systemProxy',
      desc: '',
      args: [],
    );
  }

  /// `Project`
  String get project {
    return Intl.message('Project', name: 'project', desc: '', args: []);
  }

  /// `Core`
  String get core {
    return Intl.message('Core', name: 'core', desc: '', args: []);
  }

  /// `Tab animation`
  String get tabAnimation {
    return Intl.message(
      'Tab animation',
      name: 'tabAnimation',
      desc: '',
      args: [],
    );
  }

  /// `A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.`
  String get desc {
    return Intl.message(
      'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Starting VPN...`
  String get startVpn {
    return Intl.message(
      'Starting VPN...',
      name: 'startVpn',
      desc: '',
      args: [],
    );
  }

  /// `Stopping VPN...`
  String get stopVpn {
    return Intl.message('Stopping VPN...', name: 'stopVpn', desc: '', args: []);
  }

  /// `The current proxy group cannot be selected.`
  String get notSelectedTip {
    return Intl.message(
      'The current proxy group cannot be selected.',
      name: 'notSelectedTip',
      desc: '',
      args: [],
    );
  }

  /// `tip`
  String get tip {
    return Intl.message('tip', name: 'tip', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Backup`
  String get backup {
    return Intl.message('Backup', name: 'backup', desc: '', args: []);
  }

  /// `Backup success`
  String get backupSuccess {
    return Intl.message(
      'Backup success',
      name: 'backupSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No info`
  String get noInfo {
    return Intl.message('No info', name: 'noInfo', desc: '', args: []);
  }

  /// `Please bind WebDAV`
  String get pleaseBindWebDAV {
    return Intl.message(
      'Please bind WebDAV',
      name: 'pleaseBindWebDAV',
      desc: '',
      args: [],
    );
  }

  /// `Bind`
  String get bind {
    return Intl.message('Bind', name: 'bind', desc: '', args: []);
  }

  /// `Connectivity：`
  String get connectivity {
    return Intl.message(
      'Connectivity：',
      name: 'connectivity',
      desc: '',
      args: [],
    );
  }

  /// `WebDAV configuration`
  String get webDAVConfiguration {
    return Intl.message(
      'WebDAV configuration',
      name: 'webDAVConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `WebDAV server address`
  String get addressHelp {
    return Intl.message(
      'WebDAV server address',
      name: 'addressHelp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid WebDAV address`
  String get addressTip {
    return Intl.message(
      'Please enter a valid WebDAV address',
      name: 'addressTip',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Allow applications to bypass VPN`
  String get allowBypass {
    return Intl.message(
      'Allow applications to bypass VPN',
      name: 'allowBypass',
      desc: '',
      args: [],
    );
  }

  /// `Some apps can bypass VPN when turned on`
  String get allowBypassDesc {
    return Intl.message(
      'Some apps can bypass VPN when turned on',
      name: 'allowBypassDesc',
      desc: '',
      args: [],
    );
  }

  /// `When turned on it will be able to receive IPv6 traffic`
  String get ipv6Desc {
    return Intl.message(
      'When turned on it will be able to receive IPv6 traffic',
      name: 'ipv6Desc',
      desc: '',
      args: [],
    );
  }

  /// `Attach HTTP proxy to VpnService`
  String get systemProxyDesc {
    return Intl.message(
      'Attach HTTP proxy to VpnService',
      name: 'systemProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `TCP concurrent`
  String get tcpConcurrent {
    return Intl.message(
      'TCP concurrent',
      name: 'tcpConcurrent',
      desc: '',
      args: [],
    );
  }

  /// `Enabling it will allow TCP concurrency`
  String get tcpConcurrentDesc {
    return Intl.message(
      'Enabling it will allow TCP concurrency',
      name: 'tcpConcurrentDesc',
      desc: '',
      args: [],
    );
  }

  /// `Geo Low Memory Mode`
  String get geodataLoader {
    return Intl.message(
      'Geo Low Memory Mode',
      name: 'geodataLoader',
      desc: '',
      args: [],
    );
  }

  /// `Enabling will use the Geo low memory loader`
  String get geodataLoaderDesc {
    return Intl.message(
      'Enabling will use the Geo low memory loader',
      name: 'geodataLoaderDesc',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `Find process`
  String get findProcessMode {
    return Intl.message(
      'Find process',
      name: 'findProcessMode',
      desc: '',
      args: [],
    );
  }

  /// `Long term effective`
  String get infiniteTime {
    return Intl.message(
      'Long term effective',
      name: 'infiniteTime',
      desc: '',
      args: [],
    );
  }

  /// `Connections`
  String get connections {
    return Intl.message('Connections', name: 'connections', desc: '', args: []);
  }

  /// `Intranet IP`
  String get intranetIP {
    return Intl.message('Intranet IP', name: 'intranetIP', desc: '', args: []);
  }

  /// `Cut`
  String get cut {
    return Intl.message('Cut', name: 'cut', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Paste`
  String get paste {
    return Intl.message('Paste', name: 'paste', desc: '', args: []);
  }

  /// `Test url`
  String get testUrl {
    return Intl.message('Test url', name: 'testUrl', desc: '', args: []);
  }

  /// `Sync`
  String get sync {
    return Intl.message('Sync', name: 'sync', desc: '', args: []);
  }

  /// `Hide from recents`
  String get hideFromRecents {
    return Intl.message(
      'Hide from recents',
      name: 'hideFromRecents',
      desc: '',
      args: [],
    );
  }

  /// `App icon does not appear in the recent apps list while the app is in background`
  String get hideFromRecentsDesc {
    return Intl.message(
      'App icon does not appear in the recent apps list while the app is in background',
      name: 'hideFromRecentsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Delay`
  String get delay {
    return Intl.message('Delay', name: 'delay', desc: '', args: []);
  }

  /// `Style`
  String get style {
    return Intl.message('Style', name: 'style', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `Traffic`
  String get traffic {
    return Intl.message('Traffic', name: 'traffic', desc: '', args: []);
  }

  /// `Speed`
  String get speed {
    return Intl.message('Speed', name: 'speed', desc: '', args: []);
  }

  /// `All applications`
  String get allApplications {
    return Intl.message(
      'All applications',
      name: 'allApplications',
      desc: '',
      args: [],
    );
  }

  /// `Proxy group`
  String get proxyGroup {
    return Intl.message('Proxy group', name: 'proxyGroup', desc: '', args: []);
  }

  /// `Go`
  String get go {
    return Intl.message('Go', name: 'go', desc: '', args: []);
  }

  /// `External link`
  String get externalLink {
    return Intl.message(
      'External link',
      name: 'externalLink',
      desc: '',
      args: [],
    );
  }

  /// `Drop connections on node switch`
  String get autoCloseConnections {
    return Intl.message(
      'Drop connections on node switch',
      name: 'autoCloseConnections',
      desc: '',
      args: [],
    );
  }

  /// `When the proxy node changes, active connections are closed so new ones use the new node`
  String get autoCloseConnectionsDesc {
    return Intl.message(
      'When the proxy node changes, active connections are closed so new ones use the new node',
      name: 'autoCloseConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Pure black mode`
  String get pureBlackMode {
    return Intl.message(
      'Pure black mode',
      name: 'pureBlackMode',
      desc: '',
      args: [],
    );
  }

  /// ` entries`
  String get entries {
    return Intl.message(' entries', name: 'entries', desc: '', args: []);
  }

  /// `Local`
  String get local {
    return Intl.message('Local', name: 'local', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Backup local data to WebDAV`
  String get remoteBackupDesc {
    return Intl.message(
      'Backup local data to WebDAV',
      name: 'remoteBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Backup local data to local`
  String get localBackupDesc {
    return Intl.message(
      'Backup local data to local',
      name: 'localBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Layout`
  String get layout {
    return Intl.message('Layout', name: 'layout', desc: '', args: []);
  }

  /// `Tight`
  String get tight {
    return Intl.message('Tight', name: 'tight', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Loose`
  String get loose {
    return Intl.message('Loose', name: 'loose', desc: '', args: []);
  }

  /// `Profiles sort`
  String get profilesSort {
    return Intl.message(
      'Profiles sort',
      name: 'profilesSort',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Update DNS related settings`
  String get dnsDesc {
    return Intl.message(
      'Update DNS related settings',
      name: 'dnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Key`
  String get key {
    return Intl.message('Key', name: 'key', desc: '', args: []);
  }

  /// `Value`
  String get value {
    return Intl.message('Value', name: 'value', desc: '', args: []);
  }

  /// `Add Hosts`
  String get hostsDesc {
    return Intl.message('Add Hosts', name: 'hostsDesc', desc: '', args: []);
  }

  /// `Auto routes all system traffic through VpnService`
  String get vpnEnableDesc {
    return Intl.message(
      'Auto routes all system traffic through VpnService',
      name: 'vpnEnableDesc',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
  }

  /// `Providers`
  String get providers {
    return Intl.message('Providers', name: 'providers', desc: '', args: []);
  }

  /// `Proxy providers`
  String get proxyProviders {
    return Intl.message(
      'Proxy providers',
      name: 'proxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Rule providers`
  String get ruleProviders {
    return Intl.message(
      'Rule providers',
      name: 'ruleProviders',
      desc: '',
      args: [],
    );
  }

  /// `Override Dns`
  String get overrideDns {
    return Intl.message(
      'Override Dns',
      name: 'overrideDns',
      desc: '',
      args: [],
    );
  }

  /// `Controls whose DNS the core uses: the profile's or the app's`
  String get overrideDnsDesc {
    return Intl.message(
      'Controls whose DNS the core uses: the profile\'s or the app\'s',
      name: 'overrideDnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `The DNS keys picked below override the profile's`
  String get dnsSourceAppOverride {
    return Intl.message(
      'The DNS keys picked below override the profile\'s',
      name: 'dnsSourceAppOverride',
      desc: '',
      args: [],
    );
  }

  /// `The profile has no DNS of its own, so the settings below apply`
  String get dnsSourceAppFallback {
    return Intl.message(
      'The profile has no DNS of its own, so the settings below apply',
      name: 'dnsSourceAppFallback',
      desc: '',
      args: [],
    );
  }

  /// `The profile defines its own DNS. Turn this on to apply the keys picked below`
  String get dnsSourceProfile {
    return Intl.message(
      'The profile defines its own DNS. Turn this on to apply the keys picked below',
      name: 'dnsSourceProfile',
      desc: '',
      args: [],
    );
  }

  /// `Keys to override`
  String get dnsOverrideKeys {
    return Intl.message(
      'Keys to override',
      name: 'dnsOverrideKeys',
      desc: '',
      args: [],
    );
  }

  /// `None yet: the profile's DNS stays as is`
  String get dnsOverrideKeysNone {
    return Intl.message(
      'None yet: the profile\'s DNS stays as is',
      name: 'dnsOverrideKeysNone',
      desc: '',
      args: [],
    );
  }

  /// `All: the app's DNS block replaces the profile's`
  String get dnsOverrideKeysAll {
    return Intl.message(
      'All: the app\'s DNS block replaces the profile\'s',
      name: 'dnsOverrideKeysAll',
      desc: '',
      args: [],
    );
  }

  /// `Only checked keys replace the profile's values. Editing a setting checks its key.`
  String get dnsOverrideKeysTip {
    return Intl.message(
      'Only checked keys replace the profile\'s values. Editing a setting checks its key.',
      name: 'dnsOverrideKeysTip',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `System DNS will be used when turned off`
  String get statusDesc {
    return Intl.message(
      'System DNS will be used when turned off',
      name: 'statusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Prioritize the use of DOH's http/3`
  String get preferH3Desc {
    return Intl.message(
      'Prioritize the use of DOH\'s http/3',
      name: 'preferH3Desc',
      desc: '',
      args: [],
    );
  }

  /// `Respect rules`
  String get respectRules {
    return Intl.message(
      'Respect rules',
      name: 'respectRules',
      desc: '',
      args: [],
    );
  }

  /// `DNS connection following rules, need to configure proxy-server-nameserver`
  String get respectRulesDesc {
    return Intl.message(
      'DNS connection following rules, need to configure proxy-server-nameserver',
      name: 'respectRulesDesc',
      desc: '',
      args: [],
    );
  }

  /// `DNS mode`
  String get dnsMode {
    return Intl.message('DNS mode', name: 'dnsMode', desc: '', args: []);
  }

  /// `Fakeip range`
  String get fakeipRange {
    return Intl.message(
      'Fakeip range',
      name: 'fakeipRange',
      desc: '',
      args: [],
    );
  }

  /// `Fakeip filter`
  String get fakeipFilter {
    return Intl.message(
      'Fakeip filter',
      name: 'fakeipFilter',
      desc: '',
      args: [],
    );
  }

  /// `Default nameserver`
  String get defaultNameserver {
    return Intl.message(
      'Default nameserver',
      name: 'defaultNameserver',
      desc: '',
      args: [],
    );
  }

  /// `For resolving DNS server`
  String get defaultNameserverDesc {
    return Intl.message(
      'For resolving DNS server',
      name: 'defaultNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Nameserver`
  String get nameserver {
    return Intl.message('Nameserver', name: 'nameserver', desc: '', args: []);
  }

  /// `For resolving domain`
  String get nameserverDesc {
    return Intl.message(
      'For resolving domain',
      name: 'nameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Use hosts`
  String get useHosts {
    return Intl.message('Use hosts', name: 'useHosts', desc: '', args: []);
  }

  /// `Use system hosts`
  String get useSystemHosts {
    return Intl.message(
      'Use system hosts',
      name: 'useSystemHosts',
      desc: '',
      args: [],
    );
  }

  /// `Nameserver policy`
  String get nameserverPolicy {
    return Intl.message(
      'Nameserver policy',
      name: 'nameserverPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Nameservers per domain; separate several with commas`
  String get nameserverPolicyDesc {
    return Intl.message(
      'Nameservers per domain; separate several with commas',
      name: 'nameserverPolicyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Proxy nameserver`
  String get proxyNameserver {
    return Intl.message(
      'Proxy nameserver',
      name: 'proxyNameserver',
      desc: '',
      args: [],
    );
  }

  /// `Domain for resolving proxy nodes`
  String get proxyNameserverDesc {
    return Intl.message(
      'Domain for resolving proxy nodes',
      name: 'proxyNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Proxy Nameserver Policy`
  String get proxyNameserverPolicy {
    return Intl.message(
      'Proxy Nameserver Policy',
      name: 'proxyNameserverPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Nameservers per domain for resolving proxy servers; separate several with commas`
  String get proxyNameserverPolicyDesc {
    return Intl.message(
      'Nameservers per domain for resolving proxy servers; separate several with commas',
      name: 'proxyNameserverPolicyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Disclaimer`
  String get disclaimer {
    return Intl.message('Disclaimer', name: 'disclaimer', desc: '', args: []);
  }

  /// `This software is only used for non-commercial purposes such as learning exchanges and scientific research. It is strictly prohibited to use this software for commercial purposes. Any commercial activity, if any, has nothing to do with this software.`
  String get disclaimerDesc {
    return Intl.message(
      'This software is only used for non-commercial purposes such as learning exchanges and scientific research. It is strictly prohibited to use this software for commercial purposes. Any commercial activity, if any, has nothing to do with this software.',
      name: 'disclaimerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `No network`
  String get noNetwork {
    return Intl.message('No network', name: 'noNetwork', desc: '', args: []);
  }

  /// `Export logs`
  String get exportLogs {
    return Intl.message('Export logs', name: 'exportLogs', desc: '', args: []);
  }

  /// `Export Success`
  String get exportSuccess {
    return Intl.message(
      'Export Success',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Icon style`
  String get iconStyle {
    return Intl.message('Icon style', name: 'iconStyle', desc: '', args: []);
  }

  /// `Icon`
  String get onlyIcon {
    return Intl.message('Icon', name: 'onlyIcon', desc: '', args: []);
  }

  /// `Stack mode`
  String get stackMode {
    return Intl.message('Stack mode', name: 'stackMode', desc: '', args: []);
  }

  /// `MTU`
  String get mtu {
    return Intl.message('MTU', name: 'mtu', desc: '', args: []);
  }

  /// `Modify network-related settings`
  String get networkDesc {
    return Intl.message(
      'Modify network-related settings',
      name: 'networkDesc',
      desc: '',
      args: [],
    );
  }

  /// `Bypass domain`
  String get bypassDomain {
    return Intl.message(
      'Bypass domain',
      name: 'bypassDomain',
      desc: '',
      args: [],
    );
  }

  /// `Make sure to reset`
  String get resetTip {
    return Intl.message(
      'Make sure to reset',
      name: 'resetTip',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get noData {
    return Intl.message('No data', name: 'noData', desc: '', args: []);
  }

  /// `Toggle`
  String get toggle {
    return Intl.message('Toggle', name: 'toggle', desc: '', args: []);
  }

  /// `Route mode`
  String get routeMode {
    return Intl.message('Route mode', name: 'routeMode', desc: '', args: []);
  }

  /// `Route address`
  String get routeAddress {
    return Intl.message(
      'Route address',
      name: 'routeAddress',
      desc: '',
      args: [],
    );
  }

  /// `Config listen route address`
  String get routeAddressDesc {
    return Intl.message(
      'Config listen route address',
      name: 'routeAddressDesc',
      desc: '',
      args: [],
    );
  }

  /// `Memory info`
  String get memoryInfo {
    return Intl.message('Memory info', name: 'memoryInfo', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `The file has been modified. Do you want to save the changes?`
  String get fileIsUpdate {
    return Intl.message(
      'The file has been modified. Do you want to save the changes?',
      name: 'fileIsUpdate',
      desc: '',
      args: [],
    );
  }

  /// `The profile has been modified. Do you want to disable auto update?`
  String get profileHasUpdate {
    return Intl.message(
      'The profile has been modified. Do you want to disable auto update?',
      name: 'profileHasUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to cache the changes?`
  String get hasCacheChange {
    return Intl.message(
      'Do you want to cache the changes?',
      name: 'hasCacheChange',
      desc: '',
      args: [],
    );
  }

  /// `Copy success`
  String get copySuccess {
    return Intl.message(
      'Copy success',
      name: 'copySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message('Copy link', name: 'copyLink', desc: '', args: []);
  }

  /// `Export file`
  String get exportFile {
    return Intl.message('Export file', name: 'exportFile', desc: '', args: []);
  }

  /// `The cache is corrupt. Do you want to clear it?`
  String get cacheCorrupt {
    return Intl.message(
      'The cache is corrupt. Do you want to clear it?',
      name: 'cacheCorrupt',
      desc: '',
      args: [],
    );
  }

  /// `Relying on third-party api is for reference only`
  String get detectionTip {
    return Intl.message(
      'Relying on third-party api is for reference only',
      name: 'detectionTip',
      desc: '',
      args: [],
    );
  }

  /// `Listen`
  String get listen {
    return Intl.message('Listen', name: 'listen', desc: '', args: []);
  }

  /// `undo`
  String get undo {
    return Intl.message('undo', name: 'undo', desc: '', args: []);
  }

  /// `redo`
  String get redo {
    return Intl.message('redo', name: 'redo', desc: '', args: []);
  }

  /// `none`
  String get none {
    return Intl.message('none', name: 'none', desc: '', args: []);
  }

  /// `{count} items have been selected`
  String selectedCountTitle(Object count) {
    return Intl.message(
      '$count items have been selected',
      name: 'selectedCountTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Add rule`
  String get addRule {
    return Intl.message('Add rule', name: 'addRule', desc: '', args: []);
  }

  /// `Rule name`
  String get ruleName {
    return Intl.message('Rule name', name: 'ruleName', desc: '', args: []);
  }

  /// `Content`
  String get content {
    return Intl.message('Content', name: 'content', desc: '', args: []);
  }

  /// `Rule target`
  String get ruleTarget {
    return Intl.message('Rule target', name: 'ruleTarget', desc: '', args: []);
  }

  /// `Source IP`
  String get sourceIp {
    return Intl.message('Source IP', name: 'sourceIp', desc: '', args: []);
  }

  /// `No resolve IP`
  String get noResolve {
    return Intl.message('No resolve IP', name: 'noResolve', desc: '', args: []);
  }

  /// `Do you want to save the changes?`
  String get saveChanges {
    return Intl.message(
      'Do you want to save the changes?',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Used only when the profile YAML omits find-process-mode. Looking up the app of every connection costs battery.`
  String get findProcessModeDesc {
    return Intl.message(
      'Used only when the profile YAML omits find-process-mode. Looking up the app of every connection costs battery.',
      name: 'findProcessModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Every connection`
  String get findProcessModeAlways {
    return Intl.message(
      'Every connection',
      name: 'findProcessModeAlways',
      desc: '',
      args: [],
    );
  }

  /// `Only when rules need it`
  String get findProcessModeStrict {
    return Intl.message(
      'Only when rules need it',
      name: 'findProcessModeStrict',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get findProcessModeOff {
    return Intl.message('Off', name: 'findProcessModeOff', desc: '', args: []);
  }

  /// `Smooth slide between tabs (mobile layout only)`
  String get tabAnimationDesc {
    return Intl.message(
      'Smooth slide between tabs (mobile layout only)',
      name: 'tabAnimationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Color schemes`
  String get colorSchemes {
    return Intl.message(
      'Color schemes',
      name: 'colorSchemes',
      desc: '',
      args: [],
    );
  }

  /// `Palette`
  String get palette {
    return Intl.message('Palette', name: 'palette', desc: '', args: []);
  }

  /// `Developer mode`
  String get developerMode {
    return Intl.message(
      'Developer mode',
      name: 'developerMode',
      desc: '',
      args: [],
    );
  }

  /// `Developer mode is enabled.`
  String get developerModeEnableTip {
    return Intl.message(
      'Developer mode is enabled.',
      name: 'developerModeEnableTip',
      desc: '',
      args: [],
    );
  }

  /// `Message test`
  String get messageTest {
    return Intl.message(
      'Message test',
      name: 'messageTest',
      desc: '',
      args: [],
    );
  }

  /// `This is a message.`
  String get messageTestTip {
    return Intl.message(
      'This is a message.',
      name: 'messageTestTip',
      desc: '',
      args: [],
    );
  }

  /// `Crash test`
  String get crashTest {
    return Intl.message('Crash test', name: 'crashTest', desc: '', args: []);
  }

  /// `Clear Data`
  String get clearData {
    return Intl.message('Clear Data', name: 'clearData', desc: '', args: []);
  }

  /// `Text Scaling`
  String get textScale {
    return Intl.message('Text Scaling', name: 'textScale', desc: '', args: []);
  }

  /// `Restore strategy`
  String get restoreStrategy {
    return Intl.message(
      'Restore strategy',
      name: 'restoreStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Logs test`
  String get logsTest {
    return Intl.message('Logs test', name: 'logsTest', desc: '', args: []);
  }

  /// `{label} cannot be empty`
  String emptyTip(Object label) {
    return Intl.message(
      '$label cannot be empty',
      name: 'emptyTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be a url`
  String urlTip(Object label) {
    return Intl.message(
      '$label must be a url',
      name: 'urlTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be a number`
  String numberTip(Object label) {
    return Intl.message(
      '$label must be a number',
      name: 'numberTip',
      desc: '',
      args: [label],
    );
  }

  /// `Current {label} already exists`
  String existsTip(Object label) {
    return Intl.message(
      'Current $label already exists',
      name: 'existsTip',
      desc: '',
      args: [label],
    );
  }

  /// `Are you sure you want to delete the current {label}?`
  String deleteTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete the current $label?',
      name: 'deleteTip',
      desc: '',
      args: [label],
    );
  }

  /// `Are you sure you want to delete the selected {label}?`
  String deleteMultipTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete the selected $label?',
      name: 'deleteMultipTip',
      desc: '',
      args: [label],
    );
  }

  /// `No {label} yet`
  String nullTip(Object label) {
    return Intl.message(
      'No $label yet',
      name: 'nullTip',
      desc: '',
      args: [label],
    );
  }

  /// `Script`
  String get script {
    return Intl.message('Script', name: 'script', desc: '', args: []);
  }

  /// `Unnamed`
  String get unnamed {
    return Intl.message('Unnamed', name: 'unnamed', desc: '', args: []);
  }

  /// `Please enter a script name`
  String get pleaseEnterScriptName {
    return Intl.message(
      'Please enter a script name',
      name: 'pleaseEnterScriptName',
      desc: '',
      args: [],
    );
  }

  /// `Mixed Port`
  String get mixedPort {
    return Intl.message('Mixed Port', name: 'mixedPort', desc: '', args: []);
  }

  /// `Socks Port`
  String get socksPort {
    return Intl.message('Socks Port', name: 'socksPort', desc: '', args: []);
  }

  /// `Redir Port`
  String get redirPort {
    return Intl.message('Redir Port', name: 'redirPort', desc: '', args: []);
  }

  /// `Tproxy Port`
  String get tproxyPort {
    return Intl.message('Tproxy Port', name: 'tproxyPort', desc: '', args: []);
  }

  /// `{label} must be between 1024 and 49151`
  String portTip(Object label) {
    return Intl.message(
      '$label must be between 1024 and 49151',
      name: 'portTip',
      desc: '',
      args: [label],
    );
  }

  /// `Please enter a different port`
  String get portConflictTip {
    return Intl.message(
      'Please enter a different port',
      name: 'portConflictTip',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Import from file`
  String get importFile {
    return Intl.message(
      'Import from file',
      name: 'importFile',
      desc: '',
      args: [],
    );
  }

  /// `Import from URL`
  String get importUrl {
    return Intl.message(
      'Import from URL',
      name: 'importUrl',
      desc: '',
      args: [],
    );
  }

  /// `{label} details`
  String details(Object label) {
    return Intl.message(
      '$label details',
      name: 'details',
      desc: '',
      args: [label],
    );
  }

  /// `Creation time`
  String get creationTime {
    return Intl.message(
      'Creation time',
      name: 'creationTime',
      desc: '',
      args: [],
    );
  }

  /// `Process`
  String get process {
    return Intl.message('Process', name: 'process', desc: '', args: []);
  }

  /// `Host`
  String get host {
    return Intl.message('Host', name: 'host', desc: '', args: []);
  }

  /// `Destination`
  String get destination {
    return Intl.message('Destination', name: 'destination', desc: '', args: []);
  }

  /// `Destination GeoIP`
  String get destinationGeoIP {
    return Intl.message(
      'Destination GeoIP',
      name: 'destinationGeoIP',
      desc: '',
      args: [],
    );
  }

  /// `Destination IPASN`
  String get destinationIPASN {
    return Intl.message(
      'Destination IPASN',
      name: 'destinationIPASN',
      desc: '',
      args: [],
    );
  }

  /// `Special proxy`
  String get specialProxy {
    return Intl.message(
      'Special proxy',
      name: 'specialProxy',
      desc: '',
      args: [],
    );
  }

  /// `special rules`
  String get specialRules {
    return Intl.message(
      'special rules',
      name: 'specialRules',
      desc: '',
      args: [],
    );
  }

  /// `Remote destination`
  String get remoteDestination {
    return Intl.message(
      'Remote destination',
      name: 'remoteDestination',
      desc: '',
      args: [],
    );
  }

  /// `Network type`
  String get networkType {
    return Intl.message(
      'Network type',
      name: 'networkType',
      desc: '',
      args: [],
    );
  }

  /// `Proxy chains`
  String get proxyChains {
    return Intl.message(
      'Proxy chains',
      name: 'proxyChains',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get connection {
    return Intl.message('Connection', name: 'connection', desc: '', args: []);
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `Connected`
  String get connected {
    return Intl.message('Connected', name: 'connected', desc: '', args: []);
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connecting {
    return Intl.message(
      'Connecting...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restart the core?`
  String get restartCoreTip {
    return Intl.message(
      'Are you sure you want to restart the core?',
      name: 'restartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force restart the core?`
  String get forceRestartCoreTip {
    return Intl.message(
      'Are you sure you want to force restart the core?',
      name: 'forceRestartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `DNS hijacking`
  String get dnsHijacking {
    return Intl.message(
      'DNS hijacking',
      name: 'dnsHijacking',
      desc: '',
      args: [],
    );
  }

  /// `Core status`
  String get coreStatus {
    return Intl.message('Core status', name: 'coreStatus', desc: '', args: []);
  }

  /// `Append System DNS`
  String get appendSystemDns {
    return Intl.message(
      'Append System DNS',
      name: 'appendSystemDns',
      desc: '',
      args: [],
    );
  }

  /// `Forcefully append system DNS to the configuration`
  String get appendSystemDnsTip {
    return Intl.message(
      'Forcefully append system DNS to the configuration',
      name: 'appendSystemDnsTip',
      desc: '',
      args: [],
    );
  }

  /// `Edit rule`
  String get editRule {
    return Intl.message('Edit rule', name: 'editRule', desc: '', args: []);
  }

  /// `Override mode`
  String get overrideMode {
    return Intl.message(
      'Override mode',
      name: 'overrideMode',
      desc: '',
      args: [],
    );
  }

  /// `Standard mode, override basic configuration, provide simple rule addition capability`
  String get standardModeDesc {
    return Intl.message(
      'Standard mode, override basic configuration, provide simple rule addition capability',
      name: 'standardModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Script mode, use external extension scripts, provide one-click override configuration capability`
  String get scriptModeDesc {
    return Intl.message(
      'Script mode, use external extension scripts, provide one-click override configuration capability',
      name: 'scriptModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Added rules`
  String get addedRules {
    return Intl.message('Added rules', name: 'addedRules', desc: '', args: []);
  }

  /// `Control global added rules`
  String get controlGlobalAddedRules {
    return Intl.message(
      'Control global added rules',
      name: 'controlGlobalAddedRules',
      desc: '',
      args: [],
    );
  }

  /// `Override script`
  String get overrideScript {
    return Intl.message(
      'Override script',
      name: 'overrideScript',
      desc: '',
      args: [],
    );
  }

  /// `Go to configure script`
  String get goToConfigureScript {
    return Intl.message(
      'Go to configure script',
      name: 'goToConfigureScript',
      desc: '',
      args: [],
    );
  }

  /// `Edit global rules`
  String get editGlobalRules {
    return Intl.message(
      'Edit global rules',
      name: 'editGlobalRules',
      desc: '',
      args: [],
    );
  }

  /// `External fetch`
  String get externalFetch {
    return Intl.message(
      'External fetch',
      name: 'externalFetch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force crash the core?`
  String get confirmForceCrashCore {
    return Intl.message(
      'Are you sure you want to force crash the core?',
      name: 'confirmForceCrashCore',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all data?`
  String get confirmClearAllData {
    return Intl.message(
      'Are you sure you want to clear all data?',
      name: 'confirmClearAllData',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 year ago} other{{count} years ago}}`
  String yearsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 year ago',
      other: '$count years ago',
      name: 'yearsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 month ago} other{{count} months ago}}`
  String monthsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 month ago',
      other: '$count months ago',
      name: 'monthsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 day ago} other{{count} days ago}}`
  String daysAgo(num count) {
    return Intl.plural(
      count,
      one: '1 day ago',
      other: '$count days ago',
      name: 'daysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 hour ago} other{{count} hours ago}}`
  String hoursAgo(num count) {
    return Intl.plural(
      count,
      one: '1 hour ago',
      other: '$count hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 minute ago} other{{count} minutes ago}}`
  String minutesAgo(num count) {
    return Intl.plural(
      count,
      one: '1 minute ago',
      other: '$count minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `Restart VPN to apply the new app list.`
  String get restartVpnToApply {
    return Intl.message(
      'Restart VPN to apply the new app list.',
      name: 'restartVpnToApply',
      desc: '',
      args: [],
    );
  }

  /// `Reconnecting to apply the change. Active connections briefly drop.`
  String get vpnReestablishing {
    return Intl.message(
      'Reconnecting to apply the change. Active connections briefly drop.',
      name: 'vpnReestablishing',
      desc: '',
      args: [],
    );
  }

  /// `Unknown network error`
  String get unknownNetworkError {
    return Intl.message(
      'Unknown network error',
      name: 'unknownNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Recovery exception`
  String get restoreException {
    return Intl.message(
      'Recovery exception',
      name: 'restoreException',
      desc: '',
      args: [],
    );
  }

  /// `Network exception, please check your connection and try again`
  String get networkException {
    return Intl.message(
      'Network exception, please check your connection and try again',
      name: 'networkException',
      desc: '',
      args: [],
    );
  }

  /// `Server responded with HTTP {code}`
  String serverHttpError(Object code) {
    return Intl.message(
      'Server responded with HTTP $code',
      name: 'serverHttpError',
      desc: '',
      args: [code],
    );
  }

  /// `Invalid backup file`
  String get invalidBackupFile {
    return Intl.message(
      'Invalid backup file',
      name: 'invalidBackupFile',
      desc: '',
      args: [],
    );
  }

  /// `Prune cache`
  String get pruneCache {
    return Intl.message('Prune cache', name: 'pruneCache', desc: '', args: []);
  }

  /// `Backup and Restore`
  String get backupAndRestore {
    return Intl.message(
      'Backup and Restore',
      name: 'backupAndRestore',
      desc: '',
      args: [],
    );
  }

  /// `Sync data via WebDAV or files`
  String get backupAndRestoreDesc {
    return Intl.message(
      'Sync data via WebDAV or files',
      name: 'backupAndRestoreDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Restore success`
  String get restoreSuccess {
    return Intl.message(
      'Restore success',
      name: 'restoreSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Restore data via WebDAV`
  String get restoreFromWebDAVDesc {
    return Intl.message(
      'Restore data via WebDAV',
      name: 'restoreFromWebDAVDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore data via file`
  String get restoreFromFileDesc {
    return Intl.message(
      'Restore data via file',
      name: 'restoreFromFileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore profiles only`
  String get restoreOnlyProfiles {
    return Intl.message(
      'Restore profiles only',
      name: 'restoreOnlyProfiles',
      desc: '',
      args: [],
    );
  }

  /// `Restore all data`
  String get restoreAllData {
    return Intl.message(
      'Restore all data',
      name: 'restoreAllData',
      desc: '',
      args: [],
    );
  }

  /// `Add Profile`
  String get addProfile {
    return Intl.message('Add Profile', name: 'addProfile', desc: '', args: []);
  }

  /// `Delay Test`
  String get delayTest {
    return Intl.message('Delay Test', name: 'delayTest', desc: '', args: []);
  }

  /// `Location permission`
  String get locationPermissionTitle {
    return Intl.message(
      'Location permission',
      name: 'locationPermissionTitle',
      desc: '',
      args: [],
    );
  }

  /// `To detect the name of your Wi-Fi network, Android requires location permission. We use it only to read the SSID and do not store any coordinates.`
  String get locationPermissionExplanation {
    return Intl.message(
      'To detect the name of your Wi-Fi network, Android requires location permission. We use it only to read the SSID and do not store any coordinates.',
      name: 'locationPermissionExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get permissionAllow {
    return Intl.message('Allow', name: 'permissionAllow', desc: '', args: []);
  }

  /// `Not now`
  String get permissionNotNow {
    return Intl.message(
      'Not now',
      name: 'permissionNotNow',
      desc: '',
      args: [],
    );
  }

  /// `Permission required`
  String get permissionRequiredHint {
    return Intl.message(
      'Permission required',
      name: 'permissionRequiredHint',
      desc: '',
      args: [],
    );
  }

  /// `Open settings`
  String get openSettings {
    return Intl.message(
      'Open settings',
      name: 'openSettings',
      desc: '',
      args: [],
    );
  }

  /// `Network rules need Wi-Fi permission to match SSIDs`
  String get networkRulesPermissionBanner {
    return Intl.message(
      'Network rules need Wi-Fi permission to match SSIDs',
      name: 'networkRulesPermissionBanner',
      desc: '',
      args: [],
    );
  }

  /// `Permission is granted, but Location is turned off on the device. Turn on Location in system settings so the Wi-Fi network name can be read.`
  String get locationServicesDisabled {
    return Intl.message(
      'Permission is granted, but Location is turned off on the device. Turn on Location in system settings so the Wi-Fi network name can be read.',
      name: 'locationServicesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `To switch automatically while the app is in the background, allow location access all the time.`
  String get backgroundLocationRationale {
    return Intl.message(
      'To switch automatically while the app is in the background, allow location access all the time.',
      name: 'backgroundLocationRationale',
      desc: '',
      args: [],
    );
  }

  /// `Network rules`
  String get networkRulesTitle {
    return Intl.message(
      'Network rules',
      name: 'networkRulesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enable network rules`
  String get networkRulesEnable {
    return Intl.message(
      'Enable network rules',
      name: 'networkRulesEnable',
      desc: '',
      args: [],
    );
  }

  /// `Add your first rule`
  String get networkRulesEmpty {
    return Intl.message(
      'Add your first rule',
      name: 'networkRulesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add rule`
  String get networkRulesAdd {
    return Intl.message(
      'Add rule',
      name: 'networkRulesAdd',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get networkRulesEdit {
    return Intl.message('Edit', name: 'networkRulesEdit', desc: '', args: []);
  }

  /// `Delete`
  String get networkRulesDelete {
    return Intl.message(
      'Delete',
      name: 'networkRulesDelete',
      desc: '',
      args: [],
    );
  }

  /// `Disable`
  String get networkRulesDisable {
    return Intl.message(
      'Disable',
      name: 'networkRulesDisable',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get networkRulesEnableShort {
    return Intl.message(
      'Enable',
      name: 'networkRulesEnableShort',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get networkRulesActionProfile {
    return Intl.message(
      'Profile',
      name: 'networkRulesActionProfile',
      desc: '',
      args: [],
    );
  }

  /// `Don't switch`
  String get networkRulesActionNoProfile {
    return Intl.message(
      'Don\'t switch',
      name: 'networkRulesActionNoProfile',
      desc: '',
      args: [],
    );
  }

  /// `ON`
  String get networkRulesActionShortOn {
    return Intl.message(
      'ON',
      name: 'networkRulesActionShortOn',
      desc: '',
      args: [],
    );
  }

  /// `OFF`
  String get networkRulesActionShortOff {
    return Intl.message(
      'OFF',
      name: 'networkRulesActionShortOff',
      desc: '',
      args: [],
    );
  }

  /// `KEEP`
  String get networkRulesActionShortLeave {
    return Intl.message(
      'KEEP',
      name: 'networkRulesActionShortLeave',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi named`
  String get networkRulesConditionWifiNamed {
    return Intl.message(
      'Wi-Fi named',
      name: 'networkRulesConditionWifiNamed',
      desc: '',
      args: [],
    );
  }

  /// `Any Wi-Fi`
  String get networkRulesConditionAnyWifi {
    return Intl.message(
      'Any Wi-Fi',
      name: 'networkRulesConditionAnyWifi',
      desc: '',
      args: [],
    );
  }

  /// `Cellular`
  String get networkRulesConditionAnyCellular {
    return Intl.message(
      'Cellular',
      name: 'networkRulesConditionAnyCellular',
      desc: '',
      args: [],
    );
  }

  /// `Ethernet`
  String get networkRulesConditionAnyEthernet {
    return Intl.message(
      'Ethernet',
      name: 'networkRulesConditionAnyEthernet',
      desc: '',
      args: [],
    );
  }

  /// `Profile: `
  String get networkRulesConditionProfileIs {
    return Intl.message(
      'Profile: ',
      name: 'networkRulesConditionProfileIs',
      desc: '',
      args: [],
    );
  }

  /// `Add condition`
  String get networkRulesAddCondition {
    return Intl.message(
      'Add condition',
      name: 'networkRulesAddCondition',
      desc: '',
      args: [],
    );
  }

  /// `Edit condition`
  String get networkRulesConditionEdit {
    return Intl.message(
      'Edit condition',
      name: 'networkRulesConditionEdit',
      desc: '',
      args: [],
    );
  }

  /// `Not (invert)`
  String get networkRulesConditionNegate {
    return Intl.message(
      'Not (invert)',
      name: 'networkRulesConditionNegate',
      desc: '',
      args: [],
    );
  }

  /// `Exact`
  String get networkRulesWifiMatchExact {
    return Intl.message(
      'Exact',
      name: 'networkRulesWifiMatchExact',
      desc: '',
      args: [],
    );
  }

  /// `Starts with`
  String get networkRulesWifiMatchPrefix {
    return Intl.message(
      'Starts with',
      name: 'networkRulesWifiMatchPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Contains`
  String get networkRulesWifiMatchContains {
    return Intl.message(
      'Contains',
      name: 'networkRulesWifiMatchContains',
      desc: '',
      args: [],
    );
  }

  /// `Match all`
  String get networkRulesMatchAll {
    return Intl.message(
      'Match all',
      name: 'networkRulesMatchAll',
      desc: '',
      args: [],
    );
  }

  /// `Match any`
  String get networkRulesMatchAny {
    return Intl.message(
      'Match any',
      name: 'networkRulesMatchAny',
      desc: '',
      args: [],
    );
  }

  /// `AND`
  String get networkRulesJoinAnd {
    return Intl.message('AND', name: 'networkRulesJoinAnd', desc: '', args: []);
  }

  /// `OR`
  String get networkRulesJoinOr {
    return Intl.message('OR', name: 'networkRulesJoinOr', desc: '', args: []);
  }

  /// `Delete this rule?`
  String get networkRulesConfirmDelete {
    return Intl.message(
      'Delete this rule?',
      name: 'networkRulesConfirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `When no rule matches`
  String get networkRulesDefaultActionTitle {
    return Intl.message(
      'When no rule matches',
      name: 'networkRulesDefaultActionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Leave unchanged`
  String get networkRulesDefaultLeave {
    return Intl.message(
      'Leave unchanged',
      name: 'networkRulesDefaultLeave',
      desc: '',
      args: [],
    );
  }

  /// `Turn VPN on`
  String get networkRulesDefaultTurnOn {
    return Intl.message(
      'Turn VPN on',
      name: 'networkRulesDefaultTurnOn',
      desc: '',
      args: [],
    );
  }

  /// `Turn VPN off`
  String get networkRulesDefaultTurnOff {
    return Intl.message(
      'Turn VPN off',
      name: 'networkRulesDefaultTurnOff',
      desc: '',
      args: [],
    );
  }

  /// `Current decision`
  String get networkRulesStatusLabel {
    return Intl.message(
      'Current decision',
      name: 'networkRulesStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Manual choice kept until the network changes`
  String get networkRulesOverrideActive {
    return Intl.message(
      'Manual choice kept until the network changes',
      name: 'networkRulesOverrideActive',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported condition, update the app`
  String get networkRulesInvalidRule {
    return Intl.message(
      'Unsupported condition, update the app',
      name: 'networkRulesInvalidRule',
      desc: '',
      args: [],
    );
  }

  /// `Name (optional)`
  String get ruleNameOptional {
    return Intl.message(
      'Name (optional)',
      name: 'ruleNameOptional',
      desc: '',
      args: [],
    );
  }

  /// `Releases`
  String get releases {
    return Intl.message('Releases', name: 'releases', desc: '', args: []);
  }

  /// `Fork of {upstream}`
  String forkOf(Object upstream) {
    return Intl.message(
      'Fork of $upstream',
      name: 'forkOf',
      desc: '',
      args: [upstream],
    );
  }

  /// `Include WebDAV credentials in backup`
  String get includeDavCredsInBackup {
    return Intl.message(
      'Include WebDAV credentials in backup',
      name: 'includeDavCredsInBackup',
      desc: '',
      args: [],
    );
  }

  /// `REJECT`
  String get detectionRejected {
    return Intl.message(
      'REJECT',
      name: 'detectionRejected',
      desc: '',
      args: [],
    );
  }

  /// `timeout`
  String get detectionTimeout {
    return Intl.message(
      'timeout',
      name: 'detectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Off by default. Turn on only if you trust the storage where the backup will live.`
  String get includeDavCredsInBackupDesc {
    return Intl.message(
      'Off by default. Turn on only if you trust the storage where the backup will live.',
      name: 'includeDavCredsInBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Resources up to date`
  String get resourcesUpToDate {
    return Intl.message(
      'Resources up to date',
      name: 'resourcesUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `Per-app routing updated: {overlaid} re-added, {conflicts} kept yours`
  String appRoutingRulesReapplied(Object overlaid, Object conflicts) {
    return Intl.message(
      'Per-app routing updated: $overlaid re-added, $conflicts kept yours',
      name: 'appRoutingRulesReapplied',
      desc: '',
      args: [overlaid, conflicts],
    );
  }

  /// `{count} routing target(s) no longer exist after the update`
  String appRoutingDanglingTargets(Object count) {
    return Intl.message(
      '$count routing target(s) no longer exist after the update',
      name: 'appRoutingDanglingTargets',
      desc: '',
      args: [count],
    );
  }

  /// `Search apps`
  String get appRoutingSearchHint {
    return Intl.message(
      'Search apps',
      name: 'appRoutingSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `{count} groups`
  String profileGroupCount(Object count) {
    return Intl.message(
      '$count groups',
      name: 'profileGroupCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} nodes`
  String profileNodeCount(Object count) {
    return Intl.message(
      '$count nodes',
      name: 'profileNodeCount',
      desc: '',
      args: [count],
    );
  }

  /// `On`
  String get networkRulesVpnOn {
    return Intl.message('On', name: 'networkRulesVpnOn', desc: '', args: []);
  }

  /// `Off`
  String get networkRulesVpnOff {
    return Intl.message('Off', name: 'networkRulesVpnOff', desc: '', args: []);
  }

  /// `Keep`
  String get networkRulesVpnKeep {
    return Intl.message(
      'Keep',
      name: 'networkRulesVpnKeep',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi «{ssid}»`
  String networkRulesNetWifiNamed(Object ssid) {
    return Intl.message(
      'Wi-Fi «$ssid»',
      name: 'networkRulesNetWifiNamed',
      desc: '',
      args: [ssid],
    );
  }

  /// `Wi-Fi`
  String get networkRulesNetWifi {
    return Intl.message(
      'Wi-Fi',
      name: 'networkRulesNetWifi',
      desc: '',
      args: [],
    );
  }

  /// `No network`
  String get networkRulesNetNone {
    return Intl.message(
      'No network',
      name: 'networkRulesNetNone',
      desc: '',
      args: [],
    );
  }

  /// `Conditions`
  String get networkRulesConditionsLabel {
    return Intl.message(
      'Conditions',
      name: 'networkRulesConditionsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Library version`
  String get libraryVersion {
    return Intl.message(
      'Library version',
      name: 'libraryVersion',
      desc: '',
      args: [],
    );
  }

  /// `Download and switch the mihomo core version`
  String get libraryVersionDesc {
    return Intl.message(
      'Download and switch the mihomo core version',
      name: 'libraryVersionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Switch core version`
  String get libSwitchTitle {
    return Intl.message(
      'Switch core version',
      name: 'libSwitchTitle',
      desc: '',
      args: [],
    );
  }

  /// `Switching reloads the engine and drops your current connection. Continue?`
  String get libSwitchBody {
    return Intl.message(
      'Switching reloads the engine and drops your current connection. Continue?',
      name: 'libSwitchBody',
      desc: '',
      args: [],
    );
  }

  /// `Installed`
  String get libInstalled {
    return Intl.message('Installed', name: 'libInstalled', desc: '', args: []);
  }

  /// `Installed`
  String get libInstalledTag {
    return Intl.message(
      'Installed',
      name: 'libInstalledTag',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get libAvailable {
    return Intl.message('Available', name: 'libAvailable', desc: '', args: []);
  }

  /// `Active`
  String get libActive {
    return Intl.message('Active', name: 'libActive', desc: '', args: []);
  }

  /// `In use`
  String get libInUse {
    return Intl.message('In use', name: 'libInUse', desc: '', args: []);
  }

  /// `Bundled (default)`
  String get libBundled {
    return Intl.message(
      'Bundled (default)',
      name: 'libBundled',
      desc: '',
      args: [],
    );
  }

  /// `Bundled`
  String get libBundledShort {
    return Intl.message('Bundled', name: 'libBundledShort', desc: '', args: []);
  }

  /// `Bundled`
  String get libBundledTag {
    return Intl.message('Bundled', name: 'libBundledTag', desc: '', args: []);
  }

  /// `Use`
  String get libUse {
    return Intl.message('Use', name: 'libUse', desc: '', args: []);
  }

  /// `Delete`
  String get libDelete {
    return Intl.message('Delete', name: 'libDelete', desc: '', args: []);
  }

  /// `Refresh`
  String get libRefresh {
    return Intl.message('Refresh', name: 'libRefresh', desc: '', args: []);
  }

  /// `Reset to bundled`
  String get libReset {
    return Intl.message(
      'Reset to bundled',
      name: 'libReset',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load releases`
  String get libLoadError {
    return Intl.message(
      'Failed to load releases',
      name: 'libLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Requires app update`
  String get libNeedsUpdate {
    return Intl.message(
      'Requires app update',
      name: 'libNeedsUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Paste your key`
  String get quickStartPasteKey {
    return Intl.message(
      'Paste your key',
      name: 'quickStartPasteKey',
      desc: '',
      args: [],
    );
  }

  /// `Paste the link, QR, or code your provider sent you`
  String get quickStartPasteHint {
    return Intl.message(
      'Paste the link, QR, or code your provider sent you',
      name: 'quickStartPasteHint',
      desc: '',
      args: [],
    );
  }

  /// `No servers found in what you pasted`
  String get quickStartNoServers {
    return Intl.message(
      'No servers found in what you pasted',
      name: 'quickStartNoServers',
      desc: '',
      args: [],
    );
  }

  /// `Imported`
  String get quickStartImported {
    return Intl.message(
      'Imported',
      name: 'quickStartImported',
      desc: '',
      args: [],
    );
  }

  /// `Checking your connection...`
  String get quickStartVerifying {
    return Intl.message(
      'Checking your connection...',
      name: 'quickStartVerifying',
      desc: '',
      args: [],
    );
  }

  /// `verified`
  String get quickStartVerified {
    return Intl.message(
      'verified',
      name: 'quickStartVerified',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't reach the internet through this key`
  String get quickStartFailedTitle {
    return Intl.message(
      'Couldn\'t reach the internet through this key',
      name: 'quickStartFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `The key connected, but no page would load.`
  String get quickStartFailedBody {
    return Intl.message(
      'The key connected, but no page would load.',
      name: 'quickStartFailedBody',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get quickStartTryAgain {
    return Intl.message(
      'Try again',
      name: 'quickStartTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Use a different key`
  String get quickStartUseDifferent {
    return Intl.message(
      'Use a different key',
      name: 'quickStartUseDifferent',
      desc: '',
      args: [],
    );
  }

  /// `Lists`
  String get routingLists {
    return Intl.message('Lists', name: 'routingLists', desc: '', args: []);
  }

  /// `Scenarios`
  String get routingScenarios {
    return Intl.message(
      'Scenarios',
      name: 'routingScenarios',
      desc: '',
      args: [],
    );
  }

  /// `Apps`
  String get routingApps {
    return Intl.message('Apps', name: 'routingApps', desc: '', args: []);
  }

  /// `Hide system apps`
  String get routingHideSystemApps {
    return Intl.message(
      'Hide system apps',
      name: 'routingHideSystemApps',
      desc: '',
      args: [],
    );
  }

  /// `Some nodes of an unsupported type were skipped`
  String get routingSkippedNodes {
    return Intl.message(
      'Some nodes of an unsupported type were skipped',
      name: 'routingSkippedNodes',
      desc: '',
      args: [],
    );
  }

  /// `Which apps use the VPN and how`
  String get routingAppsSubtitle {
    return Intl.message(
      'Which apps use the VPN and how',
      name: 'routingAppsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Changed`
  String get routingAppsSectionChanged {
    return Intl.message(
      'Changed',
      name: 'routingAppsSectionChanged',
      desc: '',
      args: [],
    );
  }

  /// `Others · default`
  String get routingAppsSectionRest {
    return Intl.message(
      'Others · default',
      name: 'routingAppsSectionRest',
      desc: '',
      args: [],
    );
  }

  /// `Switch mode?`
  String get routingModeSwitchTitle {
    return Intl.message(
      'Switch mode?',
      name: 'routingModeSwitchTitle',
      desc: '',
      args: [],
    );
  }

  /// `All apps will use the VPN, with no exceptions. The connection drops for a second.`
  String get routingSwitchBodyAll {
    return Intl.message(
      'All apps will use the VPN, with no exceptions. The connection drops for a second.',
      name: 'routingSwitchBodyAll',
      desc: '',
      args: [],
    );
  }

  /// `Only the apps you pick will use the VPN; the rest go direct. The connection drops for a second.`
  String get routingSwitchBodyOnlySelected {
    return Intl.message(
      'Only the apps you pick will use the VPN; the rest go direct. The connection drops for a second.',
      name: 'routingSwitchBodyOnlySelected',
      desc: '',
      args: [],
    );
  }

  /// `All apps will use the VPN except the ones you pick. The connection drops for a second.`
  String get routingSwitchBodyAllExcept {
    return Intl.message(
      'All apps will use the VPN except the ones you pick. The connection drops for a second.',
      name: 'routingSwitchBodyAllExcept',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't apply the change`
  String get routingApplyFailed {
    return Intl.message(
      'Couldn\'t apply the change',
      name: 'routingApplyFailed',
      desc: '',
      args: [],
    );
  }

  /// `Can't delete: it's still in use. Remove the reference first.`
  String get routingDeleteInUse {
    return Intl.message(
      'Can\'t delete: it\'s still in use. Remove the reference first.',
      name: 'routingDeleteInUse',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get routingAdvanced {
    return Intl.message(
      'Advanced',
      name: 'routingAdvanced',
      desc: '',
      args: [],
    );
  }

  /// `Via VPN`
  String get routingViaVpn {
    return Intl.message('Via VPN', name: 'routingViaVpn', desc: '', args: []);
  }

  /// `Block`
  String get routingBlock {
    return Intl.message('Block', name: 'routingBlock', desc: '', args: []);
  }

  /// `{count} lists`
  String routingListCount(Object count) {
    return Intl.message(
      '$count lists',
      name: 'routingListCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} scenarios`
  String routingScenarioCount(Object count) {
    return Intl.message(
      '$count scenarios',
      name: 'routingScenarioCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} rules`
  String routingScenarioRuleCount(Object count) {
    return Intl.message(
      '$count rules',
      name: 'routingScenarioRuleCount',
      desc: '',
      args: [count],
    );
  }

  /// `Add list`
  String get routingAddList {
    return Intl.message('Add list', name: 'routingAddList', desc: '', args: []);
  }

  /// `No lists yet`
  String get routingNoLists {
    return Intl.message(
      'No lists yet',
      name: 'routingNoLists',
      desc: '',
      args: [],
    );
  }

  /// `By link`
  String get routingSourceLink {
    return Intl.message(
      'By link',
      name: 'routingSourceLink',
      desc: '',
      args: [],
    );
  }

  /// `Paste domains`
  String get routingSourcePaste {
    return Intl.message(
      'Paste domains',
      name: 'routingSourcePaste',
      desc: '',
      args: [],
    );
  }

  /// `By country`
  String get routingSourceCountry {
    return Intl.message(
      'By country',
      name: 'routingSourceCountry',
      desc: '',
      args: [],
    );
  }

  /// `List name`
  String get routingListName {
    return Intl.message(
      'List name',
      name: 'routingListName',
      desc: '',
      args: [],
    );
  }

  /// `One domain per line`
  String get routingPasteHint {
    return Intl.message(
      'One domain per line',
      name: 'routingPasteHint',
      desc: '',
      args: [],
    );
  }

  /// `Custom link`
  String get routingListFromLink {
    return Intl.message(
      'Custom link',
      name: 'routingListFromLink',
      desc: '',
      args: [],
    );
  }

  /// `Pasted domains`
  String get routingListPasted {
    return Intl.message(
      'Pasted domains',
      name: 'routingListPasted',
      desc: '',
      args: [],
    );
  }

  /// `By country`
  String get routingListByCountry {
    return Intl.message(
      'By country',
      name: 'routingListByCountry',
      desc: '',
      args: [],
    );
  }

  /// `New scenario`
  String get routingNewScenario {
    return Intl.message(
      'New scenario',
      name: 'routingNewScenario',
      desc: '',
      args: [],
    );
  }

  /// `No scenarios yet`
  String get routingNoScenarios {
    return Intl.message(
      'No scenarios yet',
      name: 'routingNoScenarios',
      desc: '',
      args: [],
    );
  }

  /// `Scenario name`
  String get routingScenarioName {
    return Intl.message(
      'Scenario name',
      name: 'routingScenarioName',
      desc: '',
      args: [],
    );
  }

  /// `Add rule`
  String get routingAddRule {
    return Intl.message('Add rule', name: 'routingAddRule', desc: '', args: []);
  }

  /// `Choose a list`
  String get routingPickList {
    return Intl.message(
      'Choose a list',
      name: 'routingPickList',
      desc: '',
      args: [],
    );
  }

  /// `Send to`
  String get routingSendTo {
    return Intl.message('Send to', name: 'routingSendTo', desc: '', args: []);
  }

  /// `Everything else`
  String get routingEverythingElse {
    return Intl.message(
      'Everything else',
      name: 'routingEverythingElse',
      desc: '',
      args: [],
    );
  }

  /// `Checked top to bottom`
  String get routingCheckedTopToBottom {
    return Intl.message(
      'Checked top to bottom',
      name: 'routingCheckedTopToBottom',
      desc: '',
      args: [],
    );
  }

  /// `Bypass VPN`
  String get routingAppBypass {
    return Intl.message(
      'Bypass VPN',
      name: 'routingAppBypass',
      desc: '',
      args: [],
    );
  }

  /// `Add server`
  String get routingAddServer {
    return Intl.message(
      'Add server',
      name: 'routingAddServer',
      desc: '',
      args: [],
    );
  }

  /// `Paste a link or subscription URL`
  String get routingServerHint {
    return Intl.message(
      'Paste a link or subscription URL',
      name: 'routingServerHint',
      desc: '',
      args: [],
    );
  }

  /// `No servers yet`
  String get routingNoServers {
    return Intl.message(
      'No servers yet',
      name: 'routingNoServers',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't read that link`
  String get routingImportFailed {
    return Intl.message(
      'Couldn\'t read that link',
      name: 'routingImportFailed',
      desc: '',
      args: [],
    );
  }

  /// `Server added`
  String get routingServerAdded {
    return Intl.message(
      'Server added',
      name: 'routingServerAdded',
      desc: '',
      args: [],
    );
  }

  /// `Subscription added`
  String get routingSubscriptionAdded {
    return Intl.message(
      'Subscription added',
      name: 'routingSubscriptionAdded',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get routingSubscription {
    return Intl.message(
      'Subscription',
      name: 'routingSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Create group`
  String get routingCreateGroup {
    return Intl.message(
      'Create group',
      name: 'routingCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Auto (fastest)`
  String get routingGroupAuto {
    return Intl.message(
      'Auto (fastest)',
      name: 'routingGroupAuto',
      desc: '',
      args: [],
    );
  }

  /// `Failover`
  String get routingGroupFailover {
    return Intl.message(
      'Failover',
      name: 'routingGroupFailover',
      desc: '',
      args: [],
    );
  }

  /// `Manual pick`
  String get routingGroupManual {
    return Intl.message(
      'Manual pick',
      name: 'routingGroupManual',
      desc: '',
      args: [],
    );
  }

  /// `Group name`
  String get routingGroupNameHint {
    return Intl.message(
      'Group name',
      name: 'routingGroupNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get routingConnection {
    return Intl.message(
      'Connection',
      name: 'routingConnection',
      desc: '',
      args: [],
    );
  }

  /// `Global rules`
  String get routingGlobalRules {
    return Intl.message(
      'Global rules',
      name: 'routingGlobalRules',
      desc: '',
      args: [],
    );
  }

  /// `{count} rules`
  String routingGlobalRulesCount(Object count) {
    return Intl.message(
      '$count rules',
      name: 'routingGlobalRulesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Add preset`
  String get routingAddPreset {
    return Intl.message(
      'Add preset',
      name: 'routingAddPreset',
      desc: '',
      args: [],
    );
  }

  /// `Rule presets`
  String get routingPresetPickerTitle {
    return Intl.message(
      'Rule presets',
      name: 'routingPresetPickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Block QUIC / STUN / DoT`
  String get routingPresetBlockQuicStunDot {
    return Intl.message(
      'Block QUIC / STUN / DoT',
      name: 'routingPresetBlockQuicStunDot',
      desc: '',
      args: [],
    );
  }

  /// `LAN direct`
  String get routingPresetLanDirect {
    return Intl.message(
      'LAN direct',
      name: 'routingPresetLanDirect',
      desc: '',
      args: [],
    );
  }

  /// `System services direct`
  String get routingPresetSystemServicesDirect {
    return Intl.message(
      'System services direct',
      name: 'routingPresetSystemServicesDirect',
      desc: '',
      args: [],
    );
  }

  /// `BitTorrent direct`
  String get routingPresetBittorrentDirect {
    return Intl.message(
      'BitTorrent direct',
      name: 'routingPresetBittorrentDirect',
      desc: '',
      args: [],
    );
  }

  /// `Domain`
  String get routingMatcherDomain {
    return Intl.message(
      'Domain',
      name: 'routingMatcherDomain',
      desc: '',
      args: [],
    );
  }

  /// `Domain suffix`
  String get routingMatcherDomainSuffix {
    return Intl.message(
      'Domain suffix',
      name: 'routingMatcherDomainSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Domain keyword`
  String get routingMatcherDomainKeyword {
    return Intl.message(
      'Domain keyword',
      name: 'routingMatcherDomainKeyword',
      desc: '',
      args: [],
    );
  }

  /// `IP range`
  String get routingMatcherIp {
    return Intl.message(
      'IP range',
      name: 'routingMatcherIp',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get routingMatcherApp {
    return Intl.message('App', name: 'routingMatcherApp', desc: '', args: []);
  }

  /// `Proxies`
  String get routingProxies {
    return Intl.message('Proxies', name: 'routingProxies', desc: '', args: []);
  }

  /// `Servers and subscriptions`
  String get routingProxiesSubtitle {
    return Intl.message(
      'Servers and subscriptions',
      name: 'routingProxiesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get routingGroups {
    return Intl.message('Groups', name: 'routingGroups', desc: '', args: []);
  }

  /// `How servers are chosen`
  String get routingGroupsSubtitle {
    return Intl.message(
      'How servers are chosen',
      name: 'routingGroupsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} servers`
  String routingServerCount(Object count) {
    return Intl.message(
      '$count servers',
      name: 'routingServerCount',
      desc: '',
      args: [count],
    );
  }

  /// `Rename`
  String get routingRename {
    return Intl.message('Rename', name: 'routingRename', desc: '', args: []);
  }

  /// `This group is advanced; edit it in raw YAML`
  String get routingRawGroupHint {
    return Intl.message(
      'This group is advanced; edit it in raw YAML',
      name: 'routingRawGroupHint',
      desc: '',
      args: [],
    );
  }

  /// `No groups yet`
  String get routingNoGroups {
    return Intl.message(
      'No groups yet',
      name: 'routingNoGroups',
      desc: '',
      args: [],
    );
  }

  /// `via {source}`
  String routingGroupVia(Object source) {
    return Intl.message(
      'via $source',
      name: 'routingGroupVia',
      desc: '',
      args: [source],
    );
  }

  /// `Edit group`
  String get routingEditGroup {
    return Intl.message(
      'Edit group',
      name: 'routingEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get routingGroupSource {
    return Intl.message(
      'Source',
      name: 'routingGroupSource',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get routingGroupBehavior {
    return Intl.message(
      'Mode',
      name: 'routingGroupBehavior',
      desc: '',
      args: [],
    );
  }

  /// `Pick servers`
  String get routingGroupSourceServers {
    return Intl.message(
      'Pick servers',
      name: 'routingGroupSourceServers',
      desc: '',
      args: [],
    );
  }

  /// `From a subscription`
  String get routingGroupSourceSubscription {
    return Intl.message(
      'From a subscription',
      name: 'routingGroupSourceSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Filter (regex)`
  String get routingGroupFilter {
    return Intl.message(
      'Filter (regex)',
      name: 'routingGroupFilter',
      desc: '',
      args: [],
    );
  }

  /// `e.g. main|premium`
  String get routingGroupFilterHint {
    return Intl.message(
      'e.g. main|premium',
      name: 'routingGroupFilterHint',
      desc: '',
      args: [],
    );
  }

  /// `Test interval (seconds)`
  String get routingGroupInterval {
    return Intl.message(
      'Test interval (seconds)',
      name: 'routingGroupInterval',
      desc: '',
      args: [],
    );
  }

  /// `Lazy testing`
  String get routingGroupLazy {
    return Intl.message(
      'Lazy testing',
      name: 'routingGroupLazy',
      desc: '',
      args: [],
    );
  }

  /// `Match type`
  String get routingListBehavior {
    return Intl.message(
      'Match type',
      name: 'routingListBehavior',
      desc: '',
      args: [],
    );
  }

  /// `Domains`
  String get routingBehaviorDomain {
    return Intl.message(
      'Domains',
      name: 'routingBehaviorDomain',
      desc: '',
      args: [],
    );
  }

  /// `IP ranges`
  String get routingBehaviorIpcidr {
    return Intl.message(
      'IP ranges',
      name: 'routingBehaviorIpcidr',
      desc: '',
      args: [],
    );
  }

  /// `Mixed rules`
  String get routingBehaviorClassical {
    return Intl.message(
      'Mixed rules',
      name: 'routingBehaviorClassical',
      desc: '',
      args: [],
    );
  }

  /// `By list`
  String get routingRuleByList {
    return Intl.message(
      'By list',
      name: 'routingRuleByList',
      desc: '',
      args: [],
    );
  }

  /// `By matcher`
  String get routingRuleByMatcher {
    return Intl.message(
      'By matcher',
      name: 'routingRuleByMatcher',
      desc: '',
      args: [],
    );
  }

  /// `Combined condition`
  String get routingRuleCombined {
    return Intl.message(
      'Combined condition',
      name: 'routingRuleCombined',
      desc: '',
      args: [],
    );
  }

  /// `Match by`
  String get routingMatcherType {
    return Intl.message(
      'Match by',
      name: 'routingMatcherType',
      desc: '',
      args: [],
    );
  }

  /// `domain, IP range, country or app`
  String get routingMatchValueHint {
    return Intl.message(
      'domain, IP range, country or app',
      name: 'routingMatchValueHint',
      desc: '',
      args: [],
    );
  }

  /// `Network (tcp/udp)`
  String get routingMatcherNetwork {
    return Intl.message(
      'Network (tcp/udp)',
      name: 'routingMatcherNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Geo category`
  String get routingMatcherGeosite {
    return Intl.message(
      'Geo category',
      name: 'routingMatcherGeosite',
      desc: '',
      args: [],
    );
  }

  /// `Domain wildcard`
  String get routingMatcherDomainWildcard {
    return Intl.message(
      'Domain wildcard',
      name: 'routingMatcherDomainWildcard',
      desc: '',
      args: [],
    );
  }

  /// `Domain regex`
  String get routingMatcherDomainRegex {
    return Intl.message(
      'Domain regex',
      name: 'routingMatcherDomainRegex',
      desc: '',
      args: [],
    );
  }

  /// `IP range (IPv6)`
  String get routingMatcherIpV6 {
    return Intl.message(
      'IP range (IPv6)',
      name: 'routingMatcherIpV6',
      desc: '',
      args: [],
    );
  }

  /// `IP suffix`
  String get routingMatcherIpSuffix {
    return Intl.message(
      'IP suffix',
      name: 'routingMatcherIpSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Network operator (ASN)`
  String get routingMatcherAsn {
    return Intl.message(
      'Network operator (ASN)',
      name: 'routingMatcherAsn',
      desc: '',
      args: [],
    );
  }

  /// `Country (GeoIP)`
  String get routingMatcherGeoip {
    return Intl.message(
      'Country (GeoIP)',
      name: 'routingMatcherGeoip',
      desc: '',
      args: [],
    );
  }

  /// `Destination port`
  String get routingMatcherDstPort {
    return Intl.message(
      'Destination port',
      name: 'routingMatcherDstPort',
      desc: '',
      args: [],
    );
  }

  /// `Source IP range`
  String get routingMatcherSrcIp {
    return Intl.message(
      'Source IP range',
      name: 'routingMatcherSrcIp',
      desc: '',
      args: [],
    );
  }

  /// `Source IP suffix`
  String get routingMatcherSrcIpSuffix {
    return Intl.message(
      'Source IP suffix',
      name: 'routingMatcherSrcIpSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Source ASN`
  String get routingMatcherSrcAsn {
    return Intl.message(
      'Source ASN',
      name: 'routingMatcherSrcAsn',
      desc: '',
      args: [],
    );
  }

  /// `Source country`
  String get routingMatcherSrcGeoip {
    return Intl.message(
      'Source country',
      name: 'routingMatcherSrcGeoip',
      desc: '',
      args: [],
    );
  }

  /// `Source port`
  String get routingMatcherSrcPort {
    return Intl.message(
      'Source port',
      name: 'routingMatcherSrcPort',
      desc: '',
      args: [],
    );
  }

  /// `App name wildcard`
  String get routingMatcherAppWildcard {
    return Intl.message(
      'App name wildcard',
      name: 'routingMatcherAppWildcard',
      desc: '',
      args: [],
    );
  }

  /// `App name regex`
  String get routingMatcherAppRegex {
    return Intl.message(
      'App name regex',
      name: 'routingMatcherAppRegex',
      desc: '',
      args: [],
    );
  }

  /// `App path`
  String get routingMatcherAppPath {
    return Intl.message(
      'App path',
      name: 'routingMatcherAppPath',
      desc: '',
      args: [],
    );
  }

  /// `App path wildcard`
  String get routingMatcherAppPathWildcard {
    return Intl.message(
      'App path wildcard',
      name: 'routingMatcherAppPathWildcard',
      desc: '',
      args: [],
    );
  }

  /// `App path regex`
  String get routingMatcherAppPathRegex {
    return Intl.message(
      'App path regex',
      name: 'routingMatcherAppPathRegex',
      desc: '',
      args: [],
    );
  }

  /// `User ID (UID)`
  String get routingMatcherUid {
    return Intl.message(
      'User ID (UID)',
      name: 'routingMatcherUid',
      desc: '',
      args: [],
    );
  }

  /// `Domain / website`
  String get routingMatcherCatDomain {
    return Intl.message(
      'Domain / website',
      name: 'routingMatcherCatDomain',
      desc: '',
      args: [],
    );
  }

  /// `Destination IP`
  String get routingMatcherCatDestIp {
    return Intl.message(
      'Destination IP',
      name: 'routingMatcherCatDestIp',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get routingMatcherCatSource {
    return Intl.message(
      'Source',
      name: 'routingMatcherCatSource',
      desc: '',
      args: [],
    );
  }

  /// `App / process`
  String get routingMatcherCatApp {
    return Intl.message(
      'App / process',
      name: 'routingMatcherCatApp',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get routingMatcherCatConnection {
    return Intl.message(
      'Connection',
      name: 'routingMatcherCatConnection',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get routingSearchHint {
    return Intl.message(
      'Search',
      name: 'routingSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Other code`
  String get routingCountryOther {
    return Intl.message(
      'Other code',
      name: 'routingCountryOther',
      desc: '',
      args: [],
    );
  }

  /// `ISO code or geo tag (e.g. private)`
  String get routingCountryOtherHint {
    return Intl.message(
      'ISO code or geo tag (e.g. private)',
      name: 'routingCountryOtherHint',
      desc: '',
      args: [],
    );
  }

  /// `DNS resolution`
  String get routingNoResolveTitle {
    return Intl.message(
      'DNS resolution',
      name: 'routingNoResolveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Match IP only`
  String get routingNoResolveOn {
    return Intl.message(
      'Match IP only',
      name: 'routingNoResolveOn',
      desc: '',
      args: [],
    );
  }

  /// `Do not resolve domains (no-resolve)`
  String get routingNoResolveOnDesc {
    return Intl.message(
      'Do not resolve domains (no-resolve)',
      name: 'routingNoResolveOnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Resolve domains first`
  String get routingNoResolveOff {
    return Intl.message(
      'Resolve domains first',
      name: 'routingNoResolveOff',
      desc: '',
      args: [],
    );
  }

  /// `Look up the IP before matching`
  String get routingNoResolveOffDesc {
    return Intl.message(
      'Look up the IP before matching',
      name: 'routingNoResolveOffDesc',
      desc: '',
      args: [],
    );
  }

  /// `All of`
  String get routingLogicAll {
    return Intl.message('All of', name: 'routingLogicAll', desc: '', args: []);
  }

  /// `Any of`
  String get routingLogicAny {
    return Intl.message('Any of', name: 'routingLogicAny', desc: '', args: []);
  }

  /// `None of`
  String get routingLogicNone {
    return Intl.message(
      'None of',
      name: 'routingLogicNone',
      desc: '',
      args: [],
    );
  }

  /// `Match when`
  String get routingLogicOperator {
    return Intl.message(
      'Match when',
      name: 'routingLogicOperator',
      desc: '',
      args: [],
    );
  }

  /// `Conditions`
  String get routingConditions {
    return Intl.message(
      'Conditions',
      name: 'routingConditions',
      desc: '',
      args: [],
    );
  }

  /// `Add condition`
  String get routingAddCondition {
    return Intl.message(
      'Add condition',
      name: 'routingAddCondition',
      desc: '',
      args: [],
    );
  }

  /// `Edit server`
  String get routingEditProxy {
    return Intl.message(
      'Edit server',
      name: 'routingEditProxy',
      desc: '',
      args: [],
    );
  }

  /// `Subscription URL`
  String get routingSubscriptionUrl {
    return Intl.message(
      'Subscription URL',
      name: 'routingSubscriptionUrl',
      desc: '',
      args: [],
    );
  }

  /// `Health-check URL`
  String get routingGroupTestUrl {
    return Intl.message(
      'Health-check URL',
      name: 'routingGroupTestUrl',
      desc: '',
      args: [],
    );
  }

  /// `Tolerance (ms)`
  String get routingGroupTolerance {
    return Intl.message(
      'Tolerance (ms)',
      name: 'routingGroupTolerance',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get routingModeAll {
    return Intl.message('All', name: 'routingModeAll', desc: '', args: []);
  }

  /// `Every app goes through the VPN. No per-app exceptions.`
  String get routingModeAllDesc {
    return Intl.message(
      'Every app goes through the VPN. No per-app exceptions.',
      name: 'routingModeAllDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get routingModeOnlySelected {
    return Intl.message(
      'Selected',
      name: 'routingModeOnlySelected',
      desc: '',
      args: [],
    );
  }

  /// `Only the apps you pick use the VPN. The rest stay off it.`
  String get routingModeOnlySelectedDesc {
    return Intl.message(
      'Only the apps you pick use the VPN. The rest stay off it.',
      name: 'routingModeOnlySelectedDesc',
      desc: '',
      args: [],
    );
  }

  /// `Except`
  String get routingModeAllExcept {
    return Intl.message(
      'Except',
      name: 'routingModeAllExcept',
      desc: '',
      args: [],
    );
  }

  /// `Every app uses the VPN except the ones you pick.`
  String get routingModeAllExceptDesc {
    return Intl.message(
      'Every app uses the VPN except the ones you pick.',
      name: 'routingModeAllExceptDesc',
      desc: '',
      args: [],
    );
  }

  /// `This profile sets both an include and an exclude list. It runs as a whitelist of include minus exclude. Normalize to edit.`
  String get routingBothBannerBody {
    return Intl.message(
      'This profile sets both an include and an exclude list. It runs as a whitelist of include minus exclude. Normalize to edit.',
      name: 'routingBothBannerBody',
      desc: '',
      args: [],
    );
  }

  /// `Your phone hides some installed apps from FlClash. Allow "Get installed apps" in the app's permissions to see them all.`
  String get appListRestrictedBody {
    return Intl.message(
      'Your phone hides some installed apps from FlClash. Allow "Get installed apps" in the app\'s permissions to see them all.',
      name: 'appListRestrictedBody',
      desc: '',
      args: [],
    );
  }

  /// `Normalize`
  String get routingBothNormalize {
    return Intl.message(
      'Normalize',
      name: 'routingBothNormalize',
      desc: '',
      args: [],
    );
  }

  /// `Auto-update`
  String get geoAutoUpdate {
    return Intl.message(
      'Auto-update',
      name: 'geoAutoUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get geoUpdateOff {
    return Intl.message('Off', name: 'geoUpdateOff', desc: '', args: []);
  }

  /// `Daily`
  String get geoUpdateDaily {
    return Intl.message('Daily', name: 'geoUpdateDaily', desc: '', args: []);
  }

  /// `Every 3 days`
  String get geoUpdateEvery3Days {
    return Intl.message(
      'Every 3 days',
      name: 'geoUpdateEvery3Days',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get geoUpdateWeekly {
    return Intl.message('Weekly', name: 'geoUpdateWeekly', desc: '', args: []);
  }

  /// `Hidden`
  String get routingGroupHidden {
    return Intl.message(
      'Hidden',
      name: 'routingGroupHidden',
      desc: '',
      args: [],
    );
  }

  /// `Incompatible (older core)`
  String get libIncompatibleOld {
    return Intl.message(
      'Incompatible (older core)',
      name: 'libIncompatibleOld',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 day left} other{{count} days left}}`
  String subDaysLeft(num count) {
    return Intl.plural(
      count,
      one: '1 day left',
      other: '$count days left',
      name: 'subDaysLeft',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 hour left} other{{count} hours left}}`
  String subHoursLeft(num count) {
    return Intl.plural(
      count,
      one: '1 hour left',
      other: '$count hours left',
      name: 'subHoursLeft',
      desc: '',
      args: [count],
    );
  }

  /// `Expired`
  String get subExpired {
    return Intl.message('Expired', name: 'subExpired', desc: '', args: []);
  }

  /// `{value} left`
  String subRemaining(Object value) {
    return Intl.message(
      '$value left',
      name: 'subRemaining',
      desc: '',
      args: [value],
    );
  }

  /// `Tab`
  String get tab {
    return Intl.message('Tab', name: 'tab', desc: '', args: []);
  }

  /// `List`
  String get list {
    return Intl.message('List', name: 'list', desc: '', args: []);
  }

  /// `Standard`
  String get expand {
    return Intl.message('Standard', name: 'expand', desc: '', args: []);
  }

  /// `Shrink`
  String get shrink {
    return Intl.message('Shrink', name: 'shrink', desc: '', args: []);
  }

  /// `Min`
  String get min {
    return Intl.message('Min', name: 'min', desc: '', args: []);
  }

  /// `Global`
  String get global {
    return Intl.message('Global', name: 'global', desc: '', args: []);
  }

  /// `Direct`
  String get direct {
    return Intl.message('Direct', name: 'direct', desc: '', args: []);
  }

  /// `Override`
  String get restoreStrategy_override {
    return Intl.message(
      'Override',
      name: 'restoreStrategy_override',
      desc: '',
      args: [],
    );
  }

  /// `Compatible`
  String get restoreStrategy_compatible {
    return Intl.message(
      'Compatible',
      name: 'restoreStrategy_compatible',
      desc: '',
      args: [],
    );
  }

  /// `Bypass private route address`
  String get routeMode_bypassPrivate {
    return Intl.message(
      'Bypass private route address',
      name: 'routeMode_bypassPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Use config`
  String get routeMode_config {
    return Intl.message(
      'Use config',
      name: 'routeMode_config',
      desc: '',
      args: [],
    );
  }

  /// `TonalSpot`
  String get tonalSpotScheme {
    return Intl.message(
      'TonalSpot',
      name: 'tonalSpotScheme',
      desc: '',
      args: [],
    );
  }

  /// `Fidelity`
  String get fidelityScheme {
    return Intl.message('Fidelity', name: 'fidelityScheme', desc: '', args: []);
  }

  /// `Monochrome`
  String get monochromeScheme {
    return Intl.message(
      'Monochrome',
      name: 'monochromeScheme',
      desc: '',
      args: [],
    );
  }

  /// `Neutral`
  String get neutralScheme {
    return Intl.message('Neutral', name: 'neutralScheme', desc: '', args: []);
  }

  /// `Vibrant`
  String get vibrantScheme {
    return Intl.message('Vibrant', name: 'vibrantScheme', desc: '', args: []);
  }

  /// `Expressive`
  String get expressiveScheme {
    return Intl.message(
      'Expressive',
      name: 'expressiveScheme',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get contentScheme {
    return Intl.message('Content', name: 'contentScheme', desc: '', args: []);
  }

  /// `Rainbow`
  String get rainbowScheme {
    return Intl.message('Rainbow', name: 'rainbowScheme', desc: '', args: []);
  }

  /// `FruitSalad`
  String get fruitSaladScheme {
    return Intl.message(
      'FruitSalad',
      name: 'fruitSaladScheme',
      desc: '',
      args: [],
    );
  }

  /// `View recently request records`
  String get requestsDesc {
    return Intl.message(
      'View recently request records',
      name: 'requestsDesc',
      desc: '',
      args: [],
    );
  }

  /// `View current connections data`
  String get connectionsDesc {
    return Intl.message(
      'View current connections data',
      name: 'connectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Log capture records`
  String get logsDesc {
    return Intl.message(
      'Log capture records',
      name: 'logsDesc',
      desc: '',
      args: [],
    );
  }

  /// `External resource related info`
  String get resourcesDesc {
    return Intl.message(
      'External resource related info',
      name: 'resourcesDesc',
      desc: '',
      args: [],
    );
  }

  /// `IP quality check`
  String get ipQualityCheck {
    return Intl.message(
      'IP quality check',
      name: 'ipQualityCheck',
      desc: '',
      args: [],
    );
  }

  /// `Checking will send {ip} to each service below over HTTPS, so it can look up its ownership, risk and network type.`
  String ipQualityIntro(Object ip) {
    return Intl.message(
      'Checking will send $ip to each service below over HTTPS, so it can look up its ownership, risk and network type.',
      name: 'ipQualityIntro',
      desc: '',
      args: [ip],
    );
  }

  /// `Check`
  String get ipQualityCheckAction {
    return Intl.message(
      'Check',
      name: 'ipQualityCheckAction',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get ipQualitySources {
    return Intl.message(
      'Services',
      name: 'ipQualitySources',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get ipQualityResult {
    return Intl.message('Result', name: 'ipQualityResult', desc: '', args: []);
  }

  /// `Quality`
  String get ipQualityLevel {
    return Intl.message('Quality', name: 'ipQualityLevel', desc: '', args: []);
  }

  /// `Good`
  String get ipQualityGood {
    return Intl.message('Good', name: 'ipQualityGood', desc: '', args: []);
  }

  /// `Normal`
  String get ipQualityNormal {
    return Intl.message('Normal', name: 'ipQualityNormal', desc: '', args: []);
  }

  /// `Risky`
  String get ipQualityRisky {
    return Intl.message('Risky', name: 'ipQualityRisky', desc: '', args: []);
  }

  /// `IP address`
  String get ipAddress {
    return Intl.message('IP address', name: 'ipAddress', desc: '', args: []);
  }

  /// `Type`
  String get ipType {
    return Intl.message('Type', name: 'ipType', desc: '', args: []);
  }

  /// `Residential`
  String get ipTypeResidential {
    return Intl.message(
      'Residential',
      name: 'ipTypeResidential',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get ipTypeMobile {
    return Intl.message('Mobile', name: 'ipTypeMobile', desc: '', args: []);
  }

  /// `Business`
  String get ipTypeBusiness {
    return Intl.message('Business', name: 'ipTypeBusiness', desc: '', args: []);
  }

  /// `Hosting`
  String get ipTypeHosting {
    return Intl.message('Hosting', name: 'ipTypeHosting', desc: '', args: []);
  }

  /// `Organization`
  String get ipOrganization {
    return Intl.message(
      'Organization',
      name: 'ipOrganization',
      desc: '',
      args: [],
    );
  }

  /// `ASN`
  String get ipAsn {
    return Intl.message('ASN', name: 'ipAsn', desc: '', args: []);
  }

  /// `Flags`
  String get ipFlags {
    return Intl.message('Flags', name: 'ipFlags', desc: '', args: []);
  }

  /// `Tor`
  String get ipFlagTor {
    return Intl.message('Tor', name: 'ipFlagTor', desc: '', args: []);
  }

  /// `Abuse reports`
  String get ipFlagAbuser {
    return Intl.message(
      'Abuse reports',
      name: 'ipFlagAbuser',
      desc: '',
      args: [],
    );
  }

  /// `VPN`
  String get ipFlagVpn {
    return Intl.message('VPN', name: 'ipFlagVpn', desc: '', args: []);
  }

  /// `Proxy`
  String get ipFlagProxy {
    return Intl.message('Proxy', name: 'ipFlagProxy', desc: '', args: []);
  }

  /// `Every service failed to answer`
  String get ipQualityFailed {
    return Intl.message(
      'Every service failed to answer',
      name: 'ipQualityFailed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get ipQualityRetry {
    return Intl.message('Retry', name: 'ipQualityRetry', desc: '', args: []);
  }

  /// `No type reported`
  String get ipSourceNoType {
    return Intl.message(
      'No type reported',
      name: 'ipSourceNoType',
      desc: '',
      args: [],
    );
  }

  /// `Rate limited`
  String get ipSourceRateLimited {
    return Intl.message(
      'Rate limited',
      name: 'ipSourceRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get ipSourceFailed {
    return Intl.message('Failed', name: 'ipSourceFailed', desc: '', args: []);
  }

  /// `IP mismatch`
  String get ipSourceIpMismatch {
    return Intl.message(
      'IP mismatch',
      name: 'ipSourceIpMismatch',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
