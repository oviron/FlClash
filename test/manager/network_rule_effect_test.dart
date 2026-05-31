import 'package:fl_clash/manager/effects/network_rule_effect.dart';
import 'package:fl_clash/network_rules/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skips disabled network rules', () {
    final decision = decideNetworkRuleDispatch(
      enabled: false,
      rules: const [
        NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ],
      snapshot: const NetworkSnapshot.cellular(),
      isOn: false,
    );

    expect(decision.shouldDispatch, isFalse);
    expect(decision.message, 'network rules disabled');
  });

  test('dispatches when desired state differs', () {
    final decision = decideNetworkRuleDispatch(
      enabled: true,
      rules: const [
        NetworkRule(
          id: 42,
          name: 'cell',
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ],
      snapshot: const NetworkSnapshot.cellular(),
      isOn: false,
    );

    expect(decision.shouldDispatch, isTrue);
    expect(decision.action, NetworkAction.turnOn);
    expect(decision.message, contains("matched rule 'cell'"));
    expect(decision.message, contains('starting VPN'));
  });

  test('skips when desired state already matches', () {
    final decision = decideNetworkRuleDispatch(
      enabled: true,
      rules: const [
        NetworkRule(
          conditions: [AnyCellular()],
          action: NetworkAction.turnOn,
          priority: 0,
        ),
      ],
      snapshot: const NetworkSnapshot.cellular(),
      isOn: true,
    );

    expect(decision.shouldDispatch, isFalse);
    expect(decision.message, contains('equals current state'));
  });

  test('describes wifi snapshots', () {
    expect(
      describeNetworkSnapshot(const NetworkSnapshot.wifi(ssid: 'Cafe')),
      'wifi:Cafe',
    );
    expect(
      describeNetworkSnapshot(const NetworkSnapshot.wifi()),
      'wifi:<unknown>',
    );
  });
}
