import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/state.dart';

class FlClashHttpOverrides extends HttpOverrides {
  static String handleFindProxy(Uri url) {
    if ([localhost].contains(url.host)) {
      return 'DIRECT';
    }
    final port = appController.config.patchClashConfig.mixedPort;
    // A profile apply replaces the very config that would carry this request —
    // fetching a subscription through the proxies it is still defining fails,
    // and a failed fetch then writes an empty provider that kills routing.
    final useProxy = appController.isStart && !globalState.bootstrappingConfig;
    commonPrint.log('find $url proxy:$useProxy');
    if (!useProxy) return 'DIRECT';
    return 'PROXY localhost:$port';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, _, _) => true;
    client.findProxy = handleFindProxy;
    return client;
  }
}
