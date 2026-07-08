import 'package:fl_clash/ingest/normalize.dart';
import 'package:fl_clash/ingest/registry.dart';

// The result of ingesting one input: what it normalized to, the subscription
// metadata read from response headers, and the raw resolved body (for clash
// passthrough, which normalize deliberately leaves empty).
typedef Ingested = ({Normalized normalized, SubMeta meta, String body});

typedef SubMeta = ({
  String? userinfo,
  String? title,
  String? disposition,
  int? updateHours,
});

const SubMeta _noMeta = (
  userinfo: null,
  title: null,
  disposition: null,
  updateHours: null,
);

// One ingestion path for both entry points: resolve any wrapper, fetch iff the
// resolved input is a URL, then normalize. Inline content (a share link, pasted
// xray/base64) skips the fetch. Callers synthesize or inject the result.
Future<Ingested> ingest(String input, {Map<String, String>? headers}) async {
  final resolved = resolveInput(input.trim());
  if (isSubscriptionUrl(resolved)) {
    final res = await fetchSubscription(resolved, headers: headers);
    return (
      normalized: normalize(res.body),
      meta: _readMeta(res.headers),
      body: res.body,
    );
  }
  return (normalized: normalize(resolved), meta: _noMeta, body: resolved);
}

SubMeta _readMeta(Map<String, String> headers) => (
  userinfo: headers['subscription-userinfo'],
  title: headers['profile-title'],
  disposition: headers['content-disposition'],
  updateHours: int.tryParse(headers['profile-update-interval'] ?? ''),
);
