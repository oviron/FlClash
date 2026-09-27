package com.follow.clash.common

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import java.util.concurrent.atomic.AtomicLong

// Start and stop requests run one at a time, in the order they were made, and a stop
// cancels every start requested before it that has not committed yet.
class LifecycleSequencer(private val scope: CoroutineScope) {
    val lock = Mutex()
    private val stops = AtomicLong()

    fun startTicket(): Long = stops.get()

    fun isCancelled(ticket: Long): Boolean = ticket != stops.get()

    fun cancelStarts() {
        stops.incrementAndGet()
    }

    // Runs up to the first suspension on the caller's thread, so a block that begins with
    // lock.withLock queues on the fair mutex before this returns.
    fun launch(block: suspend CoroutineScope.() -> Unit): Job =
        scope.launch(start = CoroutineStart.UNDISPATCHED, block = block)
}
