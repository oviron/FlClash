import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kStrategiesUrl =
    'https://github.com/oviron/FlClash/releases/download/strategies/byedpi-strategies.json';

const _lastUpdateKey = 'byedpi.strategiesLastUpdate';

Future<DateTime?> strategiesLastUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_lastUpdateKey);
  return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
}

// Fetch the strategy set straight from GitHub. The app is excluded from the tun
// (bydpi flavor), so a direct socket is a raw fetch — the same egress the rest
// of FlClash's own traffic uses. `findProxy = DIRECT` is required to bypass the
// app-wide HttpOverrides (lib/common/http.dart) that otherwise forces every
// HttpClient through the local mixed-port when the VPN is up.
Future<int> updateStrategiesFromRemote() async {
  final dio = Dio()
    ..httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (_, _, _) => true;
        client.findProxy = (_) => 'DIRECT';
        return client;
      },
    );
  final res = await dio.get<String>(
    kStrategiesUrl,
    options: Options(responseType: ResponseType.plain),
  );
  final raw = res.data ?? '';
  final list = parseStrategyList(raw); // validates; throws on bad payload
  await writeStrategyList(raw);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  return list.length;
}
