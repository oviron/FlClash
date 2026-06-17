import 'package:fl_clash/profile_routing/provider_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('maskProviderUrl', () {
    test('masks basic-auth userinfo, keeping host and path', () {
      expect(
        maskProviderUrl('https://user:pass@sub.example.com:8443/govpn.yaml'),
        'https://••••@sub.example.com:8443/govpn.yaml',
      );
    });

    test('masks username-only userinfo', () {
      expect(
        maskProviderUrl('https://token@sub.example.com/x'),
        'https://••••@sub.example.com/x',
      );
    });

    test('leaves a URL without userinfo unchanged', () {
      const url = 'https://sub.example.com/govpn.yaml';
      expect(maskProviderUrl(url), url);
    });

    test('does not treat a path @ as userinfo', () {
      const url = 'https://example.com/path@v2/list';
      expect(maskProviderUrl(url), url);
    });

    test('leaves a non-URL string unchanged', () {
      expect(maskProviderUrl('not a url'), 'not a url');
      expect(maskProviderUrl(''), '');
    });
  });
}
