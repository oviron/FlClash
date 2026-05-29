import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/byedpi/strategy_args.dart';
import 'package:fl_clash/common/inbound_auth.dart';
import 'package:fl_clash/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kStrategiesUrl =
    'https://github.com/oviron/FlClash/releases/download/strategies/byedpi-strategies.json';

const _lastUpdateKey = 'byedpi.strategiesLastUpdate';

Future<DateTime?> strategiesLastUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_lastUpdateKey);
  return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
}

// Two egress paths, tried in order:
//  - direct: the app is excluded from the tun (bydpi flavor), so a direct
//    socket hits the raw network — the same path the rest of FlClash's own
//    fetches use, and the one that works under a default-REJECT (whitelist)
//    routing config where the proxy would reject the app's own traffic.
//  - proxy: the local mixed-port (for default-allow configs where the release
//    host is only reachable through the tunnel); answers its inbound-auth 407.
Dio _dio({required bool viaProxy}) {
  final mixedPort = appController.config.patchClashConfig.mixedPort;
  final dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (_, _, _) => true;
      client.findProxy = (_) =>
          viaProxy ? 'PROXY localhost:$mixedPort' : 'DIRECT';
      if (viaProxy) {
        client.authenticateProxy = (host, port, scheme, realm) async {
          final pwd = await inboundAuthPassword();
          if (pwd == null || pwd.isEmpty) return false;
          client.addProxyCredentials(
            host,
            port,
            realm ?? '',
            HttpClientBasicCredentials(inboundAuthUser, pwd),
          );
          return true;
        };
      }
      return client;
    },
  );
  return dio;
}

// Fetch + validate + atomically write the on-disk override, stamp the update
// time. Returns the strategy count. Tries direct first, then proxy; throws the
// last error only if both paths fail (previous set kept).
Future<int> updateStrategiesFromRemote() async {
  Object? lastError;
  for (final viaProxy in [false, true]) {
    try {
      final res = await _dio(viaProxy: viaProxy).get<String>(
        kStrategiesUrl,
        options: Options(responseType: ResponseType.plain),
      );
      final raw = res.data ?? '';
      final list = parseStrategyList(raw); // validates; throws on bad payload
      await writeStrategyList(raw);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
      return list.length;
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError ?? Exception('strategy update failed');
}
