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

// Direct GitHub fetch (app is excluded from the tun, so this is raw).
// findProxy=DIRECT bypasses the app-wide HttpOverrides that force the proxy.
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
