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
    return parasResult<T>(result);
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
    return ProxiesData.fromJson(data);
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
  Future<String> getConnections() async {
    final api = await _ensureClashApi();
    if (api == null) return '';
    final data = await api.getConnections();
    if (data == null) return '';
    return json.encode(data);
  }

  @override
  Future<bool> closeConnection(String id) async {
    final api = await _ensureClashApi();
    if (api == null) return false;
    return api.closeConnection(id);
  }

  @override
  Future<bool> closeConnections() async {
    final api = await _ensureClashApi();
    if (api == null) return false;
    return api.closeAllConnections();
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

  @override
  Future<String> getExternalProviders() async {
    final api = await _ensureClashApi();
    if (api == null) return '[]';
    final data = await api.getProviders();
    if (data == null) return '[]';
    final providers = data['providers'];
    if (providers is! Map) return '[]';
    final filtered = <Map<String, dynamic>>[];
    providers.forEach((name, raw) {
      if (raw is! Map) return;
      final vehicle = raw['vehicleType'] ?? raw['vehicle-type'];
      if (vehicle == null || vehicle == 'Compatible') return;
      filtered.add({
        'name': raw['name'] ?? name,
        'type': raw['type'] ?? '',
        'vehicle-type': vehicle,
        'count': raw['count'] ?? 0,
        'path': raw['path'] ?? '',
        'update-at': raw['updatedAt'] ?? raw['updated-at'] ?? '',
        'subscription-info':
            raw['subscriptionInfo'] ?? raw['subscription-info'],
      });
    });
    return json.encode(filtered);
  }

  @override
  Future<String> getExternalProvider(String externalProviderName) async {
    final api = await _ensureClashApi();
    if (api == null) return '';
    final data = await api.getProvider(externalProviderName);
    if (data == null) return '';
    return json.encode({
      'name': data['name'] ?? externalProviderName,
      'type': data['type'] ?? '',
      'vehicle-type': data['vehicleType'] ?? data['vehicle-type'] ?? '',
      'count': data['count'] ?? 0,
      'path': data['path'] ?? '',
      'update-at': data['updatedAt'] ?? data['updated-at'] ?? '',
      'subscription-info':
          data['subscriptionInfo'] ?? data['subscription-info'],
    });
  }

  @override
  Future<String> updateExternalProvider(String providerName) async {
    final api = await _ensureClashApi();
    if (api == null) return 'controller unavailable';
    final ok = await api.updateProvider(providerName);
    return ok ? '' : 'update failed';
  }
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
