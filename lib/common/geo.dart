import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/path.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

// One geo database. Filenames are scrambled (MMDB=GEOIP.metadb, ASN=ASN.mmdb),
// so the config key is explicit, never derived from the name.
class GeoItem {
  final String label;
  final String key;
  final String fileName;

  const GeoItem({
    required this.label,
    required this.key,
    required this.fileName,
  });

  String get updatingKey => 'geodata_$key';
}

const geoItems = <GeoItem>[
  GeoItem(label: 'GEOIP', fileName: GEOIP, key: 'geoip'),
  GeoItem(label: 'GEOSITE', fileName: GEOSITE, key: 'geosite'),
  GeoItem(label: 'MMDB', fileName: MMDB, key: 'mmdb'),
  GeoItem(label: 'ASN', fileName: ASN, key: 'asn'),
];

(int, int) _varint(Uint8List b, int i) {
  var shift = 0;
  var result = 0;
  while (i < b.length) {
    final byte = b[i];
    i++;
    result |= (byte & 0x7f) << shift;
    if (byte & 0x80 == 0) break;
    shift += 7;
  }
  return (result, i);
}

// GEOSITE.dat category codes, lowercased + sorted. Walks the protobuf directly:
// GeoSiteList { repeated GeoSite entry=1 }, each GeoSite's first field is
// `string country_code=1`; the rest of the entry is skipped.
List<String> parseGeositeCategories(Uint8List data) {
  final codes = <String>[];
  final n = data.length;
  var i = 0;
  while (i < n) {
    final (tag, afterTag) = _varint(data, i);
    i = afterTag;
    final field = tag >> 3;
    if (tag & 7 != 2) {
      (_, i) = _varint(data, i); // non length-delimited: skip its payload
      continue;
    }
    final (len, afterLen) = _varint(data, i);
    i = afterLen;
    final end = i + len;
    if (end > n) break;
    if (field == 1) {
      final (t2, afterT2) = _varint(data, i);
      if (t2 >> 3 == 1 && t2 & 7 == 2) {
        final (l2, afterL2) = _varint(data, afterT2);
        if (afterL2 + l2 <= end) {
          codes.add(
            utf8
                .decode(
                  data.sublist(afterL2, afterL2 + l2),
                  allowMalformed: true,
                )
                .toLowerCase(),
          );
        }
      }
    }
    i = end;
  }
  codes.sort();
  return codes;
}

// parseGeositeCategories from the on-device GEOSITE.dat; empty when it has not
// been downloaded yet or cannot be read. Only the routing picker needs a parse.
Future<List<String>> loadGeositeCategories() async {
  try {
    final file = File(join(await appPath.homeDirPath, GEOSITE));
    if (!file.existsSync()) return const [];
    return parseGeositeCategories(await file.readAsBytes());
  } catch (_) {
    return const [];
  }
}

// Cheap presence check (no full parse) for the seed guard and the updater's
// missing-DB gate.
Future<bool> geositeReady() async {
  final file = File(join(await appPath.homeDirPath, GEOSITE));
  return file.existsSync() && await file.length() > 0;
}

Future<void> seedGeositeIfMissing() async {
  if (await geositeReady()) return;
  try {
    final data = await rootBundle.load('assets/geo/geosite.dat');
    final file = File(join(await appPath.homeDirPath, GEOSITE));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
  } catch (e) {
    commonPrint.log('geosite seed: $e', logLevel: LogLevel.warning);
  }
}
