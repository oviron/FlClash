import 'dart:convert';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/ingest/synthesize.dart';
import 'package:fl_clash/ingest/xray.dart';
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

    final cfg = synthesize((
      proxies: [parseShareLink(link)!],
      groups: null,
      skipped: 0,
    ));
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

    final proxies = parseSubscriptionContent(body).proxies;
    expect(proxies.length, 2);

    final reparsed = loadYaml(
      yaml.encode(synthesize((proxies: proxies, groups: null, skipped: 0))),
    );
    expect((reparsed['proxies'] as List).length, 2);
    expect((reparsed['proxy-groups'][0]['proxies'] as List).length, 2);
  });

  test('xray-JSON -> one group per remark-profile under a PROXY select', () {
    const sub = '''
[
  {"remarks":"Main","outbounds":[
    {"protocol":"vless","settings":{"vnext":[{"address":"1.1.1.1","port":443,"users":[{"id":"u1"}]}]},
      "streamSettings":{"network":"grpc","security":"reality",
        "grpcSettings":{"serviceName":"g"},
        "realitySettings":{"serverName":"s","publicKey":"P","shortId":"a"}}}]},
  {"remarks":"Antiblock","outbounds":[
    {"protocol":"hysteria","settings":{"address":"2.2.2.2","port":443,"version":2},
      "streamSettings":{"hysteriaSettings":{"version":2,"auth":"pw"},
        "security":"tls","tlsSettings":{"alpn":["h3"]}}}]}
]
''';
    expect(classifyArtifact(sub), ArtifactKind.xrayJson);
    final xrayGroups = parseXrayJsonGroups(sub);
    final cfg = synthesize((
      proxies: [for (final g in xrayGroups) ...g.proxies],
      groups: xrayGroups,
      skipped: 0,
    ));
    final reparsed = loadYaml(applyQuickStartRouting(yaml.encode(cfg)));

    final groups = reparsed['proxy-groups'] as List;
    final proxyGroup = groups.firstWhere((g) => g['name'] == 'PROXY');
    expect(proxyGroup['type'], 'select');
    expect(List<String>.from(proxyGroup['proxies'] as List), [
      'Main',
      'Antiblock',
    ]);
    // Each remark-profile is its own url-test group.
    final main = groups.firstWhere((g) => g['name'] == 'Main');
    expect(main['type'], 'url-test');
    expect((main['proxies'] as List).single, 'Main 01');
    final anti = groups.firstWhere((g) => g['name'] == 'Antiblock');
    expect((anti['proxies'] as List).single, 'Antiblock 01');
    // hysteria2 survived end to end.
    final hy = (reparsed['proxies'] as List).firstWhere(
      (p) => p['type'] == 'hysteria2',
    );
    expect(hy['password'], 'pw');
    expect(reparsed['rules'].last, 'MATCH,PROXY');
  });
}
