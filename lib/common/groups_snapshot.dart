import 'dart:convert';

import 'package:fl_clash/models/models.dart';

// A proxy-group list persisted per profile so the Proxies screen can hydrate
// instantly on cold start, before the core has loaded. It is a disposable cache:
// the first live updateGroups() overwrites it, and any decode failure is ignored.

String encodeGroupsSnapshot(List<Group> groups) =>
    json.encode(groups.map((group) => group.toJson()).toList());

List<Group> decodeGroupsSnapshot(String raw) {
  try {
    final data = json.decode(raw);
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Group.fromJson(Map<String, Object?>.from(e)))
        .toList();
  } catch (_) {
    return const [];
  }
}
