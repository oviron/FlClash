package com.follow.clash.common

import android.os.SystemClock

// At most maxAttempts in any windowMs, so a tunnel that dies on every start pauses instead of looping.
class RecoveryBudget(private val maxAttempts: Int, private val windowMs: Long) {
    private val attempts = ArrayDeque<Long>()

    @Synchronized
    fun tryAcquire(now: Long = SystemClock.elapsedRealtime()): Boolean {
        while (attempts.isNotEmpty() && now - attempts.first() >= windowMs) attempts.removeFirst()
        if (attempts.size >= maxAttempts) return false
        attempts.addLast(now)
        return true
    }
}
