import 'package:fl_clash/common/app_localizations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

enum ByeDpiMode { manual, auto }

enum ByeDpiPreset {
  universal('--disorder 1 --auto=t,r,s --tlsrec 1+s'),
  mrDrone(
    '-Ku -a3 -An -Kt,h -s0 -o1 -d1 -r1+s -Ar -o1 -At -f-1 -r1+s -As -b+500',
  ),
  mtsAggressive(
    '-Ku -a1 -An -Kt -V443 -H:googlevideo.com -n www.google.com -o1 -An -d0+sm -At -r1+s',
  ),
  megafon2ni(
    '-Ku -a5 -An -Kt -V443 -H:googlevideo.com -n www.google.com -o1 -An -f-1 -T0.5 -Ars -d0+sm -At -r1+s',
  ),
  tele2('--disorder 1 --auto=t,r,s --fake 2'),
  beelineRt(
    '-o1 -d1 -a1 -At,r,s -s1 -d1 -s5+s -s10+s -s15+s -s20+s -r1+s -S -a1',
  ),
  antiGgc('--split 3 --oob 1 --disorder 3 --auto=t,r,s'),
  cascade(
    '-d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1',
  ),
  tlsOnly('-Kt -r1+s -s1+s -d3+s -a1'),
  ttlFixed(
    '-g25 -H:"googlevideo.com youtube.com discord.com" -f-1 -n www.google.com -t4 -r1+s -An -d1 -s25+s -d30+s',
  ),
  custom('');

  const ByeDpiPreset(this.args);

  final String args;

  String get label => switch (this) {
    ByeDpiPreset.universal => appLocalizations.byedpiPresetUniversal,
    ByeDpiPreset.mrDrone => appLocalizations.byedpiPresetMrDrone,
    ByeDpiPreset.mtsAggressive => appLocalizations.byedpiPresetMtsAggressive,
    ByeDpiPreset.megafon2ni => appLocalizations.byedpiPresetMegafon2ni,
    ByeDpiPreset.tele2 => appLocalizations.byedpiPresetTele2,
    ByeDpiPreset.beelineRt => appLocalizations.byedpiPresetBeelineRt,
    ByeDpiPreset.antiGgc => appLocalizations.byedpiPresetAntiGgc,
    ByeDpiPreset.cascade => appLocalizations.byedpiPresetCascade,
    ByeDpiPreset.tlsOnly => appLocalizations.byedpiPresetTlsOnly,
    ByeDpiPreset.ttlFixed => appLocalizations.byedpiPresetTtlFixed,
    ByeDpiPreset.custom => appLocalizations.byedpiPresetCustom,
  };
}

String effectiveByeDpiCliArgs(ByeDpiSettings s) =>
    s.preset == ByeDpiPreset.custom ? s.cliArgs : s.preset.args;

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
