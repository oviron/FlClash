import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: type,
);

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
