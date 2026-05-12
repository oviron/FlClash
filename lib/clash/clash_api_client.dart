import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

/// HTTP client for mihomo external-controller REST API.
///
/// Endpoint is resolved lazily via [getEndpoint] (Go-side `GetControllerEndpoint`),
/// retried with exponential backoff. After [connect] returns true, all method
/// calls are safe. Disposal cleans the underlying dio and resets state.
class ClashApiClient {
  ClashApiClient({required this.getEndpoint});

  final Future<String> Function() getEndpoint;

  Dio? _dio;
  String _baseUrl = '';
  String _token = '';
  Completer<bool>? _connectedCompleter;

  static const _maxAttempts = 20;
  static const _baseDelayMs = 100;

  Future<bool> connect() async {
    if (_connectedCompleter != null) {
      return _connectedCompleter!.future;
    }
    final completer = Completer<bool>();
    _connectedCompleter = completer;

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final endpoint = await getEndpoint();
      if (endpoint.isNotEmpty) {
        final uri = Uri.tryParse(endpoint);
        if (uri == null || uri.host.isEmpty || uri.port == 0) {
          commonPrint.log(
            '[ClashApi] malformed endpoint: $endpoint',
            logLevel: LogLevel.warning,
          );
          continue;
        }
        _baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
        _token = uri.queryParameters['token'] ?? '';
        _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            headers: {'Authorization': 'Bearer $_token'},
            connectTimeout: const Duration(seconds: 2),
            receiveTimeout: const Duration(seconds: 5),
            responseType: ResponseType.json,
          ),
        );
        commonPrint.log('[ClashApi] connected at $_baseUrl');
        completer.complete(true);
        return true;
      }
      final backoff = Duration(
        milliseconds: _baseDelayMs * (1 << (attempt > 4 ? 4 : attempt)),
      );
      await Future.delayed(backoff);
    }

    commonPrint.log(
      '[ClashApi] endpoint never resolved after $_maxAttempts attempts',
      logLevel: LogLevel.error,
    );
    _connectedCompleter = null;
    completer.complete(false);
    return false;
  }

  Future<Map<String, dynamic>?> _getJson(String path) async {
    final dio = _dio;
    if (dio == null) return null;
    try {
      final res = await dio.get<dynamic>(path);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } on DioException catch (e) {
      commonPrint.log(
        '[ClashApi] GET $path failed: ${e.message}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<bool> _putJson(String path, {dynamic body, Map<String, dynamic>? query}) async {
    final dio = _dio;
    if (dio == null) return false;
    try {
      final res = await dio.put<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          contentType: 'application/json',
          validateStatus: (code) => code != null && code >= 200 && code < 300,
        ),
      );
      return res.statusCode != null && res.statusCode! < 300;
    } on DioException catch (e) {
      commonPrint.log(
        '[ClashApi] PUT $path failed: ${e.message}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }


  Future<Map<String, dynamic>?> getTraffic() => _getJson('/traffic');

  Future<Map<String, dynamic>?> getMemory() => _getJson('/memory');

  Future<Map<String, dynamic>?> getProxies() => _getJson('/proxies');

  Future<bool> setProxy({required String group, required String name}) =>
      _putJson(
        '/proxies/${Uri.encodeComponent(group)}',
        body: {'name': name},
      );

  /// GET /proxies/{name}/delay?timeout=N&url=... Returns `{delay: ms}` on
  /// success or null on timeout. We use raw fetch to return delay or -1.
  Future<int> testDelay({
    required String name,
    required String url,
    int timeoutMs = 5000,
  }) async {
    final dio = _dio;
    if (dio == null) return -1;
    try {
      final res = await dio.get<dynamic>(
        '/proxies/${Uri.encodeComponent(name)}/delay',
        queryParameters: {'url': url, 'timeout': timeoutMs},
        options: Options(
          validateStatus: (code) => code != null && code < 500,
          receiveTimeout: Duration(milliseconds: timeoutMs + 1000),
        ),
      );
      final data = res.data;
      if (data is Map && data['delay'] is num) {
        return (data['delay'] as num).toInt();
      }
      return -1;
    } on DioException {
      return -1;
    }
  }

  Future<void> dispose() async {
    _dio?.close(force: true);
    _dio = null;
    _baseUrl = '';
    _token = '';
    _connectedCompleter = null;
  }
}
