package com.follow.clash.service

import android.content.Context
import io.github.oviron.libmihomo.Clash

object LibraryLoader {
    @Volatile
    private var attempted: Boolean = false

    @Synchronized
    fun load(context: Context) {
        if (attempted) return
        Clash.load(context.applicationInfo.nativeLibraryDir)
        attempted = true
    }
}
