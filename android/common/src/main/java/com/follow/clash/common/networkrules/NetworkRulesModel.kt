package com.follow.clash.common.networkrules

enum class NetworkRuleType { WIFI, CELLULAR, ETHERNET, NONE }

enum class NetworkRuleAction { TURN_ON, TURN_OFF, LEAVE }

// How a rule's conditions combine. Mirror of the Dart NetworkMatchMode.
enum class NetworkMatchMode { ALL, ANY }

enum class DefaultNetworkAction { TURN_ON, TURN_OFF, LEAVE_AS_IS }

enum class NetworkDecision { START, STOP, LEAVE_AS_IS }

data class NetworkSnapshot(val type: NetworkRuleType, val ssid: String? = null)

// Snapshot + active profile id; conditions match against this. The profile axis
// is kept out of NetworkSnapshot (it is app state, not network state). Mirror of
// the Dart NetworkMatchContext.
data class MatchContext(val snapshot: NetworkSnapshot, val activeProfileId: Int? = null)

sealed interface NetworkCondition {
    val specificity: Int

    fun matches(ctx: MatchContext): Boolean

    // A named Wi-Fi (2) wins over a type-level clause (1) regardless of user
    // priority. Mirror of the Dart NetworkCondition.specificity.
    data class WifiNamed(val ssid: String) : NetworkCondition {
        override val specificity = 2
        override fun matches(ctx: MatchContext) =
            ctx.snapshot.type == NetworkRuleType.WIFI &&
                ctx.snapshot.ssid != null &&
                ctx.snapshot.ssid.equals(ssid, ignoreCase = true)
    }

    data object AnyWifi : NetworkCondition {
        override val specificity = 1
        override fun matches(ctx: MatchContext) =
            ctx.snapshot.type == NetworkRuleType.WIFI
    }

    data object AnyCellular : NetworkCondition {
        override val specificity = 1
        override fun matches(ctx: MatchContext) =
            ctx.snapshot.type == NetworkRuleType.CELLULAR
    }

    data object AnyEthernet : NetworkCondition {
        override val specificity = 1
        override fun matches(ctx: MatchContext) =
            ctx.snapshot.type == NetworkRuleType.ETHERNET
    }

    // Optional profile gate: matches when the active profile is this one.
    data class ProfileIs(val profileId: Int) : NetworkCondition {
        override val specificity = 2
        override fun matches(ctx: MatchContext) = ctx.activeProfileId == profileId
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
    val matchMode: NetworkMatchMode = NetworkMatchMode.ALL,
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
