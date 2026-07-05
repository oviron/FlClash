import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';

/// Display label for the profile [id]: its non-empty label, else `#id`, else
/// [nullLabel] when [id] is null.
String profileLabel(
  List<Profile> profiles,
  int? id, {
  required String nullLabel,
}) {
  if (id == null) return nullLabel;
  final match = profiles.where((p) => p.id == id);
  return match.isNotEmpty && match.first.label.isNotEmpty
      ? match.first.label
      : '#$id';
}

/// A Wi-Fi SSID matcher label: exact / prefix (`ssid…`) / contains (`…ssid…`).
String wifiPatternLabel(WifiNamed c) => switch (c.match) {
  WifiMatch.exact => c.ssid,
  WifiMatch.prefix => '${c.ssid}…',
  WifiMatch.contains => '…${c.ssid}…',
};
