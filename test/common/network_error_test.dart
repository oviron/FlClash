import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: type,
);

DioException _badResponse(Uri url, {required int statusCode, Object? data}) {
  final options = RequestOptions(path: url.toString());
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  group('describeNetworkError', () {
    test('timeouts and bad responses read as the network message', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.badResponse,
      ]) {
        expect(
          describeNetworkError(_dio(type)),
          appLocalizations.networkException,
        );
      }
      expect(
        describeNetworkError(TimeoutException('t')),
        appLocalizations.networkException,
      );
    });

    test('the everyday no-internet case is a sentence, not a Dio dump', () {
      expect(
        describeNetworkError(_dio(DioExceptionType.connectionError)),
        appLocalizations.networkException,
      );
      expect(
        describeNetworkError(_dio(DioExceptionType.badCertificate)),
        appLocalizations.networkException,
      );
    });

    test('a bad response shows the HTTP status and a body preview', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 403, data: 'subscription expired'),
      );
      expect(message, contains('HTTP 403'));
      expect(message, contains('subscription expired'));
    });

    test('a byte-response body is decoded as UTF-8 for the preview', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(
          url,
          statusCode: 502,
          data: Uint8List.fromList(utf8.encode('bad gateway')),
        ),
      );
      expect(message, contains('HTTP 502'));
      expect(message, contains('bad gateway'));
    });

    test('non-UTF8 bytes fall back to the status alone, no crash', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 500, data: Uint8List.fromList([255])),
      );
      expect(message, 'Server responded with HTTP 500');
    });

    test('a bad response leads with its status, not the connection hint', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 403, data: 'subscription expired'),
      )!;
      expect(message.split('\n').first, 'Server responded with HTTP 403');
      expect(message, isNot(contains(appLocalizations.networkException)));
    });

    test('a secret cut by the preview limit is still masked', () {
      final url = Uri.parse('https://panel.example/sub/deadbeefcafebabe');
      final message = describeNetworkError(
        _badResponse(
          url,
          statusCode: 400,
          data: '${'x' * 190}/sub/deadbeefcafebabe rejected',
        ),
      )!;
      expect(message, isNot(contains('deadb')));
    });

    test('the body preview is capped at roughly 200 characters', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 400, data: 'x' * 500),
      )!;
      final detail = message.split('\n').last;
      expect(detail.length, lessThanOrEqualTo(201));
    });

    test('the subscription URL is never shown, even when echoed back', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 400, data: 'bad request for $url'),
      )!;
      expect(message, isNot(contains('secret')));
      expect(message, isNot(contains(url.toString())));
    });

    test('no secret part of the URL survives an echo in any form', () {
      final url = Uri.parse('https://panel.example/sub/deadbeef?token=secret');
      for (final echo in [
        'no such path: https://panel.example/sub/deadbeef',
        'bad path /sub/deadbeef',
        'query token=secret rejected',
        'invalid token secret',
      ]) {
        final message = describeNetworkError(
          _badResponse(url, statusCode: 404, data: echo),
        )!;
        expect(message, isNot(contains('deadbeef')), reason: echo);
        expect(message, isNot(contains('secret')), reason: echo);
      }
    });

    test('short URL pieces are not masked out of the body', () {
      final url = Uri.parse('https://panel.example/api/sub?v=1');
      final message = describeNetworkError(
        _badResponse(url, statusCode: 429, data: 'limit 10 per api call'),
      )!;
      expect(message, endsWith('limit 10 per api call'));
    });

    test('a deliberate cancel is left to the caller', () {
      expect(describeNetworkError(_dio(DioExceptionType.cancel)), isNull);
    });

    test('anything non-transport falls back to the unknown message', () {
      expect(
        describeNetworkError(StateError('x')),
        appLocalizations.unknownNetworkError,
      );
      expect(
        describeNetworkError(_dio(DioExceptionType.unknown)),
        appLocalizations.unknownNetworkError,
      );
    });
  });
}
