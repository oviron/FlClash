import 'package:fl_clash/network_rules/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluate', () {
    test('empty rules returns fallback', () {
      expect(
        evaluate(
          rules: const [],
          snapshot: const NetworkSnapshot.cellular(),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.keep,
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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.turnOn,
      );
    });

    test('WifiNamed matches wifi snapshot with same ssid', () {
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
          snapshot: const NetworkSnapshot.wifi(ssid: 'HomeWifi'),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.turnOff,
      );
    });

    test('WifiNamed does not match different ssid (returns fallback)', () {
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
          fallback: NetworkAction.turnOn,
        ),
        NetworkAction.turnOn,
      );
    });

    test('WifiNamed match is case-insensitive', () {
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
          fallback: NetworkAction.keep,
        ),
        NetworkAction.turnOff,
      );
    });

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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.wifi(),
          fallback: NetworkAction.turnOn,
        ),
        NetworkAction.turnOn,
      );
    });

    test('AND of AnyWifi and WifiNamed: name mismatch means no match', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyWifi(), WifiNamed('HomeWifi')],
          action: NetworkAction.turnOff,
          priority: 0,
        ),
      ];
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.wifi(ssid: 'CafeWifi'),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.keep,
      );
    });

    test('disabled rule is skipped, fallback returned', () {
      final rules = [
        const NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
          enabled: false,
        ),
      ];
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.keep,
      );
    });

    test('priority order respected: lower priority rule evaluated first', () {
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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.turnOn,
      );
    });

    test('first matching rule wins, later matching rules ignored', () {
      // Two rules both match wifi with ssid Home. The one with lower
      // priority must short-circuit before the second one is evaluated.
      final rules = [
        const NetworkRule(
          conditions: [WifiNamed('Home')],
          action: NetworkAction.turnOff,
          priority: 0,
        ),
        const NetworkRule(
          conditions: [AnyWifi()],
          action: NetworkAction.turnOn,
          priority: 1,
        ),
      ];
      expect(
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.wifi(ssid: 'Home'),
          fallback: NetworkAction.keep,
        ),
        NetworkAction.turnOff,
      );
    });
  });
}
