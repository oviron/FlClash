package com.follow.clash.common.networkrules

// Authoritative rule engine, mirror of the Dart engine.dart. Pure logic, no
// Android calls; the manual-override window is layered on by the runtime.
object NetworkRulesEngine {

    // Empty conditions => no match. Most-specific rule wins (see
    // networkRuleComparator), not creation order.
    fun evaluateRule(rules: List<NetworkRule>, snapshot: NetworkSnapshot): NetworkRule? {
        for (rule in rules.sortedWith(networkRuleComparator)) {
            val matches = rule.enabled &&
                rule.conditions.isNotEmpty() &&
                rule.conditions.all { it.matches(snapshot) }
            if (matches) return rule
        }
        return null
    }

    fun evaluate(rules: List<NetworkRule>, snapshot: NetworkSnapshot): NetworkRuleAction? =
        evaluateRule(rules, snapshot)?.action

    fun resolve(
        rules: List<NetworkRule>,
        snapshot: NetworkSnapshot,
        defaultAction: DefaultNetworkAction,
    ): NetworkDecision = vpnDecision(evaluate(rules, snapshot), defaultAction)

    // Mirror-level entry: a disabled feature is always a no-op.
    fun resolve(mirror: RulesMirror, snapshot: NetworkSnapshot): NetworkDecision =
        if (!mirror.enabled) {
            NetworkDecision.LEAVE_AS_IS
        } else {
            resolve(mirror.rules, snapshot, mirror.defaultAction)
        }

    // Full resolution incl. the profile-switch target of the matched rule.
    fun resolveFull(mirror: RulesMirror, snapshot: NetworkSnapshot): NetworkResolution {
        if (!mirror.enabled) {
            return NetworkResolution(NetworkDecision.LEAVE_AS_IS, null, emptyMap(), null)
        }
        val matched = evaluateRule(mirror.rules, snapshot)
        return NetworkResolution(
            decision = vpnDecision(matched?.action, mirror.defaultAction),
            profileId = matched?.actionProfileId,
            selectedMap = matched?.actionSelectedMap ?: emptyMap(),
            profileName = matched?.actionProfileName,
        )
    }

    // LEAVE and "no match" both fall through to the default action.
    private fun vpnDecision(
        action: NetworkRuleAction?,
        defaultAction: DefaultNetworkAction,
    ): NetworkDecision = when (action) {
        NetworkRuleAction.TURN_ON -> NetworkDecision.START
        NetworkRuleAction.TURN_OFF -> NetworkDecision.STOP
        NetworkRuleAction.LEAVE, null -> when (defaultAction) {
            DefaultNetworkAction.TURN_ON -> NetworkDecision.START
            DefaultNetworkAction.TURN_OFF -> NetworkDecision.STOP
            DefaultNetworkAction.LEAVE_AS_IS -> NetworkDecision.LEAVE_AS_IS
        }
    }
}
