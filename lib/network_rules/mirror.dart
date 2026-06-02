// The rules mirror: Dart writes the full rule set + settings to a JSON file in
// the clash home dir (== Android filesDir) atomically on every change; the
// resident Kotlin service reads it as the single source of truth in the
// background. Schema mirrored by NetworkRulesCodec.kt.

import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:path/path.dart';

import 'model.dart';

const networkRulesMirrorFileName = 'network-rules.json';
const networkRulesMirrorVersion = 1;

String encodeNetworkRulesMirror({
  required bool enabled,
  required DefaultNetworkAction defaultAction,
  required List<NetworkRule> rules,
}) {
  return jsonEncode({
    'version': networkRulesMirrorVersion,
    'enabled': enabled,
    'defaultAction': defaultAction.name,
    'rules': [
      for (final r in rules)
        {
          'id': r.id,
          'name': r.name,
          'action': r.action.name,
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
