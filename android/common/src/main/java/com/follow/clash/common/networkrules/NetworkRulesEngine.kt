package com.follow.clash.common.networkrules

// Authoritative rule engine, mirror of the Dart engine.dart. Pure logic, no
// Android calls; the manual-override window is layered on by the runtime.
object NetworkRulesEngine {

    // Empty conditions => no match. Most-specific rule wins (see
    // networkRuleComparator), not creation order.
    fun evaluate(rules: List<NetworkRule>, snapshot: NetworkSnapshot): NetworkRuleAction? {
        for (rule in rules.sortedWith(networkRuleComparator)) {
            val matches = rule.enabled &&
                rule.conditions.isNotEmpty() &&
                rule.conditions.all { it.matches(snapshot) }
            if (matches) return rule.action
        }
        return null
    }

    fun resolve(
        rules: List<NetworkRule>,
        snapshot: NetworkSnapshot,
        defaultAction: DefaultNetworkAction,
    ): NetworkDecision = when (evaluate(rules, snapshot)) {
        NetworkRuleAction.TURN_ON -> NetworkDecision.START
        NetworkRuleAction.TURN_OFF -> NetworkDecision.STOP
        null -> when (defaultAction) {
            DefaultNetworkAction.TURN_ON -> NetworkDecision.START
            DefaultNetworkAction.TURN_OFF -> NetworkDecision.STOP
            DefaultNetworkAction.LEAVE_AS_IS -> NetworkDecision.LEAVE_AS_IS
        }
    }

    // Mirror-level entry: a disabled feature is always a no-op.
    fun resolve(mirror: RulesMirror, snapshot: NetworkSnapshot): NetworkDecision =
        if (!mirror.enabled) {
            NetworkDecision.LEAVE_AS_IS
        } else {
            resolve(mirror.rules, snapshot, mirror.defaultAction)
        }
}
