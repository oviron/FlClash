import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/network_rules/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluate', () {
    test('empty rules returns null', () {
      expect(
        evaluate(rules: const [], snapshot: const NetworkSnapshot.cellular()),
        isNull,
      );
    });

    test('single rule matching cellular returns its action', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ];
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.cellular()),
        NetworkAction.turnOn,
      );
    });

    test(
      'WifiNamed matches wifi snapshot with same ssid (case insensitive)',
      () {
        final rules = [
          const NetworkRule(
            conditions: [WifiNamed('Home')],
            action: NetworkAction.turnOff,
            priority: 0,
          ),
        ];
        expect(
          evaluate(
            rules: rules,
            snapshot: const NetworkSnapshot.wifi(ssid: 'home'),
          ),
          NetworkAction.turnOff,
        );
      },
    );

    test(
      'WifiNamed does not match wifi with different ssid (returns null)',
      () {
        final rules = [
          const NetworkRule(
            conditions: [WifiNamed('HomeWifi')],
            action: NetworkAction.turnOff,
            priority: 0,
          ),
        ];
        expect(
          evaluate(
            rules: rules,
            snapshot: const NetworkSnapshot.wifi(ssid: 'CafeWifi'),
          ),
          isNull,
        );
      },
    );

    test('WifiNamed does not match when ssid is null', () {
      // Simulates wifi connection without ACCESS_FINE_LOCATION permission.
      final rules = [
        const NetworkRule(
          conditions: [WifiNamed('HomeWifi')],
          action: NetworkAction.turnOff,
          priority: 0,
        ),
      ];
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.wifi()),
        isNull,
      );
    });

    test('disabled rule is skipped', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
          enabled: false,
        ),
      ];
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.cellular()),
        isNull,
      );
    });

    test('priority order respected: lower priority rule evaluated first; '
        'first match wins', () {
      // Both rules match cellular. Priority 0 should win over priority 5,
      // even though we hand them to the engine in reverse order.
      final rules = [
        const NetworkRule(
          name: 'high-priority-number',
          conditions: [AnyCellular()],
          action: NetworkAction.turnOff,
          priority: 5,
        ),
        const NetworkRule(
          name: 'low-priority-number',
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ];
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.cellular()),
        NetworkAction.turnOn,
      );
    });

    test('named wifi beats any-wifi regardless of user priority', () {
      // AnyWifi has the lower (better) priority number but a named-SSID rule
      // is more specific and must win on a matching network.
      final rules = [
        const NetworkRule(
          name: 'any-wifi-first',
          conditions: [AnyWifi()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
        const NetworkRule(
          name: 'home',
          conditions: [WifiNamed('Home')],
          action: NetworkAction.turnOff,
          priority: 10,
        ),
      ];
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.wifi(ssid: 'Home'),
        ),
        NetworkAction.turnOff,
      );
    });

    test('AnyEthernet matches ethernet snapshot', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyEthernet()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ];
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.ethernet()),
        NetworkAction.turnOn,
      );
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.cellular()),
        isNull,
      );
    });
  });

  group('resolveNetworkDecision', () {
    test('matching rule wins over defaultAction', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ];
      expect(
        resolveNetworkDecision(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          defaultAction: DefaultNetworkAction.turnOff,
        ),
        NetworkDecision.start,
      );
    });

    test('no match + leaveAsIs => do nothing', () {
      expect(
        resolveNetworkDecision(
          rules: const [],
          snapshot: const NetworkSnapshot.cellular(),
          defaultAction: DefaultNetworkAction.leaveAsIs,
        ),
        NetworkDecision.leaveAsIs,
      );
    });

    test(
      'no match + turnOff => stop (baseline protects on unknown network)',
      () {
        expect(
          resolveNetworkDecision(
            rules: const [],
            snapshot: const NetworkSnapshot.wifi(ssid: 'Cafe'),
            defaultAction: DefaultNetworkAction.turnOff,
          ),
          NetworkDecision.stop,
        );
      },
    );

    test('no match + turnOn => start', () {
      expect(
        resolveNetworkDecision(
          rules: const [],
          snapshot: const NetworkSnapshot.cellular(),
          defaultAction: DefaultNetworkAction.turnOn,
        ),
        NetworkDecision.start,
      );
    });
  });

  group('NetworkAction profile-switch', () {
    test('toJson/fromJson round-trip preserves vpn + profileId', () {
      const action = NetworkAction(vpn: NetworkVpnMode.leave, profileId: 7);
      expect(NetworkAction.fromJson(action.toJson()), action);
      expect(action.profileId, isNotNull);
    });

    test('fromJson defaults to turnOn and null profile on missing fields', () {
      expect(NetworkAction.fromJson(const {}), NetworkAction.turnOn);
      expect(NetworkAction.fromJson(const {}).profileId, isNull);
    });

    test('evaluate returns the matched action carrying its profileId', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction(vpn: NetworkVpnMode.turnOn, profileId: 42),
          priority: 0,
        ),
      ];
      final matched = evaluate(
        rules: rules,
        snapshot: const NetworkSnapshot.cellular(),
      );
      expect(matched?.profileId, 42);
      expect(matched?.vpn, NetworkVpnMode.turnOn);
    });

    test('vpn=leave falls through to the default decision', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction(vpn: NetworkVpnMode.leave, profileId: 1),
          priority: 0,
        ),
      ];
      expect(
        resolveNetworkDecision(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          defaultAction: DefaultNetworkAction.leaveAsIs,
        ),
        NetworkDecision.leaveAsIs,
      );
    });
  });

  group('ProfileIs condition', () {
    test('matches only when the active profile equals', () {
      final rules = [
        const NetworkRule(
          conditions: [ProfileIs(5)],
          action: NetworkAction.turnOff,
          priority: 0,
        ),
      ];
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          activeProfileId: 5,
        ),
        NetworkAction.turnOff,
      );
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          activeProfileId: 9,
        ),
        isNull,
      );
      // No active profile at all -> never matches.
      expect(
        evaluate(rules: rules, snapshot: const NetworkSnapshot.cellular()),
        isNull,
      );
    });

    test('AND-gates a network condition by profile', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular(), ProfileIs(5)],
          action: NetworkAction.turnOff,
          priority: 0,
        ),
      ];
      // cellular + profile 5 -> match
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          activeProfileId: 5,
        ),
        NetworkAction.turnOff,
      );
      // right profile, wrong network -> no match
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.wifi(ssid: 'x'),
          activeProfileId: 5,
        ),
        isNull,
      );
      // right network, wrong profile -> no match
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          activeProfileId: 9,
        ),
        isNull,
      );
    });

    test('toJson/fromJson round-trip', () {
      const condition = ProfileIs(7);
      expect(NetworkCondition.fromJson(condition.toJson()), condition);
      expect(condition.specificity, 2);
    });
  });
}
