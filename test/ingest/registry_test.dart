import 'package:fl_clash/ingest/registry.dart';
import 'package:flutter_test/flutter_test.dart';

class _Rewrite implements Resolver {
  _Rewrite(this.from, this.to);
  final String from;
  final String to;
  @override
  String? resolve(String input) => input == from ? to : null;
}

class _FakeFetch implements FetchStrategy {
  int calls = 0;
  @override
  Future<FetchResult> fetch(String url, {Map<String, String>? headers}) async {
    calls++;
    return (body: 'body-of:$url', headers: const <String, String>{});
  }
}

void main() {
  setUp(resetIngestRegistry);

  group('resolver registry', () {
    test('no resolvers -> input passes through unchanged', () {
      expect(resolveInput('https://h/happ?token=x'), 'https://h/happ?token=x');
    });

    test('a registered resolver rewrites its input', () {
      registerResolver(_Rewrite('a', 'b'));
      expect(resolveInput('a'), 'b');
      expect(resolveInput('other'), 'other');
    });

    test('first resolver returning non-null wins', () {
      registerResolver(_Rewrite('a', 'first'));
      registerResolver(_Rewrite('a', 'second'));
      expect(resolveInput('a'), 'first');
    });

    test('reset clears resolvers', () {
      registerResolver(_Rewrite('a', 'b'));
      resetIngestRegistry();
      expect(resolveInput('a'), 'a');
    });
  });

  group('fetch strategy registry', () {
    test('dispatches to the registered strategy', () async {
      final fake = _FakeFetch();
      registerFetchStrategy(fake);
      final res = await fetchSubscription('https://h/sub');
      expect(res.body, 'body-of:https://h/sub');
      expect(fake.calls, 1);
    });

    test('no strategy set -> StateError (app must init)', () {
      expect(() => fetchSubscription('https://h/sub'), throwsStateError);
    });
  });
}
