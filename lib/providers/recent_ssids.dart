// Most-recent-seen Wi-Fi names for the rule editor's SSID picker.
// Not persisted across app restarts on purpose: the engine never reads
// it, and a 20-entry list does not need disk.

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/recent_ssids.g.dart';

const int _maxRecentSsids = 20;

@Riverpod(keepAlive: true)
class RecentSsids extends _$RecentSsids {
  @override
  List<String> build() => const [];

  /// Push [ssid] to the front of the list. Any prior occurrence (compared
  /// case-insensitively) is removed first. The list is capped at 20 entries.
  void observe(String ssid) {
    final lower = ssid.toLowerCase();
    final next = <String>[ssid];
    for (final existing in state) {
      if (existing.toLowerCase() == lower) continue;
      next.add(existing);
      if (next.length >= _maxRecentSsids) break;
    }
    state = next;
  }
}
