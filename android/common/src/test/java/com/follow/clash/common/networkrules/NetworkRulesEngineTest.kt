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
        profileId: Int? = null,
        selectedMap: Map<String, String> = emptyMap(),
        profileName: String? = null,
        matchMode: NetworkMatchMode = NetworkMatchMode.ALL,
    ) = NetworkRule(
        id, name, conditions, action, priority, enabled, profileId, selectedMap, profileName, matchMode,
    )

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

    @Test
    fun resolveFullCarriesProfileTarget() {
        val mirror = RulesMirror(
            enabled = true,
            defaultAction = DefaultNetworkAction.LEAVE_AS_IS,
            rules = listOf(
                rule(
                    listOf(NetworkCondition.AnyCellular),
                    NetworkRuleAction.LEAVE,
                    profileId = 7,
                    selectedMap = mapOf("GLOBAL" to "us"),
                    profileName = "Work",
                ),
            ),
        )
        val res = NetworkRulesEngine.resolveFull(mirror, NetworkSnapshot(NetworkRuleType.CELLULAR))
        // vpn=LEAVE + default LEAVE_AS_IS => no VPN change, but the profile switches.
        assertEquals(NetworkDecision.LEAVE_AS_IS, res.decision)
        assertEquals(7, res.profileId)
        assertEquals(mapOf("GLOBAL" to "us"), res.selectedMap)
        assertEquals("Work", res.profileName)
    }

    @Test
    fun resolveFullNoMatchHasNoProfile() {
        val res = NetworkRulesEngine.resolveFull(
            RulesMirror(true, DefaultNetworkAction.TURN_OFF, emptyList()),
            NetworkSnapshot(NetworkRuleType.WIFI, "x"),
        )
        assertEquals(NetworkDecision.STOP, res.decision)
        assertNull(res.profileId)
    }

    @Test
    fun codecParsesV2ProfileFields() {
        val json = """
            {"version":2,"enabled":true,"defaultAction":"leaveAsIs","activeProfileId":3,
             "rules":[{"id":1,"actionVpn":"turnOn","action":"turnOn","actionProfileId":7,
                       "actionSelectedMap":{"GLOBAL":"us"},"actionProfileName":"Work",
                       "priority":0,"enabled":true,
                       "conditions":[{"kind":"any_cellular"}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        assertEquals(3, mirror.activeProfileId)
        val res = NetworkRulesEngine.resolveFull(mirror, NetworkSnapshot(NetworkRuleType.CELLULAR))
        assertEquals(NetworkDecision.START, res.decision)
        assertEquals(7, res.profileId)
        assertEquals("Work", res.profileName)
        assertEquals(mapOf("GLOBAL" to "us"), res.selectedMap)
    }

    @Test
    fun profileGateMatchesOnlyActiveProfile() {
        val rules = listOf(
            rule(
                listOf(NetworkCondition.AnyCellular, NetworkCondition.ProfileIs(5)),
                NetworkRuleAction.TURN_OFF,
            ),
        )
        // cellular + active profile 5 -> match -> STOP
        assertEquals(
            NetworkDecision.STOP,
            NetworkRulesEngine.resolve(
                rules,
                NetworkSnapshot(NetworkRuleType.CELLULAR),
                DefaultNetworkAction.LEAVE_AS_IS,
                5,
            ),
        )
        // cellular + active profile 9 -> gate fails -> default LEAVE
        assertEquals(
            NetworkDecision.LEAVE_AS_IS,
            NetworkRulesEngine.resolve(
                rules,
                NetworkSnapshot(NetworkRuleType.CELLULAR),
                DefaultNetworkAction.LEAVE_AS_IS,
                9,
            ),
        )
    }

    @Test
    fun codecParsesProfileGate() {
        val json = """
            {"version":2,"enabled":true,"defaultAction":"leaveAsIs","activeProfileId":3,
             "rules":[{"id":1,"actionVpn":"turnOff","priority":0,"enabled":true,
                       "conditions":[{"kind":"any_cellular"},{"kind":"profile_is","profileId":3}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        assertEquals(2, mirror.rules[0].conditions.size)
        // mirror.activeProfileId (3) == gate -> matches -> STOP
        assertEquals(
            NetworkDecision.STOP,
            NetworkRulesEngine.resolve(mirror, NetworkSnapshot(NetworkRuleType.CELLULAR)),
        )
    }

    @Test
    fun anyModeMatchesAnyCondition() {
        val rules = listOf(
            rule(
                listOf(NetworkCondition.WifiNamed("A"), NetworkCondition.WifiNamed("B")),
                NetworkRuleAction.TURN_ON,
                matchMode = NetworkMatchMode.ANY,
            ),
        )
        assertEquals(
            NetworkRuleAction.TURN_ON,
            NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.WIFI, "B")),
        )
        assertNull(NetworkRulesEngine.evaluate(rules, NetworkSnapshot(NetworkRuleType.WIFI, "C")))
    }

    @Test
    fun codecDefaultsMatchModeToAll() {
        val json = """
            {"version":3,"enabled":true,"defaultAction":"leaveAsIs",
             "rules":[{"id":1,"actionVpn":"turnOff","priority":0,"enabled":true,
                       "conditions":[{"kind":"any_cellular"}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        assertEquals(NetworkMatchMode.ALL, mirror.rules[0].matchMode)
    }

    @Test
    fun codecParsesAnyMatchMode() {
        val json = """
            {"version":3,"enabled":true,"defaultAction":"leaveAsIs",
             "rules":[{"id":1,"match":"any","actionVpn":"turnOn","priority":0,"enabled":true,
                       "conditions":[{"kind":"wifi_named","ssid":"A"},
                                     {"kind":"wifi_named","ssid":"B"}]}]}
        """.trimIndent()
        val mirror = NetworkRulesCodec.parse(json)
        assertEquals(NetworkMatchMode.ANY, mirror.rules[0].matchMode)
        assertEquals(
            NetworkDecision.START,
            NetworkRulesEngine.resolve(mirror, NetworkSnapshot(NetworkRuleType.WIFI, "B")),
        )
    }
}
