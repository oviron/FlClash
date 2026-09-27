package com.follow.clash.common

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong

// Callbacks handed to a remote process never fire if it dies; failAll() completes them.
class PendingCalls<T> {
    private val nextId = AtomicLong()
    private val pending = ConcurrentHashMap<Long, (T?) -> Unit>()

    fun register(complete: (T?) -> Unit): (T?) -> Unit {
        val id = nextId.incrementAndGet()
        val done = AtomicBoolean(false)
        val once: (T?) -> Unit = { value ->
            if (done.compareAndSet(false, true)) {
                pending.remove(id)
                complete(value)
            }
        }
        pending[id] = once
        return once
    }

    fun failAll() {
        pending.values.toList().forEach { it(null) }
    }
}
