import 'package:fl_clash/ingest/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picks a subscription URL', () {
    expect(
      firstIngestable(const ['https://example.com/sub?token=abc']),
      'https://example.com/sub?token=abc',
    );
  });

  test('picks a share link', () {
    const link = 'vless://uuid@1.2.3.4:443?type=tcp&security=tls#node';
    expect(firstIngestable(const [link]), link);
  });

  test(
    'picks a base64 subscription blob, which the old prefix gate rejected',
    () {
      // base64 of a single vless:// share link — the importer ingests it, so the
      // gallery-QR path must too.
      const blob =
          'dmxlc3M6Ly91dWlkQDEuMi4zLjQ6NDQzP3R5cGU9dGNwJnNlY3VyaXR5PXRscyNub2Rl';
      expect(firstIngestable(const [blob]), blob);
    },
  );

  test('picks a clash document', () {
    const doc = 'proxies:\n  - name: a\n    type: ss\n';
    expect(firstIngestable(const [doc]), doc);
  });

  test('returns null for a decoded but non-importable payload', () {
    expect(firstIngestable(const ['just some text']), isNull);
  });

  test('returns null for an empty list instead of throwing', () {
    expect(firstIngestable(const []), isNull);
  });

  test('skips null and empty entries', () {
    expect(
      firstIngestable(const [null, '', 'https://e.com/s']),
      'https://e.com/s',
    );
  });

  test('skips a non-importable barcode to reach an importable one', () {
    expect(
      firstIngestable(const ['WIFI:S=net;P=pw;;', 'https://e.com/s']),
      'https://e.com/s',
    );
  });
}
