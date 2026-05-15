package com.follow.clash.byedpi

import io.github.oviron.libbyedpi.ByeDpi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.atomic.AtomicBoolean

object ByeDpiProxy {
    private val running = AtomicBoolean(false)

    suspend fun start(args: List<String>): Int = withContext(Dispatchers.IO) {
        if (!running.compareAndSet(false, true)) return@withContext -1
        try {
            ByeDpi.nativeStart(args.toTypedArray())
        } finally {
            running.set(false)
        }
    }

    fun stop(): Int = ByeDpi.nativeStop()
}
