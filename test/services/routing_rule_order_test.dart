import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _exitOnly = '''
proxies: []
proxy-groups:
  - {name: PROXY, type: select, proxies: [DIRECT]}
''';

void main() {
  test('per-app rules sit below safety carve-outs and above policy rules', () {
    const profile =
        '''
$_exitOnly
rules:
  - IP-CIDR,192.168.0.0/16,DIRECT
  - GEOIP,private,DIRECT
  - DOMAIN-SUFFIX,ads.example,REJECT
  - GEOIP,RU,DIRECT
  - PROCESS-NAME,com.foo,PROXY
  - MATCH,PROXY
''';
    final out = RoutingModel.fromYaml(profile).toYaml(profile);
    final iLan = out.indexOf('IP-CIDR,192.168.0.0/16,DIRECT');
    final iGeoPriv = out.indexOf('GEOIP,private,DIRECT');
    final iApp = out.indexOf('PROCESS-NAME,com.foo,PROXY');
    final iAds = out.indexOf('DOMAIN-SUFFIX,ads.example,REJECT');
    final iGeoRu = out.indexOf('GEOIP,RU,DIRECT');
    final iMatch = out.indexOf('MATCH,PROXY');
    for (final i in [iLan, iGeoPriv, iApp, iAds, iGeoRu, iMatch]) {
      expect(i, greaterThanOrEqualTo(0));
    }
    // safety (LAN, private geo) above per-app
    expect(iLan, lessThan(iApp));
    expect(iGeoPriv, lessThan(iApp));
    // per-app above policy (ad-block, domestic geo)
    expect(iApp, lessThan(iAds));
    expect(iApp, lessThan(iGeoRu));
    // terminal MATCH last
    expect(iMatch, greaterThan(iGeoRu));
  });

  test('an anti-leak host route (/32 DIRECT) stays above per-app', () {
    const profile =
        '''
$_exitOnly
rules:
  - IP-CIDR,45.142.164.71/32,DIRECT
  - PROCESS-NAME,com.foo,PROXY
  - MATCH,PROXY
''';
    final out = RoutingModel.fromYaml(profile).toYaml(profile);
    expect(
      out.indexOf('45.142.164.71/32'),
      lessThan(out.indexOf('PROCESS-NAME,com.foo')),
    );
  });

  test('round-trip is idempotent once normalized to safety/per-app/policy', () {
    const profile =
        '''
$_exitOnly
rules:
  - IP-CIDR,10.0.0.0/8,DIRECT
  - PROCESS-NAME,com.foo,PROXY
  - GEOIP,RU,DIRECT
  - MATCH,PROXY
''';
    final once = RoutingModel.fromYaml(profile).toYaml(profile);
    final twice = RoutingModel.fromYaml(once).toYaml(once);
    expect(twice, once);
  });
}
