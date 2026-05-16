import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

enum ByeDpiMode { manual, auto }

enum ByeDpiPreset {
  universal,
  tele2,
  mrDrone,
  antiGgc,
  custom,
}

const Map<ByeDpiPreset, String> byeDpiPresetArgs = {
  ByeDpiPreset.universal: '--disorder 1 --auto=t,r,s --tlsrec 1+s',
  ByeDpiPreset.tele2: '--disorder 1 --auto=t,r,s --fake 2',
  ByeDpiPreset.mrDrone:
      '-Ku -a3 -An -Kt,h -s0 -o1 -d1 -r1+s -Ar -o1 -At -f-1 -r1+s -As -b+500',
  ByeDpiPreset.antiGgc: '--split 3 --oob 1 --disorder 3 --auto=t,r,s',
};

String effectiveByeDpiCliArgs(ByeDpiSettings s) =>
    s.preset == ByeDpiPreset.custom
        ? s.cliArgs
        : (byeDpiPresetArgs[s.preset] ?? '');

@freezed
abstract class ByeDpiSettings with _$ByeDpiSettings {
  const factory ByeDpiSettings({
    @Default(false) bool enabled,
    @Default(ByeDpiMode.auto) ByeDpiMode mode,
    @Default(true) bool fallbackEnabled,
    @Default('') String fallbackGroup,
    @Default(1080) int port,
    @Default(ByeDpiPreset.universal) ByeDpiPreset preset,
    @Default('--disorder 1 --auto=t,r,s --tlsrec 1+s') String cliArgs,
  }) = _ByeDpiSettings;

  factory ByeDpiSettings.fromJson(Map<String, Object?> json) =>
      _$ByeDpiSettingsFromJson(json);
}
