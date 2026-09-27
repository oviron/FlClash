import 'dart:io';

import 'package:fl_clash/common/http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late HttpServer server;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('tls_test');
    final res = await Process.run('openssl', [
      'req',
      '-x509',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-days',
      '1',
      '-subj',
      '/CN=127.0.0.1',
      '-keyout',
      '${dir.path}/key.pem',
      '-out',
      '${dir.path}/cert.pem',
    ]);
    expect(res.exitCode, 0, reason: '${res.stderr}');
  });

  tearDownAll(() => dir.delete(recursive: true));

  setUp(() async {
    final context = SecurityContext()
      ..useCertificateChain('${dir.path}/cert.pem')
      ..usePrivateKey('${dir.path}/key.pem');
    server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    server.listen((req) => req.response.close());
  });

  tearDown(() => server.close(force: true));

  test('the app-wide client rejects an untrusted certificate', () async {
    final client = FlClashHttpOverrides().createHttpClient(null);
    addTearDown(client.close);

    await expectLater(
      client
          .getUrl(Uri.parse('https://127.0.0.1:${server.port}/'))
          .then((req) => req.close()),
      throwsA(isA<HandshakeException>()),
    );
  });
}
