import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

typedef IpQualityAnswer = ({IpQuality quality, bool inferred});

typedef IpQualitySourceResult = ({
  IpQualitySource source,
  IpQualityAnswer? answer,
  IpQualitySourceStatus? failure,
});

typedef IpQualityReport = ({
  String ip,
  IpQuality? verdict,
  List<IpQualitySourceResult> results,
});

class _SourceFailure implements Exception {
  const _SourceFailure(this.status);

  final IpQualitySourceStatus status;
}

// Every declared source is queried in parallel with its own timeout; one
// source failing (rate limit, timeout, bad payload) never blocks the rest.
Future<IpQualityReport> lookupIpQuality(
  Dio dio,
  String ip, {
  CancelToken? cancelToken,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final token = cancelToken ?? CancelToken();
  final results = await Future.wait([
    for (final source in IpQualitySource.values)
      _query(dio, source, ip, token, timeout),
  ]);
  return aggregateIpQuality(ip, results);
}

// A stated type beats an inferred one; a risk flag from any source that
// answered carries into the verdict.
IpQualityReport aggregateIpQuality(
  String ip,
  List<IpQualitySourceResult> results,
) {
  final answers = [
    for (final result in results)
      if (result.answer case final answer?) answer,
  ];
  if (answers.isEmpty) {
    return (ip: ip, verdict: null, results: results);
  }
  final best = answers.firstWhere(
    (answer) => !answer.inferred,
    orElse: () => answers.first,
  );
  final verdict = best.quality.copyWith(
    isProxy: answers.any((answer) => answer.quality.isProxy),
    isVpn: answers.any((answer) => answer.quality.isVpn),
    isTor: answers.any((answer) => answer.quality.isTor),
    isAbuser: answers.any((answer) => answer.quality.isAbuser),
  );
  return (ip: ip, verdict: verdict, results: results);
}

Future<IpQualitySourceResult> _query(
  Dio dio,
  IpQualitySource source,
  String ip,
  CancelToken cancelToken,
  Duration timeout,
) async {
  try {
    final response = await dio
        .get<String>(
          ipQualitySourceUrl(source, ip),
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.plain,
            validateStatus: (_) => true,
          ),
        )
        .timeout(timeout);
    return parseIpQualityResponse(
      source,
      ip,
      response.statusCode ?? 0,
      response.data,
    );
  } catch (e) {
    return (source: source, answer: null, failure: _statusOf(e));
  }
}

IpQualitySourceResult parseIpQualityResponse(
  IpQualitySource source,
  String ip,
  int statusCode,
  String? body,
) {
  try {
    if (statusCode == HttpStatus.tooManyRequests) {
      throw const _SourceFailure(IpQualitySourceStatus.rateLimited);
    }
    if (statusCode != HttpStatus.ok) {
      throw const _SourceFailure(IpQualitySourceStatus.failed);
    }
    final json = jsonDecode(body ?? '') as Map<String, dynamic>;
    final answer = parseIpQualityAnswer(source, ip, json);
    if (answer == null) {
      throw const _SourceFailure(IpQualitySourceStatus.noType);
    }
    return (source: source, answer: answer, failure: null);
  } catch (e) {
    return (source: source, answer: null, failure: _statusOf(e));
  }
}

IpQualitySourceStatus _statusOf(Object error) {
  return switch (error) {
    _SourceFailure(:final status) => status,
    TimeoutException() => IpQualitySourceStatus.timeout,
    DioException(
      type: DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout,
    ) =>
      IpQualitySourceStatus.timeout,
    _ => IpQualitySourceStatus.failed,
  };
}

String ipQualitySourceUrl(IpQualitySource source, String ip) {
  return switch (source) {
    IpQualitySource.identMe => 'https://ident.me/json',
    IpQualitySource.ipQuery => 'https://api.ipquery.io/$ip?format=json',
    IpQualitySource.ipLocate => 'https://iplocate.io/api/lookup/$ip',
    IpQualitySource.proxyCheck => 'https://proxycheck.io/v3/$ip',
    IpQualitySource.ipApiIs => 'https://api.ipapi.is/?q=$ip',
  };
}

IpQualityAnswer? parseIpQualityAnswer(
  IpQualitySource source,
  String ip,
  Map<String, dynamic> json,
) {
  return switch (source) {
    IpQualitySource.identMe => _fromIdentMe(ip, json),
    IpQualitySource.ipQuery => _fromIpQuery(ip, json),
    IpQualitySource.ipLocate => _fromIpLocate(ip, json),
    IpQualitySource.proxyCheck => _fromProxyCheck(ip, json),
    IpQualitySource.ipApiIs => _fromIpApiIs(ip, json),
  };
}

IpQualityAnswer? _fromIdentMe(String ip, Map<String, dynamic> json) {
  if (json['ip'] != ip) {
    throw const _SourceFailure(IpQualitySourceStatus.ipMismatch);
  }
  return _quality(
    ip,
    IpQualitySource.identMe,
    _declaredType(json['type']),
    organization: _text(json['aso']),
    asn: _asn(json['asn']),
  );
}

