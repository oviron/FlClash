package com.follow.clash.common

import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class NotificationTickerTest {

    private val tick = 2000L

    @Test
    fun `screen on - refreshes on every tick`() = runTest {
        val screen = MutableStateFlow(true)
        val params = MutableStateFlow<String?>("p")
        val emissions = mutableListOf<String>()
        val job = launch {
            notificationRefreshFlow(screen, params, tick).collect { emissions.add(it) }
        }
        advanceTimeBy(tick * 3 + 1)
        job.cancel()
        // onStart + the immediate first tick, then one refresh per tick.
        assertEquals(5, emissions.size)
    }

    @Test
    fun `screen off - no periodic refreshes`() = runTest {
        val screen = MutableStateFlow(false)
        val params = MutableStateFlow<String?>("p")
        val emissions = mutableListOf<String>()
        val job = launch {
            notificationRefreshFlow(screen, params, tick).collect { emissions.add(it) }
        }
        advanceTimeBy(tick * 10)
        // Exactly the single onStart emission that backs startForeground.
        assertEquals(1, emissions.size)
        job.cancel()
    }

    @Test
    fun `screen off - params change still refreshes once`() = runTest {
        val screen = MutableStateFlow(false)
        val params = MutableStateFlow<String?>("a")
        val emissions = mutableListOf<String>()
        val job = launch {
            notificationRefreshFlow(screen, params, tick).collect { emissions.add(it) }
        }
        advanceTimeBy(tick * 2)
        params.value = "b"
        advanceTimeBy(tick * 2)
        assertEquals(listOf("a", "b"), emissions)
        job.cancel()
    }

    @Test
    fun `screen turning off stops the ticker, turning on resumes it`() = runTest {
        val screen = MutableStateFlow(true)
        val params = MutableStateFlow<String?>("p")
        val emissions = mutableListOf<String>()
        val job = launch {
            notificationRefreshFlow(screen, params, tick).collect { emissions.add(it) }
        }
        advanceTimeBy(tick + 1)
        val whileOn = emissions.size
        screen.value = false
        advanceTimeBy(tick * 10)
        val whileOff = emissions.size
        screen.value = true
        advanceTimeBy(1)
        assertEquals(whileOn, whileOff)
        assertEquals(whileOff + 1, emissions.size)
        job.cancel()
    }

    @Test
    fun `null params are never emitted`() = runTest {
        val screen = MutableStateFlow(true)
        val params = MutableStateFlow<String?>(null)
        val emissions = mutableListOf<String>()
        val job = launch {
            notificationRefreshFlow(screen, params, tick).collect { emissions.add(it) }
        }
        advanceTimeBy(tick * 3)
        assertEquals(0, emissions.size)
        params.value = "p"
        advanceTimeBy(1)
        assertEquals(1, emissions.size)
        job.cancel()
    }
}
