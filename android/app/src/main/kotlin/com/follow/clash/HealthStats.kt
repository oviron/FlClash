package com.follow.clash

import android.content.Context
import android.os.health.SystemHealthManager
import android.os.health.UidHealthStats
import androidx.core.content.ContextCompat
import com.google.gson.Gson

// Our own UID's resource use, straight from the framework. The UID is shared
// with :remote, so one call already covers the core process. Android's battery
// screen under-reports a VPN: tunnelled traffic is billed to the app that
// originated it, and the tunnel wake lock is only held while the screen is on.
fun Context.healthStatsJson(): String? {
    val manager = ContextCompat.getSystemService(this, SystemHealthManager::class.java)
        ?: return null
    val stats = runCatching { manager.takeMyUidSnapshot() }.getOrNull() ?: return null

    fun measure(key: Int): Long =
        runCatching { stats.getMeasurement(key) }.getOrDefault(0L)

    val wakeLockMs = runCatching {
        stats.getTimers(UidHealthStats.TIMERS_WAKELOCKS_PARTIAL).values.sumOf { it.time }
    }.getOrDefault(0L)

    return Gson().toJson(
        mapOf(
            "realtimeBatteryMs" to measure(UidHealthStats.MEASUREMENT_REALTIME_BATTERY_MS),
            "cpuUserMs" to measure(UidHealthStats.MEASUREMENT_USER_CPU_TIME_MS),
            "cpuSystemMs" to measure(UidHealthStats.MEASUREMENT_SYSTEM_CPU_TIME_MS),
            "wakeLockMs" to wakeLockMs,
            "wifiRxBytes" to measure(UidHealthStats.MEASUREMENT_WIFI_RX_BYTES),
            "wifiTxBytes" to measure(UidHealthStats.MEASUREMENT_WIFI_TX_BYTES),
            "mobileRxBytes" to measure(UidHealthStats.MEASUREMENT_MOBILE_RX_BYTES),
            "mobileTxBytes" to measure(UidHealthStats.MEASUREMENT_MOBILE_TX_BYTES),
        )
    )
}
