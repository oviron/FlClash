// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "${count} routing target(s) no longer exist after the update";

  static String m1(count) =>
      "Moved ${count} apps from App access into the profile";

  static String m2(count, fallback) =>
      "${count} more apps — default ${fallback}";

  static String m3(overlaid, conflicts) =>
      "Per-app routing updated: ${overlaid} re-added, ${conflicts} kept yours";

  static String m4(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m5(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m6(label) =>
      "Are you sure you want to delete the current ${label}?";

  static String m7(label) => "${label} details";

  static String m8(label) => "${label} cannot be empty";

  static String m9(label) => "Current ${label} already exists";

  static String m10(upstream) => "Fork of ${upstream}";

  static String m11(keys) => "Preserved as-is: ${keys}";

  static String m12(count) => "${count} members";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m14(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m15(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m16(ssid) => "Wi-Fi «${ssid}»";

  static String m17(label) => "No ${label} yet";

  static String m18(label) => "${label} must be a number";

  static String m19(label) => "${label} must be between 1024 and 49151";

  static String m20(count) => "${count} groups";

  static String m21(count) => "${count} nodes";

  static String m22(count) => "${count} providers · limits";

  static String m23(n) => "every ${n}s";

  static String m24(count) => "${count} rules";

  static String m25(source) => "via ${source}";

  static String m26(count) => "${count} lists";

  static String m27(count) => "${count} scenarios";

  static String m28(count) => "${count} rules";

  static String m29(count) => "${count} servers";

  static String m30(count) => "${count} items have been selected";

  static String m31(count) => "${count} rules";

  static String m32(label) => "${label} must be a url";

  static String m33(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("AccessControl"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only allow selected app to enter VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Configure application access proxy",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "The selected application will be excluded from VPN",
    ),
    "accessControlProfileLock": MessageLookupByLibrary.simpleMessage(
      "App list is set by the active profile (tun.include-package / tun.exclude-package). GUI editing is disabled.",
    ),
    "accessControlResetToYaml": MessageLookupByLibrary.simpleMessage(
      "Reset to YAML",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access Control Settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "aclSaveDroppedUninstalled": MessageLookupByLibrary.simpleMessage(
      "Removed N uninstalled app(s) from list",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addLogicalRule": MessageLookupByLibrary.simpleMessage("Add logical rule"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow applications to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Some apps can bypass VPN when turned on",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("AllowLan"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow access proxy through the LAN",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appRouting": MessageLookupByLibrary.simpleMessage("Per-app routing"),
    "appRoutingAllRules": MessageLookupByLibrary.simpleMessage("All rules"),
    "appRoutingApps": MessageLookupByLibrary.simpleMessage("Apps"),
    "appRoutingBypassChip": MessageLookupByLibrary.simpleMessage("bypass"),
    "appRoutingBypassDirect": MessageLookupByLibrary.simpleMessage("Bypass"),
    "appRoutingBypassSection": MessageLookupByLibrary.simpleMessage(
      "Bypass · direct",
    ),
    "appRoutingDanglingTargets": m0,
    "appRoutingDeadRule": MessageLookupByLibrary.simpleMessage(
      "App is outside the tunnel, so its routing target won\'t apply",
    ),
    "appRoutingDefault": MessageLookupByLibrary.simpleMessage("Profile rules"),
    "appRoutingDefaultBypass": MessageLookupByLibrary.simpleMessage("direct"),
    "appRoutingDefaultTunnel": MessageLookupByLibrary.simpleMessage(
      "in tunnel",
    ),
    "appRoutingDirectDesc": MessageLookupByLibrary.simpleMessage(
      "inside mihomo, but direct",
    ),
    "appRoutingInTunnel": MessageLookupByLibrary.simpleMessage("In tunnel"),
    "appRoutingInTunnelSection": MessageLookupByLibrary.simpleMessage(
      "In tunnel · via mihomo",
    ),
    "appRoutingListMode": MessageLookupByLibrary.simpleMessage("List mode"),
    "appRoutingMigrated": m1,
    "appRoutingModeBlacklist": MessageLookupByLibrary.simpleMessage(
      "Blacklist: marked apps bypass the VPN, the rest go through",
    ),
    "appRoutingModeWhitelist": MessageLookupByLibrary.simpleMessage(
      "Whitelist: only apps marked in-tunnel go through the VPN",
    ),
    "appRoutingOutside": MessageLookupByLibrary.simpleMessage("Outside tunnel"),
    "appRoutingProcessMatch": MessageLookupByLibrary.simpleMessage(
      "Process matching",
    ),
    "appRoutingProcessMatchDesc": MessageLookupByLibrary.simpleMessage(
      "needed for per-app rules to work",
    ),
    "appRoutingProcessOff": MessageLookupByLibrary.simpleMessage(
      "Process matching is off in this profile, per-app routing won\'t apply",
    ),
    "appRoutingProfileRulesDesc": MessageLookupByLibrary.simpleMessage(
      "the profile decides",
    ),
    "appRoutingRemaining": m2,
    "appRoutingRulesReapplied": m3,
    "appRoutingSearchHint": MessageLookupByLibrary.simpleMessage("Search apps"),
    "appRoutingSectionFast": MessageLookupByLibrary.simpleMessage("Fast"),
    "appRoutingSectionGroup": MessageLookupByLibrary.simpleMessage("Via group"),
    "appRoutingSectionGroupHint": MessageLookupByLibrary.simpleMessage(
      "one exit for all traffic",
    ),
    "appRoutingSectionScenario": MessageLookupByLibrary.simpleMessage(
      "By scenario",
    ),
    "appRoutingSectionScenarioHint": MessageLookupByLibrary.simpleMessage(
      "via a rule set",
    ),
    "appRoutingSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Routing settings",
    ),
    "appRoutingShowSystem": MessageLookupByLibrary.simpleMessage("System apps"),
    "appRoutingShowSystemDesc": MessageLookupByLibrary.simpleMessage(
      "in the app list",
    ),
    "appRoutingSortConfigured": MessageLookupByLibrary.simpleMessage(
      "Configured first",
    ),
    "appRoutingSortName": MessageLookupByLibrary.simpleMessage("By name"),
    "appRoutingStep1": MessageLookupByLibrary.simpleMessage("In mihomo?"),
    "appRoutingStep1Hint": MessageLookupByLibrary.simpleMessage(
      "in tunnel — traffic enters mihomo and follows the rules below",
    ),
    "appRoutingStep2": MessageLookupByLibrary.simpleMessage(
      "Route inside mihomo",
    ),
    "appRoutingSubRule": MessageLookupByLibrary.simpleMessage("Sub-rule"),
    "appRoutingTunnelRestart": MessageLookupByLibrary.simpleMessage(
      "Tunnel change applies on next VPN restart",
    ),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append System DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Forcefully append system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Modify application related settings",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Drop connections on node switch",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "When the proxy node changes, active connections are closed so new ones use the new node",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Start on device boot"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "VPN service launches automatically after the phone reboots (requires OEM whitelisting)",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Connect on app open"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Tunnel comes up immediately when the app is launched",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto update interval (minutes)",
    ),
    "backgroundLocationRationale": MessageLookupByLibrary.simpleMessage(
      "To switch automatically while the app is in the background, allow location access all the time.",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Backup and recovery",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or file",
    ),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and Restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup success"),
    "behaviorClassical": MessageLookupByLibrary.simpleMessage("Classical"),
    "behaviorDomain": MessageLookupByLibrary.simpleMessage("Domains"),
    "behaviorIpcidr": MessageLookupByLibrary.simpleMessage("IP addresses"),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect when the system proxy is enabled",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupt. Do you want to clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Cancel select all",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear Data"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Export clipboard"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Clipboard import"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteWebDAV": MessageLookupByLibrary.simpleMessage(
      "Delete WebDAV configuration?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connections data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity："),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copying environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy success"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreDesc": MessageLookupByLibrary.simpleMessage(
      "Ports, IPv6, hosts, find-process, geodata loader, test URL",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "crashReporting": MessageLookupByLibrary.simpleMessage("Crash reporting"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "days": MessageLookupByLibrary.simpleMessage("Days"),
    "daysAgo": m4,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving DNS server",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay Test"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m5,
    "deleteTip": m6,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IPASN",
    ),
    "details": m7,
    "detailsSection": MessageLookupByLibrary.simpleMessage("Details"),
    "detectionRejected": MessageLookupByLibrary.simpleMessage("REJECT"),
    "detectionTimeout": MessageLookupByLibrary.simpleMessage("timeout"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relying on third-party api is for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeDesc": MessageLookupByLibrary.simpleMessage(
      "Adds a Developer screen with diagnostic actions.",
    ),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "diagnostics": MessageLookupByLibrary.simpleMessage("Diagnostics"),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is only used for non-commercial purposes such as learning exchanges and scientific research. It is strictly prohibited to use this software for commercial purposes. Any commercial activity, if any, has nothing to do with this software.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "dnsBehaviorSection": MessageLookupByLibrary.simpleMessage("Behavior"),
    "dnsCoreSection": MessageLookupByLibrary.simpleMessage("Core"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS related settings",
    ),
    "dnsFakeIpSection": MessageLookupByLibrary.simpleMessage("Fake-IP"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsResolversSection": MessageLookupByLibrary.simpleMessage("Resolvers"),
    "dnsServerSection": MessageLookupByLibrary.simpleMessage("Server"),
    "dnsServersSection": MessageLookupByLibrary.simpleMessage("Servers"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Do you want to pass",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "engine": MessageLookupByLibrary.simpleMessage("Engine"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "existsTip": m9,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Success"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip range"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Do you want to save the changes?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fallback used only when profile YAML omits find-process-mode. Small performance impact.",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("FontFamily"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "forkOf": m10,
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("FruitSalad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("General settings"),
    "geoDatabases": MessageLookupByLibrary.simpleMessage("Geo databases"),
    "geoDatabasesDesc": MessageLookupByLibrary.simpleMessage(
      "GeoIP, GeoSite, MMDB, ASN updaters",
    ),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo Low Memory Mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling will use the Geo low memory loader",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to configure script",
    ),
    "group": MessageLookupByLibrary.simpleMessage("group"),
    "groupAddKey": MessageLookupByLibrary.simpleMessage("Add key"),
    "groupAddMember": MessageLookupByLibrary.simpleMessage("Add"),
    "groupAdvancedKeys": MessageLookupByLibrary.simpleMessage(
      "Advanced (core keys)",
    ),
    "groupDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete this group?",
    ),
    "groupExtraKeys": m11,
    "groupFilterHint": MessageLookupByLibrary.simpleMessage(
      "Members are matched from all proxies by this regex",
    ),
    "groupFilterMembers": MessageLookupByLibrary.simpleMessage(
      "Members by filter",
    ),
    "groupFilterRegex": MessageLookupByLibrary.simpleMessage("Filter (regex)"),
    "groupHealthInterval": MessageLookupByLibrary.simpleMessage(
      "Interval (seconds)",
    ),
    "groupHealthUrl": MessageLookupByLibrary.simpleMessage("Health-check URL"),
    "groupLazy": MessageLookupByLibrary.simpleMessage(
      "Lazy (test only when selected)",
    ),
    "groupMemberCount": m12,
    "groupMembers": MessageLookupByLibrary.simpleMessage("Members"),
    "groupMembersManual": MessageLookupByLibrary.simpleMessage(
      "Set members manually",
    ),
    "groupNameExists": MessageLookupByLibrary.simpleMessage(
      "A group with this name already exists",
    ),
    "groupNew": MessageLookupByLibrary.simpleMessage("New group"),
    "groupOpenYaml": MessageLookupByLibrary.simpleMessage("Open as YAML"),
    "groupType": MessageLookupByLibrary.simpleMessage("Type"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Do you want to cache the changes?",
    ),
    "hideFromRecents": MessageLookupByLibrary.simpleMessage(
      "Hide from recents",
    ),
    "hideFromRecentsDesc": MessageLookupByLibrary.simpleMessage(
      "App icon does not appear in the recent apps list while the app is in background",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hosts": MessageLookupByLibrary.simpleMessage("Hosts"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Add Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Use keyboard to control applications",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("Hours"),
    "hoursAgo": m13,
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inAppLogBuffer": MessageLookupByLibrary.simpleMessage("In-app log buffer"),
    "inAppLogBufferDesc": MessageLookupByLibrary.simpleMessage(
      "Keep recent events in the Logs view (internal buffer, separate from adb logcat)",
    ),
    "includeDavCredsInBackup": MessageLookupByLibrary.simpleMessage(
      "Include WebDAV credentials in backup",
    ),
    "includeDavCredsInBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Off by default. Turn on only if you trust the storage where the backup will live.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Long term effective"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter the correct hotkey",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Intelligent selection",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "ipv6": MessageLookupByLibrary.simpleMessage("IPv6"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When turned on it will be able to receive IPv6 traffic",
    ),
    "ipv6DnsQueries": MessageLookupByLibrary.simpleMessage(
      "IPv6 (DNS queries)",
    ),
    "ipv6Engine": MessageLookupByLibrary.simpleMessage("IPv6 (engine)"),
    "ipv6Inbound": MessageLookupByLibrary.simpleMessage("IPv6 (VPN inbound)"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Tcp keep alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "launchAndBackground": MessageLookupByLibrary.simpleMessage(
      "Launch & background",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "legalAndDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Legal & disclaimer",
    ),
    "libActive": MessageLookupByLibrary.simpleMessage("Active"),
    "libAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "libBundled": MessageLookupByLibrary.simpleMessage("Bundled (default)"),
    "libBundledShort": MessageLookupByLibrary.simpleMessage("Bundled"),
    "libBundledTag": MessageLookupByLibrary.simpleMessage("Bundled"),
    "libDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "libInUse": MessageLookupByLibrary.simpleMessage("In use"),
    "libInstalled": MessageLookupByLibrary.simpleMessage("Installed"),
    "libInstalledTag": MessageLookupByLibrary.simpleMessage("Installed"),
    "libLoadError": MessageLookupByLibrary.simpleMessage(
      "Failed to load releases",
    ),
    "libNeedsUpdate": MessageLookupByLibrary.simpleMessage(
      "Requires app update",
    ),
    "libRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "libReset": MessageLookupByLibrary.simpleMessage("Reset to bundled"),
    "libSwitchBody": MessageLookupByLibrary.simpleMessage(
      "Switching reloads the engine and drops your current connection. Continue?",
    ),
    "libSwitchTitle": MessageLookupByLibrary.simpleMessage(
      "Switch core version",
    ),
    "libUse": MessageLookupByLibrary.simpleMessage("Use"),
    "libraryVersion": MessageLookupByLibrary.simpleMessage("Library version"),
    "libraryVersionDesc": MessageLookupByLibrary.simpleMessage(
      "Download and switch the mihomo core version",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to local",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Recover data from file",
    ),
    "locationPermissionExplanation": MessageLookupByLibrary.simpleMessage(
      "To detect the name of your Wi-Fi network, Android requires location permission. We use it only to read the SSID and do not store any coordinates.",
    ),
    "locationPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Permission is granted, but Location is turned off on the device. Turn on Location in system settings so the Wi-Fi network name can be read.",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "loggingDesc": MessageLookupByLibrary.simpleMessage(
      "Logcat verbosity, file sink, in-app buffer",
    ),
    "loggingFileEnabled": MessageLookupByLibrary.simpleMessage(
      "Write log file",
    ),
    "loggingFileEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "Append events to a rotated file under the app\'s external dir",
    ),
    "loggingFileLevel": MessageLookupByLibrary.simpleMessage("File level"),
    "loggingFileLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Filter for the persistent file sink",
    ),
    "loggingFilePathLabel": MessageLookupByLibrary.simpleMessage("File path"),
    "loggingFileRotationHint": MessageLookupByLibrary.simpleMessage(
      "Rotates at 5 MB, keeps 5 files (.log + .1 .. .4)",
    ),
    "loggingFileSection": MessageLookupByLibrary.simpleMessage(
      "Persistent file",
    ),
    "loggingHintAdb": MessageLookupByLibrary.simpleMessage(
      "ADB tip: adb pull <file path> to fetch the log to your machine without root",
    ),
    "loggingInAppSection": MessageLookupByLibrary.simpleMessage(
      "In-app viewer",
    ),
    "loggingLogcatLevel": MessageLookupByLibrary.simpleMessage("Logcat level"),
    "loggingLogcatLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Filter for the always-on logcat sink. View via: adb logcat -s libclash:V libclash-stderr:V proxy:V FlClash:V flutter:V",
    ),
    "loggingLogcatSection": MessageLookupByLibrary.simpleMessage(
      "Android logcat (adb)",
    ),
    "loggingOpenViewer": MessageLookupByLibrary.simpleMessage(
      "Open log viewer",
    ),
    "loggingSourceLevel": MessageLookupByLibrary.simpleMessage(
      "Source log level",
    ),
    "loggingSourceLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Maximum verbosity mihomo emits. Per-sink filters below cannot raise above this.",
    ),
    "loggingSourceSection": MessageLookupByLibrary.simpleMessage("Source"),
    "loggingTitle": MessageLookupByLibrary.simpleMessage("Logging"),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Log capture records"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback unlocking",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Minimize instead of exit",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Back button sends the app to background instead of closing it",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesAgo": m14,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "months": MessageLookupByLibrary.simpleMessage("Months"),
    "monthsAgo": m15,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving domain",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the corresponding nameserver policy",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Modify network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network exception, please check your connection and try again",
    ),
    "networkRulesActionLeave": MessageLookupByLibrary.simpleMessage("Keep VPN"),
    "networkRulesActionNoProfile": MessageLookupByLibrary.simpleMessage(
      "Don\'t switch",
    ),
    "networkRulesActionProfile": MessageLookupByLibrary.simpleMessage(
      "Profile",
    ),
    "networkRulesActionShortLeave": MessageLookupByLibrary.simpleMessage(
      "KEEP",
    ),
    "networkRulesActionShortOff": MessageLookupByLibrary.simpleMessage("OFF"),
    "networkRulesActionShortOn": MessageLookupByLibrary.simpleMessage("ON"),
    "networkRulesActionTurnOff": MessageLookupByLibrary.simpleMessage(
      "Turn VPN off",
    ),
    "networkRulesActionTurnOn": MessageLookupByLibrary.simpleMessage(
      "Turn VPN on",
    ),
    "networkRulesAdd": MessageLookupByLibrary.simpleMessage("Add rule"),
    "networkRulesAddCondition": MessageLookupByLibrary.simpleMessage(
      "Add condition",
    ),
    "networkRulesConditionAnyCellular": MessageLookupByLibrary.simpleMessage(
      "Cellular",
    ),
    "networkRulesConditionAnyEthernet": MessageLookupByLibrary.simpleMessage(
      "Ethernet",
    ),
    "networkRulesConditionAnyProfile": MessageLookupByLibrary.simpleMessage(
      "Any profile",
    ),
    "networkRulesConditionAnyWifi": MessageLookupByLibrary.simpleMessage(
      "Any Wi-Fi",
    ),
    "networkRulesConditionEdit": MessageLookupByLibrary.simpleMessage(
      "Edit condition",
    ),
    "networkRulesConditionNegate": MessageLookupByLibrary.simpleMessage(
      "Not (invert)",
    ),
    "networkRulesConditionProfileGate": MessageLookupByLibrary.simpleMessage(
      "Only on profile",
    ),
    "networkRulesConditionProfileIs": MessageLookupByLibrary.simpleMessage(
      "Profile: ",
    ),
    "networkRulesConditionWifiNamed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi named",
    ),
    "networkRulesConditionsLabel": MessageLookupByLibrary.simpleMessage(
      "Conditions",
    ),
    "networkRulesConfirmDelete": MessageLookupByLibrary.simpleMessage(
      "Delete this rule?",
    ),
    "networkRulesDefaultActionTitle": MessageLookupByLibrary.simpleMessage(
      "When no rule matches",
    ),
    "networkRulesDefaultLeave": MessageLookupByLibrary.simpleMessage(
      "Leave unchanged",
    ),
    "networkRulesDefaultTurnOff": MessageLookupByLibrary.simpleMessage(
      "Turn VPN off",
    ),
    "networkRulesDefaultTurnOn": MessageLookupByLibrary.simpleMessage(
      "Turn VPN on",
    ),
    "networkRulesDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "networkRulesDisable": MessageLookupByLibrary.simpleMessage("Disable"),
    "networkRulesEdit": MessageLookupByLibrary.simpleMessage("Edit"),
    "networkRulesEmpty": MessageLookupByLibrary.simpleMessage(
      "Add your first rule",
    ),
    "networkRulesEnable": MessageLookupByLibrary.simpleMessage(
      "Enable network rules",
    ),
    "networkRulesEnableShort": MessageLookupByLibrary.simpleMessage("Enable"),
    "networkRulesInvalidRule": MessageLookupByLibrary.simpleMessage(
      "Unsupported condition, update the app",
    ),
    "networkRulesJoinAnd": MessageLookupByLibrary.simpleMessage("AND"),
    "networkRulesJoinOr": MessageLookupByLibrary.simpleMessage("OR"),
    "networkRulesMatchAll": MessageLookupByLibrary.simpleMessage("Match all"),
    "networkRulesMatchAny": MessageLookupByLibrary.simpleMessage("Match any"),
    "networkRulesNetNone": MessageLookupByLibrary.simpleMessage("No network"),
    "networkRulesNetWifi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "networkRulesNetWifiNamed": m16,
    "networkRulesOverrideActive": MessageLookupByLibrary.simpleMessage(
      "Manual choice kept until the network changes",
    ),
    "networkRulesPermissionBanner": MessageLookupByLibrary.simpleMessage(
      "Network rules need Wi-Fi permission to match SSIDs",
    ),
    "networkRulesStatusLabel": MessageLookupByLibrary.simpleMessage(
      "Current decision",
    ),
    "networkRulesTitle": MessageLookupByLibrary.simpleMessage("Network rules"),
    "networkRulesVpnKeep": MessageLookupByLibrary.simpleMessage("Keep"),
    "networkRulesVpnOff": MessageLookupByLibrary.simpleMessage("Off"),
    "networkRulesVpnOn": MessageLookupByLibrary.simpleMessage("On"),
    "networkRulesWifiMatchContains": MessageLookupByLibrary.simpleMessage(
      "Contains",
    ),
    "networkRulesWifiMatchExact": MessageLookupByLibrary.simpleMessage("Exact"),
    "networkRulesWifiMatchPrefix": MessageLookupByLibrary.simpleMessage(
      "Starts with",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No HotKey"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No network APP"),
    "noResolve": MessageLookupByLibrary.simpleMessage("No resolve IP"),
    "none": MessageLookupByLibrary.simpleMessage("none"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profile, Please add a profile",
    ),
    "nullTip": m17,
    "numberTip": m18,
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open settings"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override Dns"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Turning it on will override the DNS options in the profile",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "permissionAllow": MessageLookupByLibrary.simpleMessage("Allow"),
    "permissionNotNow": MessageLookupByLibrary.simpleMessage("Not now"),
    "permissionRequiredHint": MessageLookupByLibrary.simpleMessage(
      "Permission required",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter the admin password",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m19,
    "preferH3": MessageLookupByLibrary.simpleMessage("Prefer H3"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prioritize the use of DOH\'s http/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Please press the keyboard.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy & Security",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAppAccess": MessageLookupByLibrary.simpleMessage("App access"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please input a valid interval time format",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto update interval time",
        ),
    "profileGroupCount": m20,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Do you want to disable auto update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile name",
    ),
    "profileNodeCount": m21,
    "profileProvidersLimits": m22,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Profiles sort"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providerBehavior": MessageLookupByLibrary.simpleMessage("Behavior"),
    "providerDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete this provider?",
    ),
    "providerEveryN": m23,
    "providerFormat": MessageLookupByLibrary.simpleMessage("Format"),
    "providerHealthCheck": MessageLookupByLibrary.simpleMessage("Health-check"),
    "providerHealthCheckEnable": MessageLookupByLibrary.simpleMessage(
      "Check availability",
    ),
    "providerNameExists": MessageLookupByLibrary.simpleMessage(
      "A provider with this name already exists",
    ),
    "providerNew": MessageLookupByLibrary.simpleMessage("New provider"),
    "providerPath": MessageLookupByLibrary.simpleMessage("Path"),
    "providerSource": MessageLookupByLibrary.simpleMessage("Source"),
    "providerSourceFile": MessageLookupByLibrary.simpleMessage("File"),
    "providerSourceHttp": MessageLookupByLibrary.simpleMessage("Subscription"),
    "providerSourceInline": MessageLookupByLibrary.simpleMessage("Inline"),
    "providerSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "Subscription URL",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chains"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("Proxy groups"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Domain for resolving proxy nodes",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan QR code to obtain profile",
    ),
    "quickStartFailedBody": MessageLookupByLibrary.simpleMessage(
      "The key connected, but no page would load.",
    ),
    "quickStartFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t reach the internet through this key",
    ),
    "quickStartImported": MessageLookupByLibrary.simpleMessage("Imported"),
    "quickStartNoServers": MessageLookupByLibrary.simpleMessage(
      "No servers found in what you pasted",
    ),
    "quickStartPasteHint": MessageLookupByLibrary.simpleMessage(
      "Paste the link, QR, or code your provider sent you",
    ),
    "quickStartPasteKey": MessageLookupByLibrary.simpleMessage(
      "Paste your key",
    ),
    "quickStartTryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
    "quickStartUseDifferent": MessageLookupByLibrary.simpleMessage(
      "Use a different key",
    ),
    "quickStartVerified": MessageLookupByLibrary.simpleMessage("verified"),
    "quickStartVerifying": MessageLookupByLibrary.simpleMessage(
      "Checking your connection...",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "recovery": MessageLookupByLibrary.simpleMessage("Recovery"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Recover all data"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Recover profiles only",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage(
      "Recovery succeeded",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir Port"),
    "redo": MessageLookupByLibrary.simpleMessage("redo"),
    "regExp": MessageLookupByLibrary.simpleMessage("RegExp"),
    "releases": MessageLookupByLibrary.simpleMessage("Releases"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Recover data from WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recently request records",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "The current page has changes. Are you sure you want to reset?",
    ),
    "resetSection": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetTip": MessageLookupByLibrary.simpleMessage("Make sure to reset"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "External resource related info",
    ),
    "resourcesUpToDate": MessageLookupByLibrary.simpleMessage(
      "Resources up to date",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connection following rules, need to configure proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restartVpnToApply": MessageLookupByLibrary.simpleMessage(
      "Restart VPN to apply the new app list.",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Recovery exception",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via WebDAV",
    ),
    "restoreOnlyProfiles": MessageLookupByLibrary.simpleMessage(
      "Restore profiles only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("Restore success"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route address"),
    "routeAddressBypassPrivateHint": MessageLookupByLibrary.simpleMessage(
      "Not used in Bypass private mode",
    ),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Config listen route address",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private route address",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Use config"),
    "routingAddCondition": MessageLookupByLibrary.simpleMessage(
      "Add condition",
    ),
    "routingAddList": MessageLookupByLibrary.simpleMessage("Add list"),
    "routingAddRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "routingAddServer": MessageLookupByLibrary.simpleMessage("Add server"),
    "routingAdvanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "routingAdvancedEditors": MessageLookupByLibrary.simpleMessage(
      "Power-user editors",
    ),
    "routingAdvancedKeys": MessageLookupByLibrary.simpleMessage(
      "Advanced keys",
    ),
    "routingAdvancedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Groups, sub-rules, raw rules and YAML",
    ),
    "routingAppBypass": MessageLookupByLibrary.simpleMessage("Bypass VPN"),
    "routingApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t apply the change",
    ),
    "routingApps": MessageLookupByLibrary.simpleMessage("Apps"),
    "routingHideSystemApps": MessageLookupByLibrary.simpleMessage(
      "Hide system apps",
    ),
    "routingSkippedNodes": MessageLookupByLibrary.simpleMessage(
      "Some nodes of an unsupported type were skipped",
    ),
    "routingAppsCardTitle": MessageLookupByLibrary.simpleMessage(
      "Default for new and unset apps:",
    ),
    "routingAppsRuleBlacklist": MessageLookupByLibrary.simpleMessage(
      "All apps go through the VPN. Only the ones marked below bypass it. New apps go through the VPN by default; move banking and government apps off it manually.",
    ),
    "routingAppsRuleWhitelist": MessageLookupByLibrary.simpleMessage(
      "Only apps in the list below go through the VPN. Everything else, including new apps, stays off the VPN and cannot see it.",
    ),
    "routingAppsSectionChanged": MessageLookupByLibrary.simpleMessage(
      "Changed",
    ),
    "routingAppsSectionRest": MessageLookupByLibrary.simpleMessage(
      "Others · default",
    ),
    "routingAppsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Which apps use the VPN and how",
    ),
    "routingBehaviorClassical": MessageLookupByLibrary.simpleMessage(
      "Mixed rules",
    ),
    "routingBehaviorDomain": MessageLookupByLibrary.simpleMessage("Domains"),
    "routingBehaviorIpcidr": MessageLookupByLibrary.simpleMessage("IP ranges"),
    "routingBlock": MessageLookupByLibrary.simpleMessage("Block"),
    "routingBuild": MessageLookupByLibrary.simpleMessage("Build"),
    "routingCheckedTopToBottom": MessageLookupByLibrary.simpleMessage(
      "Checked top to bottom",
    ),
    "routingConditions": MessageLookupByLibrary.simpleMessage("Conditions"),
    "routingConnection": MessageLookupByLibrary.simpleMessage("Connection"),
    "routingCountryOther": MessageLookupByLibrary.simpleMessage("Other code"),
    "routingCountryOtherHint": MessageLookupByLibrary.simpleMessage(
      "ISO code or geo tag (e.g. private)",
    ),
    "routingCreateGroup": MessageLookupByLibrary.simpleMessage("Create group"),
    "routingEditGroup": MessageLookupByLibrary.simpleMessage("Edit group"),
    "routingEditProxy": MessageLookupByLibrary.simpleMessage("Edit server"),
    "routingEverythingElse": MessageLookupByLibrary.simpleMessage(
      "Everything else",
    ),
    "routingGlobalRules": MessageLookupByLibrary.simpleMessage("Global rules"),
    "routingGlobalRulesCount": m24,
    "routingGroupAuto": MessageLookupByLibrary.simpleMessage("Auto (fastest)"),
    "routingGroupBehavior": MessageLookupByLibrary.simpleMessage("Mode"),
    "routingGroupFailover": MessageLookupByLibrary.simpleMessage("Failover"),
    "routingGroupFilter": MessageLookupByLibrary.simpleMessage(
      "Filter (regex)",
    ),
    "routingGroupFilterHint": MessageLookupByLibrary.simpleMessage(
      "e.g. main|premium",
    ),
    "routingGroupHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "routingGroupInterval": MessageLookupByLibrary.simpleMessage(
      "Test interval (seconds)",
    ),
    "routingGroupLazy": MessageLookupByLibrary.simpleMessage("Lazy testing"),
    "routingGroupManual": MessageLookupByLibrary.simpleMessage("Manual pick"),
    "routingGroupNameHint": MessageLookupByLibrary.simpleMessage("Group name"),
    "routingGroupSource": MessageLookupByLibrary.simpleMessage("Source"),
    "routingGroupSourceServers": MessageLookupByLibrary.simpleMessage(
      "Pick servers",
    ),
    "routingGroupSourceSubscription": MessageLookupByLibrary.simpleMessage(
      "From a subscription",
    ),
    "routingGroupTestUrl": MessageLookupByLibrary.simpleMessage(
      "Health-check URL",
    ),
    "routingGroupTolerance": MessageLookupByLibrary.simpleMessage(
      "Tolerance (ms)",
    ),
    "routingGroupVia": m25,
    "routingGroups": MessageLookupByLibrary.simpleMessage("Groups"),
    "routingGroupsSubtitle": MessageLookupByLibrary.simpleMessage(
      "How servers are chosen",
    ),
    "routingImportFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t read that link",
    ),
    "routingListBehavior": MessageLookupByLibrary.simpleMessage("Match type"),
    "routingListByCountry": MessageLookupByLibrary.simpleMessage("By country"),
    "routingListCount": m26,
    "routingListFromLink": MessageLookupByLibrary.simpleMessage("Custom link"),
    "routingListName": MessageLookupByLibrary.simpleMessage("List name"),
    "routingListPasted": MessageLookupByLibrary.simpleMessage("Pasted domains"),
    "routingLists": MessageLookupByLibrary.simpleMessage("Lists"),
    "routingLogicAll": MessageLookupByLibrary.simpleMessage("All of"),
    "routingLogicAny": MessageLookupByLibrary.simpleMessage("Any of"),
    "routingLogicNone": MessageLookupByLibrary.simpleMessage("None of"),
    "routingLogicOperator": MessageLookupByLibrary.simpleMessage("Match when"),
    "routingMatchValueHint": MessageLookupByLibrary.simpleMessage(
      "domain, IP range, country or app",
    ),
    "routingMatcherApp": MessageLookupByLibrary.simpleMessage("App"),
    "routingMatcherAppPath": MessageLookupByLibrary.simpleMessage("App path"),
    "routingMatcherAppPathRegex": MessageLookupByLibrary.simpleMessage(
      "App path regex",
    ),
    "routingMatcherAppPathWildcard": MessageLookupByLibrary.simpleMessage(
      "App path wildcard",
    ),
    "routingMatcherAppRegex": MessageLookupByLibrary.simpleMessage(
      "App name regex",
    ),
    "routingMatcherAppWildcard": MessageLookupByLibrary.simpleMessage(
      "App name wildcard",
    ),
    "routingMatcherAsn": MessageLookupByLibrary.simpleMessage(
      "Network operator (ASN)",
    ),
    "routingMatcherCatApp": MessageLookupByLibrary.simpleMessage(
      "App / process",
    ),
    "routingMatcherCatConnection": MessageLookupByLibrary.simpleMessage(
      "Connection",
    ),
    "routingMatcherCatDestIp": MessageLookupByLibrary.simpleMessage(
      "Destination IP",
    ),
    "routingMatcherCatDomain": MessageLookupByLibrary.simpleMessage(
      "Domain / website",
    ),
    "routingMatcherCatSource": MessageLookupByLibrary.simpleMessage("Source"),
    "routingMatcherDomain": MessageLookupByLibrary.simpleMessage("Domain"),
    "routingMatcherDomainKeyword": MessageLookupByLibrary.simpleMessage(
      "Domain keyword",
    ),
    "routingMatcherDomainRegex": MessageLookupByLibrary.simpleMessage(
      "Domain regex",
    ),
    "routingMatcherDomainSuffix": MessageLookupByLibrary.simpleMessage(
      "Domain suffix",
    ),
    "routingMatcherDomainWildcard": MessageLookupByLibrary.simpleMessage(
      "Domain wildcard",
    ),
    "routingMatcherDstPort": MessageLookupByLibrary.simpleMessage(
      "Destination port",
    ),
    "routingMatcherGeoip": MessageLookupByLibrary.simpleMessage(
      "Country (GeoIP)",
    ),
    "routingMatcherGeosite": MessageLookupByLibrary.simpleMessage(
      "Geo category",
    ),
    "routingMatcherIp": MessageLookupByLibrary.simpleMessage("IP range"),
    "routingMatcherIpSuffix": MessageLookupByLibrary.simpleMessage("IP suffix"),
    "routingMatcherIpV6": MessageLookupByLibrary.simpleMessage(
      "IP range (IPv6)",
    ),
    "routingMatcherNetwork": MessageLookupByLibrary.simpleMessage(
      "Network (tcp/udp)",
    ),
    "routingMatcherSrcAsn": MessageLookupByLibrary.simpleMessage("Source ASN"),
    "routingMatcherSrcGeoip": MessageLookupByLibrary.simpleMessage(
      "Source country",
    ),
    "routingMatcherSrcIp": MessageLookupByLibrary.simpleMessage(
      "Source IP range",
    ),
    "routingMatcherSrcIpSuffix": MessageLookupByLibrary.simpleMessage(
      "Source IP suffix",
    ),
    "routingMatcherSrcPort": MessageLookupByLibrary.simpleMessage(
      "Source port",
    ),
    "routingMatcherType": MessageLookupByLibrary.simpleMessage("Match by"),
    "routingMatcherUid": MessageLookupByLibrary.simpleMessage("User ID (UID)"),
    "routingModeSwitchTitle": MessageLookupByLibrary.simpleMessage(
      "Switch mode?",
    ),
    "routingModeSwitchToBypassBody": MessageLookupByLibrary.simpleMessage(
      "After the switch, only apps you mark go through the VPN; everything else stays off it. Connections drop for a second. Continue?",
    ),
    "routingModeSwitchToVpnBody": MessageLookupByLibrary.simpleMessage(
      "After the switch, new and unmarked apps, including banking and government apps you haven\'t moved off, will go through the VPN. Connections drop for a second. Continue?",
    ),
    "routingNewScenario": MessageLookupByLibrary.simpleMessage("New scenario"),
    "routingNoGroups": MessageLookupByLibrary.simpleMessage("No groups yet"),
    "routingNoLists": MessageLookupByLibrary.simpleMessage("No lists yet"),
    "routingNoResolveOff": MessageLookupByLibrary.simpleMessage(
      "Resolve domains first",
    ),
    "routingNoResolveOffDesc": MessageLookupByLibrary.simpleMessage(
      "Look up the IP before matching",
    ),
    "routingNoResolveOn": MessageLookupByLibrary.simpleMessage("Match IP only"),
    "routingNoResolveOnDesc": MessageLookupByLibrary.simpleMessage(
      "Do not resolve domains (no-resolve)",
    ),
    "routingNoResolveTitle": MessageLookupByLibrary.simpleMessage(
      "DNS resolution",
    ),
    "routingNoScenarios": MessageLookupByLibrary.simpleMessage(
      "No scenarios yet",
    ),
    "routingNoServers": MessageLookupByLibrary.simpleMessage("No servers yet"),
    "routingPasteHint": MessageLookupByLibrary.simpleMessage(
      "One domain per line",
    ),
    "routingPickList": MessageLookupByLibrary.simpleMessage("Choose a list"),
    "routingProxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "routingProxiesSubtitle": MessageLookupByLibrary.simpleMessage(
      "Servers and subscriptions",
    ),
    "routingProxyNested": MessageLookupByLibrary.simpleMessage(
      "Nested fields below are kept as-is; edit them in raw YAML.",
    ),
    "routingRawGroupHint": MessageLookupByLibrary.simpleMessage(
      "This group is advanced; edit it in raw YAML",
    ),
    "routingRename": MessageLookupByLibrary.simpleMessage("Rename"),
    "routingRuleByList": MessageLookupByLibrary.simpleMessage("By list"),
    "routingRuleByMatcher": MessageLookupByLibrary.simpleMessage("By matcher"),
    "routingRuleCombined": MessageLookupByLibrary.simpleMessage(
      "Combined condition",
    ),
    "routingRules": MessageLookupByLibrary.simpleMessage("Routing rules"),
    "routingScenarioCount": m27,
    "routingScenarioName": MessageLookupByLibrary.simpleMessage(
      "Scenario name",
    ),
    "routingScenarioRuleCount": m28,
    "routingScenarios": MessageLookupByLibrary.simpleMessage("Scenarios"),
    "routingSearchHint": MessageLookupByLibrary.simpleMessage("Search"),
    "routingSendTo": MessageLookupByLibrary.simpleMessage("Send to"),
    "routingServerAdded": MessageLookupByLibrary.simpleMessage("Server added"),
    "routingServerCount": m29,
    "routingServerHint": MessageLookupByLibrary.simpleMessage(
      "Paste a link or subscription URL",
    ),
    "routingServers": MessageLookupByLibrary.simpleMessage("Servers"),
    "routingServersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Where your traffic exits",
    ),
    "routingSetAsExit": MessageLookupByLibrary.simpleMessage(
      "Use as active exit",
    ),
    "routingSourceCountry": MessageLookupByLibrary.simpleMessage("By country"),
    "routingSourceLink": MessageLookupByLibrary.simpleMessage("By link"),
    "routingSourcePaste": MessageLookupByLibrary.simpleMessage("Paste domains"),
    "routingSubscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "routingSubscriptionAdded": MessageLookupByLibrary.simpleMessage(
      "Subscription added",
    ),
    "routingSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "Subscription URL",
    ),
    "routingViaVpn": MessageLookupByLibrary.simpleMessage("Via VPN"),
    "routingWhatToBlock": MessageLookupByLibrary.simpleMessage("What to block"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleAddClause": MessageLookupByLibrary.simpleMessage("Add condition"),
    "ruleBlockInvalid": MessageLookupByLibrary.simpleMessage(
      "Add at least one condition and a target",
    ),
    "ruleBlockOperator": MessageLookupByLibrary.simpleMessage("Operator"),
    "ruleBlockTitle": MessageLookupByLibrary.simpleMessage("Logical rule"),
    "ruleConditionParams": MessageLookupByLibrary.simpleMessage("Parameters"),
    "ruleConditionType": MessageLookupByLibrary.simpleMessage("Condition"),
    "ruleConditions": MessageLookupByLibrary.simpleMessage("Conditions"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleNameOptional": MessageLookupByLibrary.simpleMessage("Name (optional)"),
    "ruleOpAnd": MessageLookupByLibrary.simpleMessage("AND"),
    "ruleOpNot": MessageLookupByLibrary.simpleMessage("NOT"),
    "ruleOpOr": MessageLookupByLibrary.simpleMessage("OR"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "ruleTargetPick": MessageLookupByLibrary.simpleMessage("Pick target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Do you want to save the changes?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode, use external extension scripts, provide one-click override configuration capability",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m30,
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "shrink": MessageLookupByLibrary.simpleMessage("Shrink"),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks Port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("special rules"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode, override basic configuration, provide simple rule addition capability",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "System DNS will be used when turned off",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub rule"),
    "subRuleDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete this sub-rule?",
    ),
    "subRuleNameExists": MessageLookupByLibrary.simpleMessage(
      "A sub-rule with this name already exists",
    ),
    "subRuleNew": MessageLookupByLibrary.simpleMessage("New sub-rule"),
    "subRuleRename": MessageLookupByLibrary.simpleMessage("Rename sub-rule"),
    "subRuleRuleCount": m31,
    "subRules": MessageLookupByLibrary.simpleMessage("Sub-rules"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System APP"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Smooth slide between tabs (mobile layout only)",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling it will allow TCP concurrency",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test url"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text Scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode,adjust the color",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "tip": MessageLookupByLibrary.simpleMessage("tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("TonalSpot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "only effective in administrator mode",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn Off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn On"),
    "undo": MessageLookupByLibrary.simpleMessage("undo"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain profile through URL",
    ),
    "urlTip": m32,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "userInterface": MessageLookupByLibrary.simpleMessage("User interface"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Auto routes all system traffic through VpnService",
    ),
    "vpnSettings": MessageLookupByLibrary.simpleMessage("VPN settings"),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "years": MessageLookupByLibrary.simpleMessage("Years"),
    "yearsAgo": m33,
    "zh_CN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
    "zoom": MessageLookupByLibrary.simpleMessage("Zoom"),
  };
}
