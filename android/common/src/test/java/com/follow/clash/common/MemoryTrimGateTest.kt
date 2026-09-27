package com.follow.clash.common

import android.content.ComponentCallbacks2.TRIM_MEMORY_BACKGROUND
import android.content.ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL
import android.content.ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW
import android.content.ComponentCallbacks2.TRIM_MEMORY_RUNNING_MODERATE
import android.content.ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN
import org.junit.Assert.assertEquals
import org.junit.Test

class MemoryTrimGateTest {
    private var now = 1_000L
    private var collected = 0
    private val gate = MemoryTrimGate(minIntervalMs = 30_000L, now = { now }) { collected++ }

    @Test
    fun ignoresModerateAndUiHidden() {
        gate.onTrimMemory(TRIM_MEMORY_RUNNING_MODERATE)
        gate.onTrimMemory(TRIM_MEMORY_UI_HIDDEN)
        assertEquals(0, collected)
    }

    @Test
    fun collectsUnderPressure() {
        gate.onTrimMemory(TRIM_MEMORY_RUNNING_LOW)
        now += 30_000L
        gate.onTrimMemory(TRIM_MEMORY_BACKGROUND)
        now += 30_000L
        gate.onLowMemory()
        assertEquals(3, collected)
    }

    @Test
    fun throttlesBurstsWithinTheInterval() {
        gate.onTrimMemory(TRIM_MEMORY_RUNNING_LOW)
        now += 10_000L
        gate.onTrimMemory(TRIM_MEMORY_RUNNING_CRITICAL)
        gate.onLowMemory()
        assertEquals(1, collected)
        now += 20_000L
        gate.onTrimMemory(TRIM_MEMORY_RUNNING_CRITICAL)
        assertEquals(2, collected)
    }
}
