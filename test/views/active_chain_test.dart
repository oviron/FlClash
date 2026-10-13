import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/views/proxies/group_chain.dart';
import 'package:flutter_test/flutter_test.dart';

Group _g(
  String name, {
  String? now,
  GroupType type = GroupType.Selector,
  String? testUrl,
}) => Group(name: name, type: type, now: now, testUrl: testUrl);

void main() {
  test('walks the entry group through nested groups to the leaf', () {
    final groups = [
      _g('VPN', now: 'Auto'),
      _g('Auto', now: 'qde-direct', type: GroupType.URLTest),
    ];
    expect(resolveChain(groups, 'VPN'), ['VPN', 'Auto', 'qde-direct']);
  });

  test('stops when the selection names a non-group leaf', () {
    expect(resolveChain([_g('VPN', now: 'node-1')], 'VPN'), ['VPN', 'node-1']);
  });

  test('stops on an empty selection', () {
    expect(resolveChain([_g('VPN', now: '')], 'VPN'), ['VPN']);
    expect(resolveChain([_g('VPN')], 'VPN'), ['VPN']);
  });

  test('guards against a self-referencing cycle', () {
    final groups = [_g('A', now: 'B'), _g('B', now: 'A')];
    expect(resolveChain(groups, 'A'), ['A', 'B']);
  });

  group('the chain the strip shows', () {
    test('resolves hops outside the mode-filtered list', () {
      // currentGroupsState blanks `now`, so resolving inside it would stop at
      // the entry group and the strip would show a single name.
      final visible = [
        _g('VPN', now: ''),
        _g('Auto', now: '', type: GroupType.URLTest),
      ];
      final all = [
        _g('VPN', now: 'Auto'),
        _g('Auto', now: 'qde-direct', type: GroupType.URLTest),
      ];
      expect(activeChain(visible, all), ['VPN', 'Auto', 'qde-direct']);
    });

    test('is empty when no group is visible in this mode', () {
      expect(activeChain([], [_g('VPN', now: 'node-1')]), isEmpty);
    });

    test('falls back to the entry name when the group is gone', () {
      expect(activeChain([_g('VPN', now: '')], []), ['VPN']);
    });
  });

  group('the url the leaf is measured under', () {
    test('is that of the group that picked it, not the outer one', () {
      final groups = [
        _g('Outer', now: 'Inner', testUrl: 'https://outer'),
        _g('Inner', now: 'node', testUrl: 'https://inner'),
      ];
      expect(
        leafTestUrl(groups, resolveChain(groups, 'Outer')),
        'https://inner',
      );
    });

    test('is the default for a chain of one', () {
      expect(leafTestUrl([_g('VPN', testUrl: 'https://vpn')], ['VPN']), isNull);
    });
  });
}
