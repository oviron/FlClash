import 'package:fl_clash/network_rules/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluate', () {
    test('empty rules returns null', () {
      expect(
        evaluate(
          rules: const [],
          snapshot: const NetworkSnapshot.cellular(),
        ),
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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
        ),
        NetworkAction.turnOn,
      );
    });

    test('WifiNamed matches wifi snapshot with same ssid (case insensitive)', () {
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
    });

    test('WifiNamed does not match wifi with different ssid (returns null)', () {
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
        ),
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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
        ),
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
        evaluate(
          rules: rules,
          snapshot: const NetworkSnapshot.cellular(),
        ),
        NetworkAction.turnOn,
      );
    });
  });
}
