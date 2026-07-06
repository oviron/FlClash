import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/path.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

/// Geo databases the app manages: (mihomo geoType label, on-disk file name).
const geoFileItems = <(String, String)>[
  ('GEOIP', GEOIP),
  ('GEOSITE', GEOSITE),
  ('MMDB', MMDB),
  ('ASN', ASN),
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

/// Category codes (`country_code`) of every entry in a v2ray / MetaCubeX
/// GEOSITE.dat, lowercased and sorted. Walks the protobuf directly (no generated
/// bindings): GeoSiteList { repeated GeoSite entry = 1 }, GeoSite reads its
/// first field, the `string country_code = 1`, then skips the rest of the entry.
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

/// [parseGeositeCategories] loaded from the on-device GEOSITE.dat; empty when the
/// geo database has not been downloaded yet or cannot be read.
Future<List<String>> loadGeositeCategories() async {
  try {
    final file = File(join(await appPath.homeDirPath, GEOSITE));
    if (!file.existsSync()) return const [];
    return parseGeositeCategories(await file.readAsBytes());
  } catch (_) {
    return const [];
  }
}

/// Copies the bundled baseline GEOSITE.dat into the core home dir when the
/// on-device file is missing or unreadable (empty categories). Offline-safe
/// first-run guard so a GEOSITE-rule profile never fails to apply on a fresh
/// install before the network updater has run.
Future<void> seedGeositeIfMissing() async {
  if ((await loadGeositeCategories()).isNotEmpty) return;
  try {
    final data = await rootBundle.load('assets/geo/geosite.dat');
    final file = File(join(await appPath.homeDirPath, GEOSITE));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
  } catch (_) {}
}
