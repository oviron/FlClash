package com.follow.clash.common

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.joinAll
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.withLock
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LifecycleSequencerTest {
    @Test
    fun requestsTakeTheLockInTheOrderTheyWereMade() = runBlocking {
        val sequencer = LifecycleSequencer(CoroutineScope(Dispatchers.Default))
        val order = mutableListOf<Int>()
        sequencer.lock.lock()
        val jobs = (0 until 500).map { i ->
            sequencer.launch { sequencer.lock.withLock { order += i } }
        }
        sequencer.lock.unlock()
        jobs.joinAll()

        assertEquals((0 until 500).toList(), order)
    }

    @Test
    fun stopCancelsStartsRequestedBeforeIt() {
        val sequencer = LifecycleSequencer(CoroutineScope(Dispatchers.Default))
        val before = sequencer.startTicket()
        assertFalse(sequencer.isCancelled(before))

        sequencer.cancelStarts()
        val after = sequencer.startTicket()

        assertTrue(sequencer.isCancelled(before))
        assertFalse(sequencer.isCancelled(after))
    }
}
