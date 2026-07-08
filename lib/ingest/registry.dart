// The two extension points the Happ module (or any future wrapper module) plugs
// into. The core registers nothing here: with an empty resolver list and the
// core single-GET fetch strategy, every non-wrapper input still ingests.

typedef FetchResult = ({String body, Map<String, String> headers});

// Stage 0: rewrite a launcher/wrapper input to a concrete subscription URL or
// inline body. Return null to pass the input through untouched.
abstract class Resolver {
  String? resolve(String input);
}

// Stage 1: fetch a subscription URL to its body + response headers. The core
// default does one honest GET; a module may swap in a richer strategy.
abstract class FetchStrategy {
  Future<FetchResult> fetch(String url, {Map<String, String>? headers});
}

final List<Resolver> _resolvers = [];
FetchStrategy? _fetchStrategy;

void registerResolver(Resolver resolver) => _resolvers.add(resolver);

void registerFetchStrategy(FetchStrategy strategy) => _fetchStrategy = strategy;

void resetIngestRegistry() {
  _resolvers.clear();
  _fetchStrategy = null;
}

// Apply resolvers in registration order; the first rewrite wins.
String resolveInput(String input) {
  for (final resolver in _resolvers) {
    final out = resolver.resolve(input);
    if (out != null) return out;
  }
  return input;
}

Future<FetchResult> fetchSubscription(
  String url, {
  Map<String, String>? headers,
}) {
  final strategy = _fetchStrategy;
  if (strategy == null) {
    throw StateError('ingest fetch strategy not set (call initIngest first)');
  }
  return strategy.fetch(url, headers: headers);
}
