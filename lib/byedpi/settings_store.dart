import 'package:fl_clash/byedpi/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _legacyCliArgs = {
  '--auto=tlsrec',
  '-An -o1 -At,r,s -d1',
  // byebyedpi.org shorthand we mistakenly shipped as raw byedpi argv;
  // byedpi v0.17.3 rejects --tls13 / --fake-resend / --split-pos / --auto=torst.
  '--disorder 1 --auto=torst --tls13',
  '--disorder 1 --auto=torst --fake-resend 2',
  '--split-pos 3 --oob 1 --disorder 3 --auto=torst',
};

class ByeDpiSettingsStore {
  ByeDpiSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  bool get hasLegacyDefaults =>
      _prefs.getString('byedpi.preset') == null &&
      _legacyCliArgs.contains(_prefs.getString('byedpi.cliArgs'));

  ByeDpiSettings read() {
    final storedCli = _prefs.getString('byedpi.cliArgs');
    final storedPreset = _prefs.getString('byedpi.preset');
    final legacy = storedPreset == null &&
        storedCli != null &&
        _legacyCliArgs.contains(storedCli);

    final preset = legacy
        ? ByeDpiPreset.universal
        : (storedPreset != null
            ? ByeDpiPreset.values.firstWhere(
                (p) => p.name == storedPreset,
                orElse: () => ByeDpiPreset.universal,
              )
            : ByeDpiPreset.universal);

    // When migrating away from legacy cliArgs, surface the new universal
    // defaults so a later switch to Custom doesn't show a stale string.
    final cliArgs = (legacy || storedCli == null)
        ? ByeDpiPreset.universal.args
        : storedCli;

    return ByeDpiSettings(
      enabled: _prefs.getBool('byedpi.enabled') ?? false,
      mode: ByeDpiMode.values.byName(
        _prefs.getString('byedpi.mode') ?? ByeDpiMode.auto.name,
      ),
      fallbackEnabled: _prefs.getBool('byedpi.fallbackEnabled') ?? true,
      fallbackGroup: _prefs.getString('byedpi.fallbackGroup') ?? '',
      port: _prefs.getInt('byedpi.port') ?? 1080,
      preset: preset,
      cliArgs: cliArgs,
    );
  }

  Future<void> write(ByeDpiSettings s) async {
    await _prefs.setBool('byedpi.enabled', s.enabled);
    await _prefs.setString('byedpi.mode', s.mode.name);
    await _prefs.setBool('byedpi.fallbackEnabled', s.fallbackEnabled);
    await _prefs.setString('byedpi.fallbackGroup', s.fallbackGroup);
    await _prefs.setInt('byedpi.port', s.port);
    await _prefs.setString('byedpi.preset', s.preset.name);
    await _prefs.setString('byedpi.cliArgs', s.cliArgs);
  }
}
