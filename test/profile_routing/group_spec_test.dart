import 'package:fl_clash/profile_routing/group_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroupSpec.extra', () {
    test('returns exactly the non-modeled keys with their values', () {
      final g = GroupSpec({
        'name': 'G',
        'type': 'url-test',
        'proxies': ['a'],
        'strategy': 'round-robin',
        'exclude-type': 'Shadowsocks',
        'icon': 'x.png',
      });
      expect(g.extra, {
        'strategy': 'round-robin',
        'exclude-type': 'Shadowsocks',
        'icon': 'x.png',
      });
      expect(g.extra.keys, isNot(contains('name')));
      expect(g.extra.keys, isNot(contains('proxies')));
    });

    test('is empty when only modeled keys are present', () {
      expect(GroupSpec({'name': 'G', 'type': 'select'}).extra, isEmpty);
    });
  });

  group('GroupSpec int accessors', () {
    test('parse int, numeric string, and num; null on non-numeric/absent', () {
      expect(GroupSpec({'interval': 300}).interval, 300);
      expect(GroupSpec({'interval': '600'}).interval, 600);
      expect(GroupSpec({'tolerance': 50}).tolerance, 50);
      expect(GroupSpec({'tolerance': 'x'}).tolerance, isNull);
      expect(GroupSpec({}).interval, isNull);
    });
  });
}
