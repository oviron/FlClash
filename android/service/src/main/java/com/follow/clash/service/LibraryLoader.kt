package com.follow.clash.service

import android.content.Context
import io.github.oviron.libmihomo.Clash

/**
 * Single entry point that pulls the bundled mihomo bridge libraries into
 * the process. Idempotent across services in the same process; safe to call
 * from each `Service.onCreate`.
 *
 * Today the path is the APK-bundled `nativeLibraryDir`. The Phase E
 * runtime-version-switch flow plugs in here: replace the directory with an
 * `/data/.../files/libs/libmihomo-v<X.Y.Z>/jni/<abi>` path selected by the
 * user and call [reset] before [load] to switch libraries.
 */
object LibraryLoader {
    @Volatile
    private var loaded: Boolean = false

    @Synchronized
    fun load(context: Context) {
        if (loaded) return
        Clash.load(context.applicationInfo.nativeLibraryDir)
        loaded = true
    }

    @Synchronized
    fun reset() {
        loaded = false
    }
}
