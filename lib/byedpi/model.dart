import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

enum ByeDpiMode { manual, auto }

// `custom` is not a JSON strategy: it surfaces the user's own cliArgs.
const kByeDpiCustomId = 'custom';
const kByeDpiDefaultId = 'universal';
const kByeDpiDefaultArgs = '-o1 -a1 -r-5+se';

class ByeDpiStrategy {
  final String id;
  final String label;
  final String args;

  const ByeDpiStrategy({
    required this.id,
    required this.label,
    required this.args,
  });

  factory ByeDpiStrategy.fromJson(Map<String, dynamic> json) => ByeDpiStrategy(
    id: json['id'] as String,
    label: (json['label'] ?? json['id']) as String,
    args: json['args'] as String? ?? '',
  );
}

// Args resolve from the loaded strategy set (byedpi-strategies.json); `custom`
// uses the user's cliArgs. Falls back to the default args if the id is absent
// (e.g. asset failed to load).
String effectiveByeDpiCliArgs(ByeDpiSettings s, Map<String, String> argsById) =>
    s.preset == kByeDpiCustomId
    ? s.cliArgs
    : (argsById[s.preset] ?? kByeDpiDefaultArgs);

@freezed
abstract class ByeDpiSettings with _$ByeDpiSettings {
  const factory ByeDpiSettings({
    @Default(false) bool enabled,
    @Default(ByeDpiMode.auto) ByeDpiMode mode,
    @Default(true) bool fallbackEnabled,
    @Default('') String fallbackGroup,
    @Default(1080) int port,
    @Default(kByeDpiDefaultId) String preset,
    @Default(kByeDpiDefaultArgs) String cliArgs,
  }) = _ByeDpiSettings;

  factory ByeDpiSettings.fromJson(Map<String, Object?> json) =>
      _$ByeDpiSettingsFromJson(json);
}
