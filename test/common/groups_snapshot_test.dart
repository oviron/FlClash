import 'package:fl_clash/common/groups_snapshot.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groups snapshot round-trip', () {
    test('preserves group type, nested proxies, and fields', () {
      const groups = [
        Group(
          type: GroupType.Selector,
          name: 'PROXY',
          now: 'auto',
          icon: 'x',
          hidden: false,
          testUrl: 'http://gstatic/generate_204',
          all: [
            Proxy(name: 'auto', type: 'URLTest'),
            Proxy(name: 'hk', type: 'Shadowsocks'),
          ],
        ),
        Group(
          type: GroupType.URLTest,
          name: 'auto',
          all: [Proxy(name: 'hk', type: 'Shadowsocks')],
        ),
      ];
      final decoded = decodeGroupsSnapshot(encodeGroupsSnapshot(groups));
      expect(decoded, groups);
    });

    test('malformed input decodes to an empty list', () {
      expect(decodeGroupsSnapshot('not json'), isEmpty);
      expect(decodeGroupsSnapshot('{"a":1}'), isEmpty);
      expect(decodeGroupsSnapshot(''), isEmpty);
    });
  });
}
