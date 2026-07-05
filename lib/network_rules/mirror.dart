// Dart writes the full rule set + settings to a JSON file the resident reads as
// its source of truth (schema mirrored by NetworkRulesCodec.kt).

import 'dart:async';
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
          // leave maps to turnOff so a stale resident fails safe (never auto-starts).
          'action': r.action.vpn == NetworkVpnMode.turnOn
              ? 'turnOn'
              : 'turnOff',
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

/// Serializes mirror writes so the newest state always commits last: while a
/// write runs, further requests coalesce into a single trailing run that reads
/// the freshest state. [schedule]'s future resolves once that state (or newer)
/// is committed. [rebake] flags a request that needs the expensive cache
/// rebuild; the trailing run inherits it if any coalesced request set it.
class MirrorWriteQueue {
  Future<void>? _running;
  bool _pending = false;
  bool _rebakePending = false;

  Future<void> schedule(
    Future<void> Function({required bool rebake}) run, {
    required bool rebake,
  }) {
    _rebakePending = _rebakePending || rebake;
    if (_running != null) {
      _pending = true;
      return _running!;
    }
    return _running = _drain(run);
  }

  Future<void> _drain(Future<void> Function({required bool rebake}) run) async {
    try {
      do {
        _pending = false;
        final rebake = _rebakePending;
        _rebakePending = false;
        await run(rebake: rebake);
      } while (_pending);
    } finally {
      _running = null;
    }
  }
}

int _mirrorWriteSeq = 0;

Future<void> writeNetworkRulesMirror(String homeDir, String content) async {
  final dir = Directory(homeDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  // Unique temp per write: concurrent _onRulesChanged calls would otherwise
  // share one `.tmp`, and the second rename fails (the source was already moved).
  final tmp = File(
    join(homeDir, '$networkRulesMirrorFileName.${_mirrorWriteSeq++}.tmp'),
  );
  try {
    await tmp.writeAsString(content, flush: true);
    await tmp.rename(join(homeDir, networkRulesMirrorFileName));
  } catch (_) {
    if (await tmp.exists()) {
      await tmp.delete();
    }
    rethrow;
  }
}
