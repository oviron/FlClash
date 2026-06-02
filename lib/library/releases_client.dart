import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/library/model.dart';

// Direct GitHub fetch: the app UID is excluded from the tun, and findProxy=DIRECT
// bypasses the app-wide HttpOverrides that force the proxy.
Dio _directDio() => Dio()
  ..httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (_, _, _) => true;
      client.findProxy = (_) => 'DIRECT';
      return client;
    },
  );

class ReleasesClient {
  final Dio _dio = _directDio();

  // Unauthenticated GitHub API: 60 req/hr. Callers should cache and refresh on demand.
  Future<List<LibraryRelease>> fetch(String label) async {
    final res = await _dio.get<List<dynamic>>(
      'https://api.github.com/repos/${repoFor(label)}/releases',
      options: Options(headers: {'Accept': 'application/vnd.github+json'}),
    );
    final out = <LibraryRelease>[];
    for (final raw in res.data ?? const []) {
      final r = (raw as Map).cast<String, dynamic>();
      final assets = ((r['assets'] as List?) ?? const [])
          .map((a) => (a as Map).cast<String, dynamic>())
          .toList();
      final meta = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.metadata.json'),
      );
      final aar = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.aar'),
      );
      final asc = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.aar.asc'),
      );
      if (meta == null || aar == null || asc == null) continue;

      final metaRes = await _dio.get<String>(
        meta['browser_download_url'] as String,
        options: Options(responseType: ResponseType.plain),
      );
      final m = (jsonDecode(metaRes.data ?? '{}') as Map).cast<String, dynamic>();
      final core = (m['core'] as Map?)?.cast<String, dynamic>() ?? const {};
      final tag = r['tag_name'] as String;

      out.add(
        LibraryRelease(
          label: label,
          version: tag.startsWith('v') ? tag.substring(1) : tag,
          coreName: core['name'] as String? ?? label,
          coreVersion: core['version'] as String? ?? '',
          bridgeAbi: (m['bridgeABI'] as num?)?.toInt() ?? -1,
          abis: ((m['abis'] as List?) ?? const []).cast<String>(),
          aarUrl: aar['browser_download_url'] as String,
          ascUrl: asc['browser_download_url'] as String,
          sha256: m['sha256'] as String? ?? '',
        ),
      );
    }
    return out;
  }

  // Downloads .aar + .asc into [tempDirPath] via a .part temp + atomic rename.
  Future<({String aar, String asc})> download(
    LibraryRelease rel,
    String tempDirPath,
  ) async {
    final base = '$tempDirPath/${rel.label}-v${rel.version}';
    final aar = '$base.aar';
    final asc = '$aar.asc';
    await _downloadTo(rel.aarUrl, aar);
    await _downloadTo(rel.ascUrl, asc);
    return (aar: aar, asc: asc);
  }

  Future<void> _downloadTo(String url, String dest) async {
    final part = '$dest.part';
    await _dio.download(url, part);
    await File(part).rename(dest);
  }
}
