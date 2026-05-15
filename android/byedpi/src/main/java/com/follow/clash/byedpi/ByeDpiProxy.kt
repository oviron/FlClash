package com.follow.clash.byedpi

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.atomic.AtomicBoolean

object ByeDpiProxy {
    private val running = AtomicBoolean(false)

    init { System.loadLibrary("byedpi") }

    suspend fun start(args: List<String>): Int = withContext(Dispatchers.IO) {
        if (!running.compareAndSet(false, true)) return@withContext -1
        try {
            nativeStart(args.toTypedArray())
        } finally {
            running.set(false)
        }
    }

    fun stop(): Int = nativeStop()

    fun forceClose(): Int = nativeForceClose()

    fun isRunning(): Boolean = running.get()

    private external fun nativeStart(args: Array<String>): Int
    private external fun nativeStop(): Int
    private external fun nativeForceClose(): Int
}
