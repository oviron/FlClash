import 'package:fl_clash/common/request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirectSafeHeaders', () {
    final headers = {
      'User-Agent': 'Happ/3.6.0',
      'x-hwid': 'DEVICE-ID',
      'Authorization': 'Bearer secret',
    };

    test('keeps every header on a same-host redirect', () {
      final out = redirectSafeHeaders(
        headers,
        Uri.parse('https://panel.example/sub'),
        Uri.parse('https://panel.example/sub2'),
      );
      expect(out, headers);
    });

    test('strips the device id and auth on a cross-host redirect', () {
      final out = redirectSafeHeaders(
        headers,
        Uri.parse('https://panel.example/sub'),
        Uri.parse('https://cdn.other/redir'),
      );
      expect(out, {'User-Agent': 'Happ/3.6.0'});
    });

    test('null headers stay null', () {
      expect(
        redirectSafeHeaders(
          null,
          Uri.parse('https://a/'),
          Uri.parse('https://b/'),
        ),
        isNull,
      );
    });
  });
}
