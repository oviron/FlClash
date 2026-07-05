import 'dart:convert';

import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

String _b64(String s) => base64.encode(utf8.encode(s));

void main() {
  group('classifyArtifact', () {
    test('share link', () {
      expect(
        classifyArtifact('vless://uuid@1.2.3.4:443?security=tls#a'),
        ArtifactKind.shareLink,
      );
      expect(
        classifyArtifact('  trojan://pw@h:443#x '),
        ArtifactKind.shareLink,
      );
    });

    test('subscription url', () {
      expect(
        classifyArtifact('https://sub.example.com/link/abc'),
        ArtifactKind.subscriptionUrl,
      );
    });

    test('clash yaml', () {
      expect(
        classifyArtifact('proxies:\n  - name: a\n    type: vless'),
        ArtifactKind.clashYaml,
      );
    });

    test('base64 list', () {
      final blob = _b64('vless://uuid@1.2.3.4:443?security=tls#a\n');
      expect(classifyArtifact(blob), ArtifactKind.base64List);
    });

    test('xray json (happ subscription): a list with outbounds', () {
      expect(
        classifyArtifact(
          '[{"remarks":"a","outbounds":[{"protocol":"vless"}]}]',
        ),
        ArtifactKind.xrayJson,
      );
    });

    test('xray detection is precise (list + outbounds only)', () {
      // A JSON list without `outbounds` is not xray.
      expect(classifyArtifact('[1,2,3]'), ArtifactKind.unknown);
      // JSON objects never trigger the list-only xray branch (SIP008, json-clash).
      expect(
        classifyArtifact('{"version":1,"servers":[]}'),
        ArtifactKind.unknown,
      );
      expect(
        classifyArtifact('{"proxies":[{"name":"a"}]}'),
        ArtifactKind.unknown,
      );
    });

    test('unknown', () {
      expect(classifyArtifact('hello world'), ArtifactKind.unknown);
    });
  });

  group('synthesizeConfig', () {
    test('wraps proxies into the node envelope (topology only)', () {
      final cfg = synthesizeConfig([
        {'name': 'n1', 'type': 'vless', 'server': '1.2.3.4', 'port': 443},
      ]);
      expect((cfg['proxies'] as List).length, 1);

      final groups = cfg['proxy-groups'] as List;
      expect(groups.length, 1);
      expect(groups.first['name'], 'PROXY');
      expect(groups.first['type'], 'url-test');
      expect(groups.first['proxies'], ['n1']);

      // Routing is added by the model writer, not assembled here.
      expect(cfg.containsKey('rules'), false);
      // No dns block: rely on the app's hardened model defaults.
      expect(cfg.containsKey('dns'), false);
    });

    test('applyQuickStartRouting adds the full-tunnel rule via the writer', () {
      final envelope = yaml.encode(
        synthesizeConfig([
          {'name': 'n1', 'type': 'vless', 'server': '1.2.3.4', 'port': 443},
        ]),
      );
      final full = applyQuickStartRouting(envelope);
      expect(ProfileRulesDocument(full).rules.map((r) => r.serialize()), [
        'MATCH,PROXY',
      ]);
      // The envelope's nodes and exit group survive untouched.
      expect(full, contains('n1'));
      expect(ProfileRulesDocument(full).proxyGroups.single.name, 'PROXY');
    });

    test('assigns unique non-empty names', () {
      final cfg = synthesizeConfig([
        {'type': 'vless', 'server': 'a', 'port': 1},
        {'name': '', 'type': 'vless', 'server': 'b', 'port': 2},
        {'name': 'dup', 'type': 'ss', 'server': 'c', 'port': 3},
        {'name': 'dup', 'type': 'ss', 'server': 'd', 'port': 4},
      ]);
      final proxies = (cfg['proxies'] as List).cast<Map<String, dynamic>>();
      final names = proxies.map((p) => p['name'] as String).toList();
      expect(
        names.toSet().length,
        names.length,
        reason: 'names must be unique',
      );
      expect(names.every((n) => n.isNotEmpty), true);
      expect(
        (cfg['proxy-groups'] as List).first['proxies'],
        names,
        reason: 'group references every proxy by its final name',
      );
    });

    test('throws on empty proxy list (caller guards node-count)', () {
      expect(() => synthesizeConfig([]), throwsArgumentError);
    });
  });
}
