import 'package:fl_clash/ingest/happ/happ_identity.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:fl_clash/ingest/registry.dart';
import 'package:yaml/yaml.dart';

typedef HeaderDecorator =
    Future<Map<String, String>> Function({Map<String, String>? base});

// Fetches a subscription twice, honest and as the Happ client, and keeps the
// body that normalizes to more proxies (some panels gate their full node set
// behind the Happ identity). A tie keeps the honest body to avoid leaking the
// device id when it buys nothing; if one side fails the other is used.
class HappFetchStrategy implements FetchStrategy {
  HappFetchStrategy({required RawFetch rawFetch, HeaderDecorator? happIdentity})
    : _rawFetch = rawFetch,
      _happIdentity = happIdentity ?? happHeaders;

  final RawFetch _rawFetch;
  final HeaderDecorator _happIdentity;

  @override
  Future<FetchResult> fetch(String url, {Map<String, String>? headers}) async {
    final honestFuture = _tryFetch(url, headers);
    final happFuture = _happIdentity(
      base: headers,
    ).then((h) => _tryFetch(url, h)).catchError((_) => null);
    final [honest, happ] = await Future.wait([honestFuture, happFuture]);

    if (happ != null &&
        (honest == null || _count(happ.body) > _count(honest.body))) {
      return happ;
    }
    if (honest != null) return honest;
    if (happ != null) return happ;
    throw StateError('both subscription fetches failed');
  }

  Future<FetchResult?> _tryFetch(
    String url,
    Map<String, String>? headers,
  ) async {
    try {
      return await _rawFetch(url, headers: headers);
    } catch (_) {
      return null;
    }
  }

  // Compare bodies by node count across formats. A clash document normalizes to
  // zero (it is a passthrough, not a proxy list), so count its `proxies:` block
  // directly, otherwise a thin xray body would always beat a full clash config.
  int _count(String body) {
    if (isClashDocument(body)) return _clashProxyCount(body);
    return normalize(body).proxies.length;
  }

  int _clashProxyCount(String body) {
    try {
      final doc = loadYaml(body);
      final proxies = doc is Map ? doc['proxies'] : null;
      return proxies is List ? proxies.length : 0;
    } catch (_) {
      return 0;
    }
  }
}
