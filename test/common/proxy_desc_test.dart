import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a node is described by its protocol', () {
    expect(
      computeProxyDesc(
        const Proxy(name: 'qd-hy2', type: 'Hysteria2'),
        groups: const [],
        selectedMap: const {},
      ),
      'Hysteria2',
    );
  });

  test('a group names the node it leads to, not its own type', () {
    final groups = [
      const Group(name: 'qde-ru', type: GroupType.URLTest, now: 'qru-hy2'),
    ];
    expect(
      computeProxyDesc(
        const Proxy(name: 'qde-ru', type: 'URLTest'),
        groups: groups,
        selectedMap: const {},
      ),
      '→ qru-hy2',
    );
  });

  test('a group walks nested groups down to the leaf', () {
    final groups = [
      const Group(name: 'VPN', type: GroupType.Selector, now: 'qde'),
      const Group(name: 'qde', type: GroupType.URLTest, now: 'qd-grpc'),
    ];
    expect(
      computeProxyDesc(
        const Proxy(name: 'VPN', type: 'Selector'),
        groups: groups,
        selectedMap: const {'VPN': 'qde'},
      ),
      '→ qd-grpc',
    );
  });

  test('a group that leads nowhere says so instead of naming itself', () {
    final groups = [const Group(name: 'qde', type: GroupType.URLTest)];
    expect(
      computeProxyDesc(
        const Proxy(name: 'qde', type: 'URLTest'),
        groups: groups,
        selectedMap: const {},
      ),
      '—',
    );
  });
}
