// The rules mirror: Dart atomically writes the full rule set + settings to a
// JSON file in the clash home dir (Android filesDir) on every change; the
// resident reads it as its source of truth. Schema mirrored by NetworkRulesCodec.kt.

import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:path/path.dart';

import 'model.dart';

const networkRulesMirrorFileName = 'network-rules.json';
const networkRulesMirrorVersion = 3;

String encodeNetworkRulesMirror({
  required bool enabled,
  required DefaultNetworkAction defaultAction,
  required List<NetworkRule> rules,
  Map<int, Map<String, String>> selectedMaps = const {},
  Map<int, String> profileNames = const {},
  int? activeProfileId,
}) {
  return jsonEncode({
    'version': networkRulesMirrorVersion,
    'enabled': enabled,
    'defaultAction': defaultAction.name,
    if (activeProfileId != null) 'activeProfileId': activeProfileId,
    'rules': [
      for (final r in rules)
        {
          'id': r.id,
          'name': r.name,
          'match': r.matchMode.name,
          // Legacy on/off field for a downgraded resident (kept one release).
          'action': r.action.vpn == NetworkVpnMode.turnOff
              ? 'turnOff'
              : 'turnOn',
          'actionVpn': r.action.vpn.name,
          if (r.action.profileId != null) 'actionProfileId': r.action.profileId,
          if (r.action.profileId != null &&
              selectedMaps[r.action.profileId] != null)
            'actionSelectedMap': selectedMaps[r.action.profileId],
          if (r.action.profileId != null &&
              profileNames[r.action.profileId] != null)
            'actionProfileName': profileNames[r.action.profileId],
          'priority': r.priority,
          'enabled': r.enabled,
          'conditions': [for (final c in r.conditions) c.toJson()],
        },
    ],
  });
}

Future<void> writeNetworkRulesMirror(String homeDir, String content) async {
  final tmp = File(join(homeDir, '$networkRulesMirrorFileName.tmp'));
  await tmp.writeAsString(content, flush: true);
  await tmp.rename(join(homeDir, networkRulesMirrorFileName));
}
