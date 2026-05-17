import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

enum ByeDpiMode { manual, auto }

enum ByeDpiPreset {
  universal,
  mrDrone,
  mtsAggressive,
  megafon2ni,
  tele2,
  beelineRt,
  antiGgc,
  cascade,
  tlsOnly,
  ttlFixed,
  custom,
}

const Map<ByeDpiPreset, String> byeDpiPresetArgs = {
  ByeDpiPreset.universal: '--disorder 1 --auto=t,r,s --tlsrec 1+s',
  ByeDpiPreset.mrDrone:
      '-Ku -a3 -An -Kt,h -s0 -o1 -d1 -r1+s -Ar -o1 -At -f-1 -r1+s -As -b+500',
  ByeDpiPreset.mtsAggressive:
      '-Ku -a1 -An -Kt -V443 -H:googlevideo.com -n www.google.com -o1 -An -d0+sm -At -r1+s',
  ByeDpiPreset.megafon2ni:
      '-Ku -a5 -An -Kt -V443 -H:googlevideo.com -n www.google.com -o1 -An -f-1 -T0.5 -Ars -d0+sm -At -r1+s',
  ByeDpiPreset.tele2: '--disorder 1 --auto=t,r,s --fake 2',
  ByeDpiPreset.beelineRt:
      '-o1 -d1 -a1 -At,r,s -s1 -d1 -s5+s -s10+s -s15+s -s20+s -r1+s -S -a1',
  ByeDpiPreset.antiGgc: '--split 3 --oob 1 --disorder 3 --auto=t,r,s',
  ByeDpiPreset.cascade:
      '-d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1',
  ByeDpiPreset.tlsOnly: '-Kt -r1+s -s1+s -d3+s -a1',
  ByeDpiPreset.ttlFixed:
      '-g25 -H:"googlevideo.com youtube.com discord.com" -f-1 -n www.google.com -t4 -r1+s -An -d1 -s25+s -d30+s',
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
