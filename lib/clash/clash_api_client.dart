import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

/// Minimal client for mihomo external-controller REST API.
///
/// Phase A scope: discover endpoint with exponential backoff and verify with
/// `GET /version`. Phase B will extend with proxies, traffic, connections.
class ClashApiClient {
  ClashApiClient({required this.getEndpoint});

  /// Resolves `http://127.0.0.1:PORT?token=SECRET` from Go core via existing
  /// action plumbing. Returns empty string until controller has started.
  final Future<String> Function() getEndpoint;

  Dio? _dio;
  String _baseUrl = '';
  String _token = '';
  Completer<bool>? _connectedCompleter;

  static const _maxAttempts = 20;
  static const _baseDelayMs = 100;

  bool get isConnected => _dio != null;
  String get baseUrl => _baseUrl;

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
    completer.complete(false);
    return false;
  }

  Future<Map<String, dynamic>?> getVersion() async {
    final dio = _dio;
    if (dio == null) {
      return null;
    }
    try {
      final res = await dio.get<Map<String, dynamic>>('/version');
      return res.data;
    } on DioException catch (e) {
      commonPrint.log(
        '[ClashApi] GET /version failed: ${e.message}',
        logLevel: LogLevel.warning,
      );
      return null;
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
