import 'package:fl_clash/byedpi/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ByeDpiSettingsStore {
  ByeDpiSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  ByeDpiSettings read() => ByeDpiSettings(
    enabled: _prefs.getBool('byedpi.enabled') ?? false,
    port: _prefs.getInt('byedpi.port') ?? 1080,
    cliArgs: _prefs.getString('byedpi.cliArgs') ?? '',
    fallbackGroup: _prefs.getString('byedpi.fallbackGroup') ?? 'VPN',
  );

  Future<void> write(ByeDpiSettings s) async {
    await _prefs.setBool('byedpi.enabled', s.enabled);
    await _prefs.setInt('byedpi.port', s.port);
    await _prefs.setString('byedpi.cliArgs', s.cliArgs);
    await _prefs.setString('byedpi.fallbackGroup', s.fallbackGroup);
  }
}
