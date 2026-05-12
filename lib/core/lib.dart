import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/clash/clash_api_client.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/plugins/service.dart';

import 'interface.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  Completer<bool> _connectedCompleter = Completer();
  ClashApiClient? _clashApi;
  Future<bool>? _clashApiReady;

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
    await _clashApi?.dispose();
    _clashApi = null;
    _clashApiReady = null;
    return true;
  }

  @override
  Future<bool> shutdown(_) async {
    if (!_connectedCompleter.isCompleted) {
      return false;
    }
    _connectedCompleter = Completer();
    await _clashApi?.dispose();
    _clashApi = null;
    _clashApiReady = null;
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

  Future<ClashApiClient?> _ensureClashApi() async {
    final ready = _clashApiReady;
    if (ready != null) return (await ready) ? _clashApi : null;
    final completer = Completer<bool>();
    _clashApiReady = completer.future;
    final client = ClashApiClient(getEndpoint: () async {
      return (await invoke<String>(
            method: ActionMethod.getControllerEndpoint,
          )) ??
          '';
    });
    _clashApi = client;
    final ok = await client.connect();
    completer.complete(ok);
    if (ok) return client;
    _clashApi = null;
    _clashApiReady = null;
    return null;
  }

  Map<String, dynamic>? _trafficCache;
  DateTime? _trafficCachedAt;

  Future<Map<String, dynamic>?> _cachedTraffic() async {
    final at = _trafficCachedAt;
    if (at != null &&
        DateTime.now().difference(at) < const Duration(milliseconds: 900)) {
      return _trafficCache;
    }
    final api = await _ensureClashApi();
    if (api == null) return null;
    _trafficCache = await api.getTraffic();
    _trafficCachedAt = DateTime.now();
    return _trafficCache;
  }

  @override
  Future<ProxiesData> getProxies() async {
    final api = await _ensureClashApi();
    if (api == null) return const ProxiesData(proxies: {}, all: []);
    final data = await api.getProxies();
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
    final all = <String>[];
    proxies.forEach((name, raw) {
      if (raw is Map && groupTypes.contains(raw['type'])) {
        all.add(name as String);
      }
    });
    return ProxiesData(
      proxies: Map<String, dynamic>.from(proxies),
      all: all,
    );
  }

  @override
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    final api = await _ensureClashApi();
    if (api == null) return 'controller unavailable';
    final ok = await api.setProxy(
      group: changeProxyParams.groupName,
      name: changeProxyParams.proxyName,
    );
    return ok ? '' : 'set proxy failed';
  }

  @override
  Future<String> getTraffic() async {
    final data = await _cachedTraffic();
    if (data == null) return '';
    return json.encode({'up': data['up'] ?? 0, 'down': data['down'] ?? 0});
  }

  @override
  Future<String> getTotalTraffic() async {
    final data = await _cachedTraffic();
    if (data == null) return '';
    return json.encode({
      'up': data['upTotal'] ?? 0,
      'down': data['downTotal'] ?? 0,
    });
  }

  @override
  Future<String> getMemory() async {
    final api = await _ensureClashApi();
    if (api == null) return '0';
    final data = await api.getMemory();
    if (data == null) return '0';
    return '${data['inuse'] ?? 0}';
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) async {
    final api = await _ensureClashApi();
    if (api == null) {
      return json.encode(Delay(name: proxyName, value: -1, url: url));
    }
    final delay = await api.testDelay(name: proxyName, url: url);
    return json.encode(Delay(name: proxyName, value: delay, url: url));
  }

}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
