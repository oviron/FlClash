import 'package:fl_clash/ingest/happ/happ_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final r = HappResolver();

  group('HappResolver web launcher', () {
    test('/happ?token -> /api/sub?token on the same origin', () {
      expect(
        r.resolve('https://links.clovpn.org/happ?token=abc'),
        'https://links.clovpn.org/api/sub?token=abc',
      );
    });

    test('/happ?id also rewrites', () {
      expect(r.resolve('https://h/happ?id=42'), 'https://h/api/sub?id=42');
    });

    test('keeps every query param on rewrite', () {
      expect(
        r.resolve('https://h/happ?a=1&token=x&b=2'),
        'https://h/api/sub?a=1&token=x&b=2',
      );
    });

    test('path must be exactly /happ (no rewrite on /sub/happ-x)', () {
      expect(r.resolve('https://h/sub/happ-x?token=abc'), isNull);
    });

    test('/happ without token/id passes through', () {
      expect(r.resolve('https://h/happ'), isNull);
      expect(r.resolve('https://h/happ?foo=bar'), isNull);
    });
  });

  group('HappResolver happ:// deep link', () {
    test('happ://add/<url> unwraps to the url', () {
      expect(r.resolve('happ://add/https://h/s'), 'https://h/s');
    });

    test('happ://add/<percent-encoded url> decodes', () {
      expect(
        r.resolve('happ://add/https%3A%2F%2Fh%2Fs%3Ftoken%3Dx'),
        'https://h/s?token=x',
      );
    });

    test('happ://add/ with a non-url payload passes through', () {
      expect(r.resolve('happ://add/not-a-url'), isNull);
    });
  });

  group('HappResolver passthrough', () {
    test('a plain subscription URL is left untouched', () {
      expect(r.resolve('https://h/api/sub?token=x'), isNull);
      expect(r.resolve('https://m7.gosapi.com/sub/abc'), isNull);
    });

    test('a share link is left for the normalizer', () {
      expect(r.resolve('vless://u@h:443#x'), isNull);
    });
  });
}
