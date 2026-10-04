import 'dart:convert';

import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

// Shape written by libmihomo's dnsquery package (Go encoding/json).
const _coreJson = '''
[
  {"domain":"example.com","type":"A","answers":["93.184.215.14"],"rcode":"NOERROR","delay":12,"time":"2026-10-04T12:34:56.123456789+03:00"},
  {"domain":"missing.test","type":"AAAA","answers":[],"rcode":"NXDOMAIN","delay":40,"time":"2026-10-04T09:00:00Z"},
  {"domain":"down.test","type":"A","answers":[],"error":"all DNS requests failed","delay":5000,"time":"2026-10-04T09:00:01.5Z"}
]
''';

void main() {
  final queries = (json.decode(_coreJson) as List)
      .cast<Map<String, dynamic>>()
      .map(DnsQuery.fromJson)
      .toList();

  test('answered query keeps answers, rcode and delay', () {
    expect(queries[0].domain, 'example.com');
    expect(queries[0].type, 'A');
    expect(queries[0].answers, ['93.184.215.14']);
    expect(queries[0].rcode, 'NOERROR');
    expect(queries[0].error, '');
    expect(queries[0].delay, 12);
  });

  test('nanosecond timestamps with an offset parse to the same instant', () {
    expect(
      queries[0].time.toUtc(),
      DateTime.utc(2026, 10, 4, 9, 34, 56, 123, 456),
    );
  });

  test('failed query carries the error without an rcode', () {
    expect(queries[1].rcode, 'NXDOMAIN');
    expect(queries[2].rcode, '');
    expect(queries[2].error, 'all DNS requests failed');
    expect(queries[2].answers, isEmpty);
  });
}
