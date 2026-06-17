import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/views/proxies/group_chain.dart';
import 'package:flutter_test/flutter_test.dart';

Group _g(String name, {String? now, GroupType type = GroupType.Selector}) =>
    Group(name: name, type: type, now: now);

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
}
