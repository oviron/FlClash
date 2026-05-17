package com.follow.clash.service

import android.content.Context
import com.follow.clash.common.Logger
import io.github.oviron.libmihomo.Clash

object LibraryLoader {
    private var attempted: Boolean = false

    @Synchronized
    fun load(context: Context) {
        if (attempted) return
        try {
            Clash.load(context.applicationInfo.nativeLibraryDir)
            attempted = true
        } catch (e: Throwable) {
            Logger.e("LibraryLoader", "Clash.load failed: ${e.message}\n${e.stackTraceToString()}")
            // Keep attempted = false so the next load() call can retry —
            // a transient failure (e.g., temporary FD exhaustion) shouldn't
            // permanently disable native loading.
            throw e
        }
    }
}
