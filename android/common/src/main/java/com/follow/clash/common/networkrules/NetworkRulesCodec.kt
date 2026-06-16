package com.follow.clash.common.networkrules

import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser

// Reads the rules mirror that Dart writes atomically to
// filesDir/network-rules.json. Tolerant by design: a malformed file or an
// unknown future condition kind must never crash the resident service, it
// degrades to "feature off / rule skipped".
object NetworkRulesCodec {

    fun parse(raw: String): RulesMirror {
        return try {
            val root = JsonParser.parseString(raw).asJsonObject
            RulesMirror(
                enabled = root.optBoolean("enabled", false),
                defaultAction = parseDefaultAction(root.optString("defaultAction")),
                rules = parseRules(root.getAsJsonArray("rules")),
                activeProfileId = root.optIntOrNull("activeProfileId"),
            )
        } catch (_: Exception) {
            disabled
        }
    }

    val disabled = RulesMirror(
        enabled = false,
        defaultAction = DefaultNetworkAction.LEAVE_AS_IS,
        rules = emptyList(),
    )

    private fun parseRules(array: JsonArray?): List<NetworkRule> {
        if (array == null) return emptyList()
        val out = ArrayList<NetworkRule>(array.size())
        for (element in array) {
            val rule = runCatching { parseRule(element.asJsonObject) }.getOrNull()
            if (rule != null) out.add(rule)
        }
        return out
    }

    private fun parseRule(obj: JsonObject): NetworkRule = NetworkRule(
        id = obj.optInt("id", 0),
        name = if (obj.has("name") && !obj.get("name").isJsonNull) {
            obj.get("name").asString
        } else {
            null
        },
        conditions = parseConditions(obj.getAsJsonArray("conditions")),
        // Prefer the v2 `actionVpn`; fall back to the legacy on/off `action`.
        action = parseAction(obj.optString("actionVpn") ?: obj.optString("action")),
        priority = obj.optInt("priority", 0),
        enabled = obj.optBoolean("enabled", true),
        actionProfileId = obj.optIntOrNull("actionProfileId"),
        actionSelectedMap = parseStringMap(obj.getAsJsonObjectOrNull("actionSelectedMap")),
        actionProfileName = obj.optString("actionProfileName"),
        matchMode = parseMatchMode(obj.optString("match")),
    )

    private fun parseMatchMode(value: String?): NetworkMatchMode =
        if (value == "any") NetworkMatchMode.ANY else NetworkMatchMode.ALL

    private fun parseConditions(array: JsonArray?): List<NetworkCondition> {
        if (array == null) return emptyList()
        val out = ArrayList<NetworkCondition>(array.size())
        for (element in array) {
            val condition = runCatching { parseCondition(element.asJsonObject) }.getOrNull()
            if (condition != null) out.add(condition)
        }
        return out
    }

    private fun parseCondition(obj: JsonObject): NetworkCondition? =
        when (obj.optString("kind")) {
            "wifi_named" -> NetworkCondition.WifiNamed(obj.get("ssid").asString)
            "any_wifi" -> NetworkCondition.AnyWifi
            "any_cellular" -> NetworkCondition.AnyCellular
            "any_ethernet" -> NetworkCondition.AnyEthernet
            "profile_is" -> NetworkCondition.ProfileIs(obj.get("profileId").asInt)
            else -> null
        }

    private fun parseAction(value: String?): NetworkRuleAction = when (value) {
        "turnOff" -> NetworkRuleAction.TURN_OFF
        "leave" -> NetworkRuleAction.LEAVE
        else -> NetworkRuleAction.TURN_ON
    }

    private fun parseStringMap(obj: JsonObject?): Map<String, String> {
        if (obj == null) return emptyMap()
        val out = LinkedHashMap<String, String>()
        for ((key, value) in obj.entrySet()) {
            if (!value.isJsonNull) out[key] = value.asString
        }
        return out
    }

    private fun parseDefaultAction(value: String?): DefaultNetworkAction = when (value) {
        "turnOn" -> DefaultNetworkAction.TURN_ON
        "turnOff" -> DefaultNetworkAction.TURN_OFF
        else -> DefaultNetworkAction.LEAVE_AS_IS
    }

    private fun JsonObject.optString(key: String): String? =
        if (has(key) && !get(key).isJsonNull) get(key).asString else null

    private fun JsonObject.optBoolean(key: String, fallback: Boolean): Boolean =
        if (has(key) && !get(key).isJsonNull) get(key).asBoolean else fallback

    private fun JsonObject.optInt(key: String, fallback: Int): Int =
        if (has(key) && !get(key).isJsonNull) get(key).asInt else fallback

    private fun JsonObject.optIntOrNull(key: String): Int? =
        if (has(key) && !get(key).isJsonNull) get(key).asInt else null

    private fun JsonObject.getAsJsonObjectOrNull(key: String): JsonObject? =
        if (has(key) && get(key).isJsonObject) getAsJsonObject(key) else null
}
