package com.follow.clash.common.networkrules

enum class NetworkRuleType { WIFI, CELLULAR, ETHERNET, NONE }

enum class NetworkRuleAction { TURN_ON, TURN_OFF, LEAVE }

enum class DefaultNetworkAction { TURN_ON, TURN_OFF, LEAVE_AS_IS }

enum class NetworkDecision { START, STOP, LEAVE_AS_IS }

data class NetworkSnapshot(val type: NetworkRuleType, val ssid: String? = null)

sealed interface NetworkCondition {
    val specificity: Int

    fun matches(snapshot: NetworkSnapshot): Boolean

    // A named Wi-Fi (2) wins over a type-level clause (1) regardless of user
    // priority. Mirror of the Dart NetworkCondition.specificity.
    data class WifiNamed(val ssid: String) : NetworkCondition {
        override val specificity = 2
        override fun matches(snapshot: NetworkSnapshot) =
            snapshot.type == NetworkRuleType.WIFI &&
                snapshot.ssid != null &&
                snapshot.ssid.equals(ssid, ignoreCase = true)
    }

    data object AnyWifi : NetworkCondition {
        override val specificity = 1
        override fun matches(snapshot: NetworkSnapshot) =
            snapshot.type == NetworkRuleType.WIFI
    }

    data object AnyCellular : NetworkCondition {
        override val specificity = 1
        override fun matches(snapshot: NetworkSnapshot) =
            snapshot.type == NetworkRuleType.CELLULAR
    }

    data object AnyEthernet : NetworkCondition {
        override val specificity = 1
        override fun matches(snapshot: NetworkSnapshot) =
            snapshot.type == NetworkRuleType.ETHERNET
    }
}

data class NetworkRule(
    val id: Int,
    val name: String?,
    val conditions: List<NetworkCondition>,
    val action: NetworkRuleAction,
    val priority: Int,
    val enabled: Boolean,
    val actionProfileId: Int? = null,
    val actionSelectedMap: Map<String, String> = emptyMap(),
    val actionProfileName: String? = null,
)

// What the runtime should actuate: the VPN decision plus, when a rule targets a
// profile, that profile's id / pre-baked selectedMap / display name.
data class NetworkResolution(
    val decision: NetworkDecision,
    val profileId: Int?,
    val selectedMap: Map<String, String>,
    val profileName: String?,
)

data class RulesMirror(
    val enabled: Boolean,
    val defaultAction: DefaultNetworkAction,
    val rules: List<NetworkRule>,
    val activeProfileId: Int? = null,
)

fun NetworkRule.specificity(): Int =
    conditions.maxOfOrNull { it.specificity } ?: 0

// Most specific first, then lower user priority, then lower id. Keep in sync
// with the Dart compareNetworkRules.
val networkRuleComparator: Comparator<NetworkRule> =
    compareByDescending<NetworkRule> { it.specificity() }
        .thenBy { it.priority }
        .thenBy { it.id }
