import 'package:fl_clash/services/routing_model.dart';
import 'package:flutter_test/flutter_test.dart';

RoutingModel _model(TunnelMode mode, List<AppAssignment> apps) => RoutingModel(
  exitGroup: 'Proxy',
  lists: const [],
  scenarios: const [],
  apps: apps,
  tunnelMode: mode,
);

AppAssignment _via(String pkg) => AppAssignment(packageName: pkg, dest: toVpn);
AppAssignment _bypass(String pkg) =>
    AppAssignment(packageName: pkg, dest: toBypass);

List<String> _pkgs(RoutingModel m) => [for (final a in m.apps) a.packageName];

void main() {
  group('switchTunnelMode', () {
    test('whitelist -> all stashes the include set', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.whitelist, [_via('a'), _via('b')]),
        stashInclude: const [],
        stashExclude: const [],
        newMode: TunnelMode.all,
      );
      expect(r.model.tunnelMode, TunnelMode.all);
      expect(r.stashInclude, ['a', 'b']);
      expect(r.stashExclude, isEmpty);
    });

    test('all -> whitelist restores the stashed include set as via-VPN', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.all, const []),
        stashInclude: const ['a', 'b', 'c'],
        stashExclude: const [],
        newMode: TunnelMode.whitelist,
      );
      expect(r.model.tunnelMode, TunnelMode.whitelist);
      expect(_pkgs(r.model), ['a', 'b', 'c']);
      expect(r.model.apps.every((x) => x.dest is ToVpn), isTrue);
    });

    test('blacklist -> all stashes the exclude set', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.blacklist, [_bypass('x'), _bypass('y')]),
        stashInclude: const [],
        stashExclude: const [],
        newMode: TunnelMode.all,
      );
      expect(r.stashExclude, ['x', 'y']);
      expect(r.stashInclude, isEmpty);
    });

    test('all -> blacklist restores the stashed exclude set as bypass', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.all, const []),
        stashInclude: const [],
        stashExclude: const ['x', 'y'],
        newMode: TunnelMode.blacklist,
      );
      expect(r.model.tunnelMode, TunnelMode.blacklist);
      expect(_pkgs(r.model), ['x', 'y']);
      expect(r.model.apps.every((a) => a.dest is ToBypass), isTrue);
    });

    test('whitelist -> all -> whitelist round-trips the selection', () {
      final toAll = switchTunnelMode(
        current: _model(TunnelMode.whitelist, [_via('a'), _via('b')]),
        stashInclude: const [],
        stashExclude: const [],
        newMode: TunnelMode.all,
      );
      final back = switchTunnelMode(
        current: toAll.model,
        stashInclude: toAll.stashInclude,
        stashExclude: toAll.stashExclude,
        newMode: TunnelMode.whitelist,
      );
      expect(_pkgs(back.model), ['a', 'b']);
      expect(back.model.apps.every((x) => x.dest is ToVpn), isTrue);
    });

    test('whitelist -> blacklist keeps each mode its own remembered list', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.whitelist, [_via('a'), _via('b')]),
        stashInclude: const [],
        stashExclude: const ['x'],
        newMode: TunnelMode.blacklist,
      );
      // Leaving whitelist stashes its include; entering blacklist restores its
      // own stashed exclude, not the whitelist apps.
      expect(r.stashInclude, ['a', 'b']);
      expect(_pkgs(r.model), ['x']);
    });

    test('all -> whitelist with an empty stash yields no apps', () {
      final r = switchTunnelMode(
        current: _model(TunnelMode.all, const []),
        stashInclude: const [],
        stashExclude: const [],
        newMode: TunnelMode.whitelist,
      );
      expect(r.model.apps, isEmpty);
    });
  });
}
