package com.follow.clash.common

import android.content.ComponentCallbacks2
import android.content.res.Configuration
import android.os.SystemClock

class MemoryTrimGate(
    private val minIntervalMs: Long = 30_000L,
    private val now: () -> Long = SystemClock::elapsedRealtime,
    private val collect: () -> Unit,
) : ComponentCallbacks2 {
    private var lastCollectAt: Long? = null

    @Synchronized
    override fun onTrimMemory(level: Int) {
        if (level < ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW ||
            level == ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN
        ) return
        val at = now()
        val last = lastCollectAt
        if (last != null && at - last < minIntervalMs) return
        lastCollectAt = at
        collect()
    }

    @Deprecated("Deprecated in Java")
    override fun onLowMemory() = onTrimMemory(ComponentCallbacks2.TRIM_MEMORY_COMPLETE)

    override fun onConfigurationChanged(newConfig: Configuration) = Unit
}
