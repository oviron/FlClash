import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _ip = '203.0.113.7';

IpQualitySourceResult _parse(
  IpQualitySource source,
  Map<String, dynamic> json, {
  int statusCode = HttpStatus.ok,
}) {
  return parseIpQualityResponse(source, _ip, statusCode, jsonEncode(json));
}

void main() {
  group('ipQualitySourceUrl', () {
    test('is https for every source', () {
      for (final source in IpQualitySource.values) {
        expect(Uri.parse(ipQualitySourceUrl(source, _ip)).scheme, 'https');
      }
    });

    test('embeds the ip where the source expects it', () {
      expect(ipQualitySourceUrl(IpQualitySource.ipQuery, _ip), contains(_ip));
      expect(ipQualitySourceUrl(IpQualitySource.ipLocate, _ip), contains(_ip));
      expect(
        ipQualitySourceUrl(IpQualitySource.proxyCheck, _ip),
        contains(_ip),
      );
      expect(ipQualitySourceUrl(IpQualitySource.ipApiIs, _ip), contains(_ip));
    });
  });

  group('parseIpQualityResponse: ident.me', () {
    test('reads a declared hosting type', () {
      final result = _parse(IpQualitySource.identMe, {
        'ip': _ip,
        'type': 'hosting',
        'aso': 'Example Hosting LLC',
        'asn': 'AS12345',
      });
      final quality = result.answer!.quality;
      expect(result.answer!.inferred, isFalse);
      expect(quality.type, IpType.hosting);
      expect(quality.organization, 'Example Hosting LLC');
      expect(quality.asn, 12345);
    });

    test('fails as an ip mismatch when the source echoes another ip', () {
      final result = _parse(IpQualitySource.identMe, {
        'ip': '198.51.100.1',
        'type': 'hosting',
      });
      expect(result.answer, isNull);
      expect(result.failure, IpQualitySourceStatus.ipMismatch);
    });

    test('fails with noType when the type is unrecognised', () {
      final result = _parse(IpQualitySource.identMe, {
        'ip': _ip,
        'type': 'unknown-value',
      });
      expect(result.answer, isNull);
      expect(result.failure, IpQualitySourceStatus.noType);
    });
  });

  group('parseIpQualityResponse: ipquery.io', () {
    test('flags vpn and proxy from the risk block', () {
      final result = _parse(IpQualitySource.ipQuery, {
        'risk': {'is_vpn': true, 'is_proxy': true, 'is_datacenter': true},
        'isp': {'org': 'Example Cloud', 'asn': 'AS999'},
      });
      final quality = result.answer!.quality;
      expect(result.answer!.inferred, isFalse);
      expect(quality.type, IpType.hosting);
      expect(quality.isVpn, isTrue);
      expect(quality.isProxy, isTrue);
      expect(quality.organization, 'Example Cloud');
      expect(quality.asn, 999);
    });

    test('infers residential when no type signal is present', () {
      final result = _parse(IpQualitySource.ipQuery, {
        'risk': <String, dynamic>{},
        'isp': <String, dynamic>{},
      });
      expect(result.answer!.inferred, isTrue);
      expect(result.answer!.quality.type, IpType.residential);
    });
  });

  group('parseIpQualityResponse: iplocate.io', () {
    test('reads abuse and tor flags from the privacy block', () {
      final result = _parse(IpQualitySource.ipLocate, {
        'privacy': {'is_tor': true, 'is_abuser': true},
        'company': {'name': 'Example Org', 'type': 'business'},
        'asn': {'asn': 'AS4321'},
      });
      final quality = result.answer!.quality;
      expect(quality.type, IpType.business);
      expect(quality.isTor, isTrue);
      expect(quality.isAbuser, isTrue);
      expect(quality.organization, 'Example Org');
      expect(quality.asn, 4321);
    });
  });

  group('parseIpQualityResponse: proxycheck.io', () {
    test('reads the per-ip result keyed by the address', () {
      final result = _parse(IpQualitySource.proxyCheck, {
        'status': 'ok',
        _ip: {
          'network': {'organisation': 'Example Telecom', 'type': 'Wireless'},
          'detections': {'proxy': true},
        },
      });
      final quality = result.answer!.quality;
      expect(quality.type, IpType.mobile);
      expect(quality.isProxy, isTrue);
      expect(quality.organization, 'Example Telecom');
    });

    test('fails with rateLimited when the service denies the query', () {
      final result = _parse(IpQualitySource.proxyCheck, {'status': 'denied'});
      expect(result.answer, isNull);
      expect(result.failure, IpQualitySourceStatus.rateLimited);
    });
  });

  group('parseIpQualityResponse: ipapi.is', () {
    test('reads a declared datacenter and abuser flag', () {
      final result = _parse(IpQualitySource.ipApiIs, {
        'is_datacenter': true,
        'is_abuser': true,
        'company': {'name': 'Example Datacenter'},
        'asn': {'asn': 555},
      });
      final quality = result.answer!.quality;
      expect(quality.type, IpType.hosting);
      expect(quality.isAbuser, isTrue);
      expect(quality.organization, 'Example Datacenter');
      expect(quality.asn, 555);
    });
  });

  group('parseIpQualityResponse: transport status codes', () {
    test('maps HTTP 429 to rateLimited regardless of source', () {
      final result = parseIpQualityResponse(
        IpQualitySource.ipApiIs,
        _ip,
        HttpStatus.tooManyRequests,
        null,
      );
      expect(result.failure, IpQualitySourceStatus.rateLimited);
    });

    test('maps any other non-200 status to failed', () {
      final result = parseIpQualityResponse(
        IpQualitySource.ipApiIs,
        _ip,
        HttpStatus.internalServerError,
        null,
      );
      expect(result.failure, IpQualitySourceStatus.failed);
    });

    test('maps an unparsable body to failed', () {
      final result = parseIpQualityResponse(
        IpQualitySource.ipApiIs,
        _ip,
        HttpStatus.ok,
        'not json',
      );
      expect(result.failure, IpQualitySourceStatus.failed);
    });
  });

  group('aggregateIpQuality', () {
    IpQuality quality({
      required IpQualitySource source,
      IpType type = IpType.residential,
      bool isProxy = false,
      bool isVpn = false,
      bool isTor = false,
      bool isAbuser = false,
    }) {
      return IpQuality(
        ip: _ip,
        source: source,
        type: type,
        isProxy: isProxy,
        isVpn: isVpn,
        isTor: isTor,
        isAbuser: isAbuser,
      );
    }

    test('reports no verdict when every source failed', () {
      final report = aggregateIpQuality(_ip, [
        (
          source: IpQualitySource.identMe,
          answer: null,
          failure: IpQualitySourceStatus.timeout,
        ),
        (
          source: IpQualitySource.ipApiIs,
          answer: null,
          failure: IpQualitySourceStatus.failed,
        ),
      ]);
      expect(report.verdict, isNull);
    });

    test('prefers a definitive answer over an inferred one', () {
      final report = aggregateIpQuality(_ip, [
        (
          source: IpQualitySource.ipQuery,
          answer: (
            quality: quality(source: IpQualitySource.ipQuery),
            inferred: true,
          ),
          failure: null,
        ),
        (
          source: IpQualitySource.ipApiIs,
          answer: (
            quality: quality(
              source: IpQualitySource.ipApiIs,
              type: IpType.hosting,
            ),
            inferred: false,
          ),
          failure: null,
        ),
      ]);
      expect(report.verdict!.source, IpQualitySource.ipApiIs);
      expect(report.verdict!.type, IpType.hosting);
    });

    test('falls back to the inferred answer when nothing else answered', () {
      final report = aggregateIpQuality(_ip, [
        (
          source: IpQualitySource.ipQuery,
          answer: (
            quality: quality(source: IpQualitySource.ipQuery),
            inferred: true,
          ),
          failure: null,
        ),
        (
          source: IpQualitySource.identMe,
          answer: null,
          failure: IpQualitySourceStatus.timeout,
        ),
      ]);
      expect(report.verdict!.source, IpQualitySource.ipQuery);
    });

    test('ORs risk flags across every source that answered', () {
      final report = aggregateIpQuality(_ip, [
        (
          source: IpQualitySource.ipApiIs,
          answer: (
            quality: quality(source: IpQualitySource.ipApiIs),
            inferred: false,
          ),
          failure: null,
        ),
        (
          source: IpQualitySource.ipLocate,
          answer: (
            quality: quality(source: IpQualitySource.ipLocate, isTor: true),
            inferred: false,
          ),
          failure: null,
        ),
        (
          source: IpQualitySource.proxyCheck,
          answer: (
            quality: quality(
              source: IpQualitySource.proxyCheck,
              isVpn: true,
              isProxy: true,
            ),
            inferred: false,
          ),
          failure: null,
        ),
      ]);
      final verdict = report.verdict!;
      // The winning source is the first definitive answer (ipApiIs), but the
      // Tor/VPN/proxy flags raised by the other two still carry into it.
      expect(verdict.source, IpQualitySource.ipApiIs);
      expect(verdict.isTor, isTrue);
      expect(verdict.isVpn, isTrue);
      expect(verdict.isProxy, isTrue);
    });
  });

  group('IpQualityExt.level', () {
    test('tor or abuse flags always read as risky', () {
      const q = IpQuality(
        ip: _ip,
        source: IpQualitySource.identMe,
        type: IpType.residential,
        isTor: true,
      );
      expect(q.level, IpQualityLevel.risky);
    });

    test('hosting without risk flags reads as normal', () {
      const q = IpQuality(
        ip: _ip,
        source: IpQualitySource.identMe,
        type: IpType.hosting,
      );
      expect(q.level, IpQualityLevel.normal);
    });

    test('residential, mobile and business read as good', () {
      for (final type in [IpType.residential, IpType.mobile, IpType.business]) {
        final q = IpQuality(
          ip: _ip,
          source: IpQualitySource.identMe,
          type: type,
        );
        expect(q.level, IpQualityLevel.good);
      }
    });
  });
}
