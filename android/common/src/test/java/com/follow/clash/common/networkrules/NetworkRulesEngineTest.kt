package com.follow.clash.common.networkrules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class NetworkRulesEngineTest {

    private fun rule(
        conditions: List<NetworkCondition>,
        action: NetworkRuleAction,
        priority: Int = 0,
        enabled: Boolean = true,
        id: Int = 0,
        name: String? = null,
    ) = NetworkRule(id, name, conditions, action, priority, enabled)

    @Test
    fun emptyRulesNoMatch() {
        assertNull(
            NetworkRulesEngine.evaluate(emptyList(), NetworkSnapshot(NetworkRuleType.CELLULAR)),
        )
    }

    @Test
    fun disabledRuleSkipped() {
        val rules = listOf(
            rule(listOf(NetworkCondition.AnyCellular), NetworkRuleAction.TURN_ON, enabled = false),
        )
        assertNull(NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.CELLULAR)))
    }

    @Test
    fun wifiNamedCaseInsensitiveMatch() {
        val rules = listOf(rule(listOf(NetworkCondition.WifiNamed("Home")), NetworkRuleAction.TURN_OFF))
        assertEquals(
            NetworkRuleAction.TURN_OFF,
            NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.WIFI, "home")),
        )
    }

    @Test
    fun wifiNamedNoMatchWhenSsidNull() {
        val rules = listOf(rule(listOf(NetworkCondition.WifiNamed("Home")), NetworkRuleAction.TURN_OFF))
        assertNull(NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.WIFI, null)))
    }

    @Test
    fun namedWifiBeatsAnyWifiRegardlessOfPriority() {
        val rules = listOf(
            rule(listOf(NetworkCondition.AnyWifi), NetworkRuleAction.TURN_ON, priority = 0, name = "any"),
            rule(listOf(NetworkCondition.WifiNamed("Home")), NetworkRuleAction.TURN_OFF, priority = 10, name = "home"),
        )
        assertEquals(
            NetworkRuleAction.TURN_OFF,
            NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.WIFI, "Home")),
        )
    }

    @Test
    fun equalSpecificityFallsBackToPriority() {
        val rules = listOf(
            rule(listOf(NetworkCondition.AnyCellular), NetworkRuleAction.TURN_OFF, priority = 5),
            rule(listOf(NetworkCondition.AnyCellular), NetworkRuleAction.TURN_ON, priority = 0),
        )
        assertEquals(
            NetworkRuleAction.TURN_ON,
            NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.CELLULAR)),
        )
    }

    @Test
    fun anyEthernetMatches() {
        val rules = listOf(rule(listOf(NetworkCondition.AnyEthernet), NetworkRuleAction.TURN_ON))
        assertEquals(
            NetworkRuleAction.TURN_ON,
            NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.ETHERNET)),
        )
        assertNull(NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.CELLULAR)))
    }

    @Test
    fun resolveMatchingRuleWinsOverDefault() {
        val rules = listOf(rule(listOf(NetworkCondition.AnyCellular), NetworkRuleAction.TURN_ON))
        assertEquals(
            NetworkDecision.START,
            NetworkRulesEngine.resolve(rules, NetworkSnapshot(NetworkRuleType.CELLULAR), DefaultNetworkAction.TURN_OFF),
        )
    }

    @Test
    fun resolveNoMatchAppliesDefault() {
        assertEquals(
            NetworkDecision.LEAVE_AS_IS,
            NetworkRulesEngine.resolve(emptyList(), NetworkSnapshot(NetworkRuleType.CELLULAR), DefaultNetworkAction.LEAVE_AS_IS),
        )
        assertEquals(
            NetworkDecision.STOP,
            NetworkRulesEngine.resolve(emptyList(), NetworkSnapshot(NetworkRuleType.WIFI, "Cafe"), DefaultNetworkAction.TURN_OFF),
        )
    }

    @Test
    fun resolveDisabledMirrorIsNoop() {
        val mirror = RulesMirror(
            enabled = false,
            defaultAction = DefaultNetworkAction.TURN_ON,
            rules = listOf(rule(listOf(NetworkCondition.AnyCellular), NetworkRuleAction.TURN_ON)),
        )
        assertEquals(
            NetworkDecision.LEAVE_AS_IS,
            NetworkRulesEngine.resolve(mirror, NetworkSnapshot(NetworkRuleType.CELLULAR)),
        )
    }

    @Test
    fun codecParsesMirrorAndAppliesDecision() {
        val json = """
            {"version":1,"enabled":true,"defaultAction":"turnOff",
             "rules":[{"id":1,"name":"Home","action":"turnOff","priority":0,"enabled":true,
                       "conditions":[{"kind":"wifi_named","ssid":"Home"}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        assertTrue(mirror.enabled)
        assertEquals(DefaultNetworkAction.TURN_OFF, mirror.defaultAction)
        assertEquals(1, mirror.rules.size)
        assertEquals(
            NetworkDecision.STOP,
            NetworkRulesEngine.resolve(mirror, NetworkSnapshot(NetworkRuleType.WIFI, "home")),
        )
    }

    @Test
    fun codecSkipsUnknownConditionKind() {
        val json = """
            {"enabled":true,"defaultAction":"leaveAsIs",
             "rules":[{"id":1,"action":"turnOn","priority":0,"enabled":true,
                       "conditions":[{"kind":"future_geofence","lat":1,"lon":2}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        // Rule survives but with no usable conditions => never matches.
        assertEquals(1, mirror.rules.size)
        assertTrue(mirror.rules[0].conditions.isEmpty())
        assertEquals(
            NetworkDecision.LEAVE_AS_IS,
            NetworkRulesEngine.resolve(mirror, NetworkSnapshot(NetworkRuleType.WIFI, "x")),
        )
    }

    @Test
    fun codecReturnsDisabledOnMalformedJson() {
        val mirror = NetworkRulesCodec.parse("not json at all")
        assertEquals(NetworkRulesCodec.disabled, mirror)
    }
}
