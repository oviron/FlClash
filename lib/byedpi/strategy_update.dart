import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:fl_clash/common/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kStrategiesUrl =
    'https://github.com/oviron/FlClash/releases/download/strategies/byedpi-strategies.json';

const _lastUpdateKey = 'byedpi.strategiesLastUpdate';

Future<DateTime?> strategiesLastUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_lastUpdateKey);
  return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
}

// Fetch the strategy set from [kStrategiesUrl] (routed through mihomo when the
// VPN is up, via request._clashDio), validate, atomically write the on-disk
// override and stamp the update time. Returns the strategy count. Throws on
// fetch/parse failure — the previous on-disk/bundled set is left untouched.
Future<int> updateStrategiesFromRemote() async {
  final res = await request.getTextResponseForUrl(kStrategiesUrl);
  final raw = res.data ?? '';
  final list = parseStrategyList(raw);
  await writeStrategyList(raw);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  return list.length;
}