IpQualityAnswer? _fromIpQuery(String ip, Map<String, dynamic> json) {
  final risk = _object(json['risk']);
  final isp = _object(json['isp']);
  final type = _pickType(
    hosting: _flag(risk['is_datacenter']),
    mobile: _flag(risk['is_mobile']),
  );
  return _quality(
    ip,
    IpQualitySource.ipQuery,
    type ?? IpType.residential,
    inferred: type == null,
    organization: _text(isp['org']) ?? _text(isp['isp']),
    asn: _asn(isp['asn']),
    isProxy: _flag(risk['is_proxy']),
    isVpn: _flag(risk['is_vpn']),
    isTor: _flag(risk['is_tor']),
  );
}

IpQualityAnswer? _fromIpLocate(String ip, Map<String, dynamic> json) {
  final privacy = _object(json['privacy']);
  final company = _object(json['company']);
  final asn = _object(json['asn']);
  return _quality(
    ip,
    IpQualitySource.ipLocate,
    _pickType(
      hosting: _flag(privacy['is_hosting']),
      declared: _declaredType(company['type']) ?? _declaredType(asn['type']),
    ),
    organization: _text(company['name']) ?? _text(asn['name']),
    asn: _asn(asn['asn']),
    isProxy: _flag(privacy['is_proxy']),
    isVpn: _flag(privacy['is_vpn']),
    isTor: _flag(privacy['is_tor']),
    isAbuser: _flag(privacy['is_abuser']),
  );
}

IpQualityAnswer? _fromProxyCheck(String ip, Map<String, dynamic> json) {
  final status = json['status'];
  if (status == 'denied') {
    throw const _SourceFailure(IpQualitySourceStatus.rateLimited);
  }
  if (status != 'ok' && status != 'warning') {
    throw const _SourceFailure(IpQualitySourceStatus.failed);
  }
  final result = _object(json[ip]);
  final network = _object(result['network']);
  final detections = _object(result['detections']);
  final networkType = network['type'];
  return _quality(
    ip,
    IpQualitySource.proxyCheck,
    _pickType(
      hosting: _flag(detections['hosting']) || networkType == 'Hosting',
      mobile: networkType == 'Wireless',
      declared: switch (networkType) {
        'Residential' => IpType.residential,
        'Business' => IpType.business,
        _ => null,
      },
    ),
    organization: _text(network['organisation']),
    asn: _asn(network['asn']),
    isProxy: _flag(detections['proxy']),
    isVpn: _flag(detections['vpn']),
    isTor: _flag(detections['tor']),
  );
}

IpQualityAnswer? _fromIpApiIs(String ip, Map<String, dynamic> json) {
  final company = _object(json['company']);
  final asn = _object(json['asn']);
  return _quality(
    ip,
    IpQualitySource.ipApiIs,
    _pickType(
      hosting: _flag(json['is_datacenter']),
      mobile: _flag(json['is_mobile']),
      declared: _declaredType(company['type']) ?? _declaredType(asn['type']),
    ),
    organization: _text(company['name']) ?? _text(asn['org']),
    asn: _asn(asn['asn']),
    isProxy: _flag(json['is_proxy']),
    isVpn: _flag(json['is_vpn']),
    isTor: _flag(json['is_tor']),
    isAbuser: _flag(json['is_abuser']),
  );
}

// An inferred type is the source's silence about hosting and mobile taken as
// residential; it only stands in when no source states a type.
IpQualityAnswer? _quality(
  String ip,
  IpQualitySource source,
  IpType? type, {
  bool inferred = false,
  String? organization,
  int? asn,
  bool isProxy = false,
  bool isVpn = false,
  bool isTor = false,
  bool isAbuser = false,
}) {
  if (type == null) {
    return null;
  }
  final quality = IpQuality(
    ip: ip,
    source: source,
    type: type,
    organization: organization,
    asn: asn,
    isProxy: isProxy,
    isVpn: isVpn,
    isTor: isTor,
    isAbuser: isAbuser,
  );
  return (quality: quality, inferred: inferred);
}

IpType? _pickType({
  required bool hosting,
  bool mobile = false,
  IpType? declared,
}) {
  if (hosting || declared == IpType.hosting) {
    return IpType.hosting;
  }
  if (mobile) {
    return IpType.mobile;
  }
  return declared;
}

IpType? _declaredType(Object? value) {
  return switch (value) {
    'isp' => IpType.residential,
    'business' || 'education' || 'government' || 'banking' => IpType.business,
    'hosting' => IpType.hosting,
    _ => null,
  };
}

Map<String, dynamic> _object(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

bool _flag(Object? value) => value == true;

String? _text(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

int? _asn(Object? value) {
  final asn = switch (value) {
    final int number => number,
    final String text => int.tryParse(
      RegExp(r'\d+').firstMatch(text)?[0] ?? '',
    ),
    _ => null,
  };
  return asn == 0 ? null : asn;
}
