import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _twoGroupProfile = '''
proxies: []
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
  - {name: Final, type: select, proxies: [PROXY, DIRECT]}
rules:
  - DOMAIN-SUFFIX,ya.ru,DIRECT
  - MATCH,Final
''';

void main() {
  test('terminal MATCH to a non-exit group round-trips verbatim', () {
    final m = RoutingModel.fromYaml(_twoGroupProfile);
    // The exit is the first non-hidden group (PROXY), not the terminal's group.
    expect(m.exitGroup, 'PROXY');

    // A no-op save must not silently reroute the catch-all MATCH,Final to the
    // exit group (MATCH,PROXY).
    final out = m.toYaml(_twoGroupProfile);
    expect(out, contains('MATCH,Final'));
    expect(out.contains('MATCH,PROXY'), isFalse);
  });

  test('terminal MATCH to the exit group is the modeled default route', () {
    const profile = '''
proxies: []
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
rules:
  - MATCH,PROXY
''';
    final m = RoutingModel.fromYaml(profile);
    expect(m.defaultRoute, toVpn);
    expect(m.toYaml(profile), contains('MATCH,PROXY'));
  });
}
