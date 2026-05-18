import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

mixin CoreInterface {
  Future<bool> init(InitParams params);

  Future<String> preload();

  Future<bool> shutdown(bool isUser);

  Future<bool> get isInit;

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<Result<dynamic>> getConfig(String path);

  Future<String> asyncTestDelay(String url, String proxyName);

  /// Probe exit-IP for the default route. `mode` is the Dart-side value
  /// ('rule'/'global'/'direct') passed to avoid a race with mihomo's
  /// debounced config sync.
  Future<String> probeCurrentProxyIp({String mode = ''});

  Future<String> updateConfig(UpdateParams updateParams);

  Future<String> setupConfig(SetupParams setupParams);

  Future<ProxiesData> getProxies();

  Future<String> changeProxy(ChangeProxyParams changeProxyParams);

  Future<bool> startListener();

  Future<bool> stopListener();

  Future<String> getExternalProviders();

  Future<String> getExternalProvider(String name, String type);

  Future<String> updateGeoData(UpdateGeoDataParams params);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String name, String type);

  FutureOr<String> getTraffic();

  FutureOr<String> getTotalTraffic();

  FutureOr<String> getCountryCode(String ip);

  FutureOr<String> getMemory();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  FutureOr<void> setLogcatLevel(LogLevel level);

  FutureOr<void> setFileLevel(LogLevel level);

  FutureOr<void> setFileEnabled(bool enabled);

  FutureOr<void> setLogFilePath(String path);

  FutureOr<void> forwardHostLog({
    required LogLevel level,
    required String tag,
    required String payload,
  });

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<bool> subscribeConnections();

  FutureOr<bool> unsubscribeConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<String> deleteFile(String path);

  FutureOr<bool> closeAllConnections();

  FutureOr<bool> resetConnections();
}

abstract class CoreHandlerInterface with CoreInterface {
  Completer<dynamic> get completer;

  FutureOr<bool> destroy();

  Future<T?> _invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      commonPrint.log(
        'Invoke pre ${method.name} timeout $e',
        logLevel: LogLevel.error,
      );
      return null;
    }
    if (kDebugMode && watchExecution) {
      commonPrint.log('Invoke ${method.name} ${DateTime.now()} $data');
    }

    return await utils.handleWatch(
      function: () async {
        return await invoke<T>(method: method, data: data, timeout: timeout);
      },
      onWatch: (data, elapsedMilliseconds) {
        commonPrint.log('Invoke ${method.name} ${elapsedMilliseconds}ms');
      },
    );
  }

  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  });

  Future<T> parseResult<T>(ActionResult result) async {
    return switch (result.method) {
      ActionMethod.getConfig => result.toResult as T,
      _ => result.data as T,
    };
  }

  @override
  Future<bool> init(InitParams params) async {
    return await _invoke<bool>(
          method: ActionMethod.initClash,
          data: json.encode(params),
        ) ??
        false;
  }

  @override
  Future<bool> shutdown(bool isUser);

  @override
  Future<bool> get isInit async {
    return await _invoke<bool>(method: ActionMethod.getIsInit) ?? false;
  }

  @override
  Future<bool> forceGc() async {
    return await _invoke<bool>(method: ActionMethod.forceGc) ?? false;
  }

  @override
  Future<String> validateConfig(String path) async {
    return await _invoke<String>(
          method: ActionMethod.validateConfig,
          data: path,
        ) ??
        '';
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return await _invoke<String>(
          method: ActionMethod.updateConfig,
          data: json.encode(updateParams),
        ) ??
        '';
  }

  @override
  Future<Result<dynamic>> getConfig(String path) async {
    final res = await _invoke(method: ActionMethod.getConfig, data: path);
    return res ?? Result.success({});
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    return await _invoke<String>(
          method: ActionMethod.setupConfig,
          data: json.encode(setupParams),
        ) ??
        '';
  }

  @override
  Future<bool> crash() async {
    return await _invoke<bool>(method: ActionMethod.crash) ?? false;
  }

  @override
  Future<String> updateGeoData(UpdateGeoDataParams params) async {
    return await _invoke<String>(
          method: ActionMethod.updateGeoData,
          data: json.encode(params),
        ) ??
        '';
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) async {
    return await _invoke<String>(
          method: ActionMethod.sideLoadExternalProvider,
          data: json.encode({'providerName': providerName, 'data': data}),
        ) ??
        '';
  }

  @override
  Future<bool> resetConnections() async {
    return await _invoke<bool>(method: ActionMethod.resetConnections) ?? false;
  }

  @override
  Future<String> deleteFile(String path) async {
    return await _invoke<String>(method: ActionMethod.deleteFile, data: path) ??
        '';
  }

  @override
  void resetTraffic() {
    _invoke(method: ActionMethod.resetTraffic);
  }

  @override
  void startLog() {
    _invoke(method: ActionMethod.startLog);
  }

  @override
  void stopLog() {
    _invoke<bool>(method: ActionMethod.stopLog);
  }

  @override
  void setLogcatLevel(LogLevel level) {
    _invoke(method: ActionMethod.setLogcatLevel, data: level.index);
  }

  @override
  void setFileLevel(LogLevel level) {
    _invoke(method: ActionMethod.setFileLevel, data: level.index);
  }

  @override
  void setFileEnabled(bool enabled) {
    _invoke(method: ActionMethod.setFileEnabled, data: enabled);
  }

  @override
  void setLogFilePath(String path) {
    _invoke(method: ActionMethod.setLogFilePath, data: path);
  }

  @override
  void forwardHostLog({
    required LogLevel level,
    required String tag,
    required String payload,
  }) {
    _invoke(
      method: ActionMethod.forwardHostLog,
      data: json.encode({'level': level.index, 'tag': tag, 'payload': payload}),
    );
  }

  @override
  Future<bool> startListener() async {
    return await _invoke<bool>(method: ActionMethod.startListener) ?? false;
  }

  @override
  Future<bool> stopListener() async {
    return await _invoke<bool>(method: ActionMethod.stopListener) ?? false;
  }

  @override
  Future<String> getCountryCode(String ip) async {
    return await _invoke<String>(
          method: ActionMethod.getCountryCode,
          data: ip,
        ) ??
        '';
  }

  @override
  Future<String> getExternalProviders() async {
    return await _invoke<String>(method: ActionMethod.queryExternalProviders) ??
        '[]';
  }

  @override
  Future<String> getExternalProvider(String name, String type) async {
    return await _invoke<String>(
          method: ActionMethod.getExternalProvider,
          data: json.encode({'name': name, 'type': type}),
        ) ??
        '';
  }

  @override
  Future<String> updateExternalProvider(String name, String type) async {
    return await _invoke<String>(
          method: ActionMethod.updateExternalProvider,
          data: json.encode({'name': name, 'type': type}),
        ) ??
        '';
  }

  @override
  Future<String> getConnections() async {
    return await _invoke<String>(method: ActionMethod.getConnections) ?? '';
  }

  @override
  Future<bool> subscribeConnections() async {
    return await _invoke<bool>(method: ActionMethod.subscribeConnections) ??
        false;
  }

  @override
  Future<bool> unsubscribeConnections() async {
    return await _invoke<bool>(method: ActionMethod.unsubscribeConnections) ??
        false;
  }

  @override
  Future<bool> closeConnection(String id) async {
    return await _invoke<bool>(
          method: ActionMethod.closeConnection,
          data: id,
        ) ??
        false;
  }

  @override
  Future<bool> closeAllConnections() async {
    return await _invoke<bool>(method: ActionMethod.closeAllConnections) ??
        false;
  }
}
