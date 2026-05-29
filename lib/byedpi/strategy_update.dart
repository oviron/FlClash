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

// Route through the local mixed-port when the VPN is up (so a blocked release
// host is reachable), else direct. The inbound carries auth (see
// inbound_auth.dart), so we must answer the proxy's 407 with the stored
// credentials — `request._clashDio` doesn't, which is why the generic fetch
// failed. authenticateProxy matches whatever realm mihomo challenges with.
Dio _buildDio() {
  final mixedPort = appController.config.patchClashConfig.mixedPort;
  final viaProxy = appController.isStart;
  final dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (_, _, _) => true;
      client.findProxy = (_) =>
          viaProxy ? 'PROXY localhost:$mixedPort' : 'DIRECT';
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
      return client;
    },
  );
  return dio;
}

// Fetch the strategy set from [kStrategiesUrl], validate, atomically write the
// on-disk override and stamp the update time. Returns the strategy count.
// Throws on fetch/parse failure — the previous on-disk/bundled set is kept.
Future<int> updateStrategiesFromRemote() async {
  final res = await _buildDio().get<String>(
    kStrategiesUrl,
    options: Options(responseType: ResponseType.plain),
  );
  final raw = res.data ?? '';
  final list = parseStrategyList(raw);
  await writeStrategyList(raw);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  return list.length;
}
