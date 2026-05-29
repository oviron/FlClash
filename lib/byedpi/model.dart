import 'package:fl_clash/common/app_localizations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/model.freezed.dart';
part 'generated/model.g.dart';

enum ByeDpiMode { manual, auto }

enum ByeDpiPreset {
  universal('-o1 -a1 -r-5+se'),
  mrDrone(
    '-d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1',
  ),
  mtsAggressive('-s1 -q1 -a1 -At,r,s -f-1 -r1+s -a1'),
  megafon2ni('-o1 -d1 -r1+s -S -s1+s -d3+s -a1'),
  tele2('-s1 -o1 -a1 -At,r,s -f-1 -r1+s -a1'),
  beelineRt(
    '-o1 -d1 -a1 -At,r,s -s1 -d1 -s5+s -s10+s -s15+s -s20+s -r1+s -S -a1',
  ),
  antiGgc('-d1 -r1+s -f-1 -S -t8 -o3+s -a1'),
  cascade(
    '-d1 -s1+s -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -a1',
  ),
  tlsOnly('-s1 -d3+s -a1 -At -r1+s -a1'),
  ttlFixed('-q1+s -s29+s -o5+s -f-1 -S -a1'),
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

// `overrides` (keyed by preset id) is the data-driven source from
// byedpi-strategies.json; the enum's compiled `.args` stays as fallback when
// the asset is missing/corrupt. Empty map = pure fallback (keeps old callers).
String effectiveByeDpiCliArgs(
  ByeDpiSettings s, [
  Map<String, String> overrides = const {},
]) => s.preset == ByeDpiPreset.custom
    ? s.cliArgs
    : (overrides[s.preset.name] ?? s.preset.args);

@freezed
abstract class ByeDpiSettings with _$ByeDpiSettings {
  const factory ByeDpiSettings({
    @Default(false) bool enabled,
    @Default(ByeDpiMode.auto) ByeDpiMode mode,
    @Default(true) bool fallbackEnabled,
    @Default('') String fallbackGroup,
    @Default(1080) int port,
    @Default(ByeDpiPreset.universal) ByeDpiPreset preset,
    @Default('-o1 -a1 -r-5+se') String cliArgs,
  }) = _ByeDpiSettings;

  factory ByeDpiSettings.fromJson(Map<String, Object?> json) =>
      _$ByeDpiSettingsFromJson(json);
}
