package com.follow.clash.service

import android.content.Context
import com.follow.clash.common.ActiveLibs
import com.follow.clash.common.Logger
import io.github.oviron.libmihomo.Clash

object LibraryLoader {
    private var attempted: Boolean = false

    @Synchronized
    fun load(context: Context) {
        if (attempted) return
        val active = ActiveLibs.dirFor(context, ActiveLibs.MIHOMO, ActiveLibs.MIHOMO_SO)
        val dir = active ?: context.applicationInfo.nativeLibraryDir
        Clash.load(dir)
        if (Clash.isLoaded()) {
            attempted = true
            return
        }
        // A validated active dir that failed to load (e.g. ABI mismatch) has already mapped
        // a bad .so into this process; retrying bundled in-process can't recover it (the
        // linker caches by soname). Clear the pointer so the next launch loads bundled
        // cleanly. attempted stays false so a transient bundled failure can still retry.
        if (active != null) {
            ActiveLibs.setActive(context, ActiveLibs.MIHOMO, null)
            Logger.e("LibraryLoader", "active mihomo dir failed to load; pointer cleared")
        }
        throw IllegalStateException("Clash.load failed (dir=$dir)")
    }
}
