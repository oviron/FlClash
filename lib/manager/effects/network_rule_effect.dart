import 'package:fl_clash/network_rules/engine.dart';

class NetworkRuleDispatchDecision {
  final NetworkAction? action;
  final bool shouldDispatch;
  final bool shouldLog;
  final String message;

  const NetworkRuleDispatchDecision._({
    required this.action,
    required this.shouldDispatch,
    required this.shouldLog,
    required this.message,
  });

  factory NetworkRuleDispatchDecision.skip(
    String message, {
    bool shouldLog = false,
  }) => NetworkRuleDispatchDecision._(
    action: null,
    shouldDispatch: false,
    shouldLog: shouldLog,
    message: message,
  );

  factory NetworkRuleDispatchDecision.dispatch({
    required NetworkAction action,
    required String message,
  }) => NetworkRuleDispatchDecision._(
    action: action,
    shouldDispatch: true,
    shouldLog: true,
    message: message,
  );
}

NetworkRuleDispatchDecision decideNetworkRuleDispatch({
  required bool enabled,
  required List<NetworkRule> rules,
  required NetworkSnapshot snapshot,
  required bool isOn,
}) {
  if (!enabled) {
    return NetworkRuleDispatchDecision.skip('network rules disabled');
  }

  final action = evaluate(rules: rules, snapshot: snapshot);
  if (action == null) {
    return NetworkRuleDispatchDecision.skip(
      'no action for ${describeNetworkSnapshot(snapshot)}',
    );
  }

  final desiredOn = action == NetworkAction.turnOn;
  final snapDescr = describeNetworkSnapshot(snapshot);
  if (desiredOn == isOn) {
    return NetworkRuleDispatchDecision.skip(
      'action ${action.name} equals current state, skip ($snapDescr)',
      shouldLog: true,
    );
  }

  final reason = matchNetworkRuleReason(rules, snapshot);
  return NetworkRuleDispatchDecision.dispatch(
    action: action,
    message:
        '$reason, action=${action.name} -> '
        '${desiredOn ? "starting" : "stopping"} VPN',
  );
}

String matchNetworkRuleReason(List<NetworkRule> rules, NetworkSnapshot snap) {
  final ordered = [...rules]..sort((a, b) => a.priority.compareTo(b.priority));
  for (final rule in ordered) {
    if (!rule.enabled) continue;
    if (rule.conditions.isEmpty) continue;
    final allMatch = rule.conditions.every((c) => c.matches(snap));
    if (allMatch) {
      final label = (rule.name == null || rule.name!.isEmpty)
          ? 'anonymous#${rule.id}'
          : rule.name!;
      return "matched rule '$label' on ${describeNetworkSnapshot(snap)}";
    }
  }
  return 'no rule matched on ${describeNetworkSnapshot(snap)}';
}

String describeNetworkSnapshot(NetworkSnapshot snap) {
  switch (snap.type) {
    case NetworkType.wifi:
      return snap.ssid != null ? 'wifi:${snap.ssid}' : 'wifi:<unknown>';
    case NetworkType.cellular:
      return 'cellular';
    case NetworkType.none:
      return 'none';
  }
}
