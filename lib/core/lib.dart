import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/plugins/service.dart';

import 'interface.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  Completer<bool> _connectedCompleter = Completer();

  CoreLib._internal();

  @override
  Future<String> preload() async {
    final res = await service?.init();
    if (res?.isEmpty != true) {
      return res ?? '';
    }
    _connectedCompleter.complete(true);
    final syncRes = await service?.syncState(appController.sharedState);
    return syncRes ?? '';
  }

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  @override
  Future<bool> destroy() async {
    return true;
  }

  @override
  Future<bool> shutdown(_) async {
    if (!_connectedCompleter.isCompleted) {
      return false;
    }
    _connectedCompleter = Completer();
    return service?.shutdown() ?? true;
  }

  @override
  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    final id = '${method.name}#${utils.id}';
    final result = await service
        ?.invokeAction(Action(id: id, method: method, data: data))
        .withTimeout(onTimeout: () => null);
    if (result == null) {
      return null;
    }
    return parseResult<T>(result);
  }

  @override
  Completer<dynamic> get completer => _connectedCompleter;

  @override
  Future<ProxiesData> getProxies() async {
    final raw = await invoke<String>(method: ActionMethod.getProxies);
    if (raw == null || raw.isEmpty) {
      return const ProxiesData(proxies: {}, all: []);
    }
    Map<String, dynamic>? data;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) data = Map<String, dynamic>.from(decoded);
    } catch (e) {
      commonPrint.log(
        '[CoreLib] getProxies decode failed: $e',
        logLevel: LogLevel.warning,
      );
      return const ProxiesData(proxies: {}, all: []);
    }
    if (data == null) return const ProxiesData(proxies: {}, all: []);
    final proxies = data['proxies'];
    if (proxies is! Map) return const ProxiesData(proxies: {}, all: []);
    const groupTypes = {
      'Selector',
      'URLTest',
      'Fallback',
      'Relay',
      'LoadBalance',
    };
    final orderRaw = await invoke<String>(
      method: ActionMethod.queryProxyGroupOrder,
    );
    final orderFromYaml = <String>[];
    if (orderRaw != null && orderRaw.isNotEmpty) {
      try {
        final decoded = json.decode(orderRaw);
        if (decoded is List) {
          for (final n in decoded) {
            if (n is String) orderFromYaml.add(n);
          }
        }
      } catch (_) {}
    }
    final groupsSet = <String>{};
    proxies.forEach((name, raw) {
      if (raw is Map && groupTypes.contains(raw['type'])) {
        groupsSet.add(name as String);
      }
    });
    final all = <String>[];
    for (final name in orderFromYaml) {
      if (groupsSet.remove(name)) all.add(name);
    }
    all.addAll(groupsSet);
    return ProxiesData(proxies: Map<String, dynamic>.from(proxies), all: all);
  }

  @override
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    final ok = await invoke<bool>(
      method: ActionMethod.changeProxy,
      data: json.encode({
        'group-name': changeProxyParams.groupName,
        'proxy-name': changeProxyParams.proxyName,
      }),
    );
    return ok == true ? '' : 'set proxy failed';
  }

  @override
  Future<String> getTraffic() async {
    return (await invoke<String>(method: ActionMethod.getTraffic)) ?? '';
  }

  @override
  Future<String> getTotalTraffic() async {
    return (await invoke<String>(method: ActionMethod.getTotalTraffic)) ?? '';
  }

  @override
  Future<String> getMemory() async {
    return (await invoke<String>(method: ActionMethod.getMemory)) ?? '0';
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) async {
    final delay = await invoke<int>(
      method: ActionMethod.testDelay,
      data: json.encode({
        'proxy-name': proxyName,
        'test-url': url,
        'timeout': 5000,
      }),
    );
    return json.encode(Delay(name: proxyName, value: delay ?? -1, url: url));
  }

  @override
  Future<String> probeCurrentProxyIp({String mode = ''}) async {
    return (await invoke<String>(
          method: ActionMethod.probeCurrentProxyIp,
          data: mode,
        )) ??
        '';
  }
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
