import 'dart:convert';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('share link -> config -> valid YAML, reality preserved', () {
    const link =
        'vless://uuid-1@1.2.3.4:443?security=reality&sni=ex.com&fp=chrome'
        '&pbk=PUBKEY&sid=ab12&type=tcp&flow=xtls-rprx-vision#node';
    expect(classifyArtifact(link), ArtifactKind.shareLink);

    final cfg = synthesizeConfig([parseShareLink(link)!]);
    expect(cfg['proxies'][0]['reality-opts']['public-key'], 'PUBKEY');
    expect(cfg['proxies'][0]['flow'], 'xtls-rprx-vision');
    expect((cfg['proxy-groups'][0]['proxies'] as List).first, 'node');

    // Encodes to valid YAML and re-parses losslessly (catches any
    // non-serializable value before the native validateConfig sees it).
    final full = applyQuickStartRouting(yaml.encode(cfg));
    final reparsed = loadYaml(full);
    expect(reparsed['proxies'][0]['type'], 'vless');
    expect(reparsed['proxies'][0]['reality-opts']['public-key'], 'PUBKEY');
    expect(reparsed['rules'][0], 'MATCH,PROXY');
  });

  test('base64 subscription -> multi-node config -> valid YAML', () {
    final body = base64.encode(
      utf8.encode(
        'vless://u1@1.2.3.4:443?security=tls&type=tcp#a\n'
        'ss://${base64.encode(utf8.encode('aes-256-gcm:pw'))}@2.2.2.2:8388#b\n',
      ),
    );
    expect(classifyArtifact(body), ArtifactKind.base64List);

    final proxies = parseSubscriptionContent(body);
    expect(proxies.length, 2);

    final reparsed = loadYaml(yaml.encode(synthesizeConfig(proxies)));
    expect((reparsed['proxies'] as List).length, 2);
    expect((reparsed['proxy-groups'][0]['proxies'] as List).length, 2);
  });
}
