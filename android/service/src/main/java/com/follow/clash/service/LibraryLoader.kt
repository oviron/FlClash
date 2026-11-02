package com.follow.clash.service

import android.content.Context
import com.follow.clash.common.ActiveLibs
import com.follow.clash.common.Logger
import io.github.oviron.libmihomo.Clash
import java.io.File

object LibraryLoader {
    private var attempted: Boolean = false

    // The active dir the core was loaded from; null when it came from the APK.
    @Volatile
    var loadedFrom: String? = null
        private set

    @Synchronized
    fun load(context: Context) {
        if (attempted) return
        val label = ActiveLibs.MIHOMO
        val active = ActiveLibs.dirFor(context, label, ActiveLibs.MIHOMO_SO)
        if (active == null) {
            // A selected dir that lost a file (deleted, storage cleared) would otherwise be
            // skipped without a word while the APK copy runs.
            ActiveLibs.pointerFor(context, label)?.let { dir ->
                val missing = ActiveLibs.missingSo(dir, ActiveLibs.MIHOMO_SO)
                ActiveLibs.markFailed(context, label, dir, "missing ${missing.joinToString()}")
                Logger.e("LibraryLoader", "active mihomo dir incomplete; pointer cleared")
            }
        }
        // Target 37 refuses to System.load a writable .so; installs before that were writable.
        active?.let { dir -> ActiveLibs.MIHOMO_SO.forEach { File(dir, it).setReadOnly() } }
        val dir = active ?: context.applicationInfo.nativeLibraryDir
        Clash.load(dir)
        if (Clash.isLoaded()) {
            loadedFrom = active
            attempted = true
            return
        }
        // A validated active dir that failed to load (e.g. ABI mismatch) has already mapped
        // a bad .so into this process; retrying bundled in-process can't recover it (the
        // linker caches by soname). Clear the pointer so the next launch loads bundled
        // cleanly. attempted stays false so a transient bundled failure can still retry.
        if (active != null) {
            ActiveLibs.markFailed(context, label, active, loadFailureReason())
            Logger.e("LibraryLoader", "active mihomo dir failed to load; pointer cleared")
        }
        throw IllegalStateException("Clash.load failed (dir=$dir)")
    }

    // Clash keeps why load() failed; assertReady() hands it out as the cause.
    private fun loadFailureReason(): String {
        val error = runCatching { Clash.assertReady() }.exceptionOrNull() ?: return "unknown"
        val cause = error.cause ?: error
        return cause.message ?: cause.javaClass.simpleName
    }
}
