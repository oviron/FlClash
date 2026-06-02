package com.follow.clash.networkrules

import android.content.Context
import android.net.Network
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import androidx.core.content.getSystemService
import com.follow.clash.common.networkrules.NetworkRuleType
import com.follow.clash.common.networkrules.NetworkSnapshot

// Builds the authoritative network snapshot natively from a NOT_VPN network:
// the connected SSID is only readable here (ACCESS_FINE_LOCATION + location on)
// while the UI is backgrounded. Mirror of the Dart NetworkProbe sanitisation.
class NetworkSnapshotReader(context: Context) {
    private val wifiManager = context.applicationContext.getSystemService<WifiManager>()

    fun read(capabilities: NetworkCapabilities?): NetworkSnapshot {
        if (capabilities == null) return NetworkSnapshot(NetworkRuleType.NONE)
        return when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ->
                NetworkSnapshot(NetworkRuleType.WIFI, readSsid(capabilities))

            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) ->
                NetworkSnapshot(NetworkRuleType.ETHERNET)

            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ->
                NetworkSnapshot(NetworkRuleType.CELLULAR)

            else -> NetworkSnapshot(NetworkRuleType.NONE)
        }
    }

    private fun readSsid(capabilities: NetworkCapabilities): String? {
        val raw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (capabilities.transportInfo as? WifiInfo)?.ssid
        } else {
            @Suppress("DEPRECATION")
            wifiManager?.connectionInfo?.ssid
        }
        return sanitizeSsid(raw)
    }

    companion object {
        fun sanitizeSsid(raw: String?): String? {
            if (raw == null) return null
            var value = raw.trim()
            if (value == WifiManager.UNKNOWN_SSID || value == "<unknown ssid>") return null
            if (value.length >= 2 && value.startsWith("\"") && value.endsWith("\"")) {
                value = value.substring(1, value.length - 1)
            }
            return value.ifEmpty { null }
        }

        // Stable per-network token; the override window resets when it changes.
        fun networkKey(network: Network?): Long = network?.networkHandle ?: -1L
    }
}
