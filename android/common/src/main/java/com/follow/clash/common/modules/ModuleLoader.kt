package com.follow.clash.common.modules

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.atomic.AtomicBoolean

interface ModuleLoaderScope {
    fun <T : Module> install(module: T): T
}

interface ModuleLoader {
    fun load()

    fun cancel()
}

fun CoroutineScope.moduleLoader(block: suspend ModuleLoaderScope.() -> Unit): ModuleLoader {
    val modules = mutableListOf<Module>()
    var job: Job? = null
    val loaded = AtomicBoolean(false)
    // Per-loader (per-service) mutex. Was previously a file-level singleton,
    // which globally serialized module installs across VpnService /
    // CommonService / RemoteService. Anti-loop ordering inside one loader is
    // still guaranteed by sequential .install() calls under withLock.
    val mutex = Mutex()

    return object : ModuleLoader {
        override fun load() {
            if (!loaded.compareAndSet(false, true)) return
            job = launch(Dispatchers.IO) {
                mutex.withLock {
                    val scope = object : ModuleLoaderScope {
                        override fun <T : Module> install(module: T): T {
                            modules.add(module)
                            return module
                        }
                    }
                    scope.block()
                    // Install in order — each module's onInstallSuspend awaited
                    // before the next starts, preserving the byedpi-before-TUN
                    // ordering invariant.
                    for (module in modules) module.install()
                }
            }
        }

        override fun cancel() {
            if (!loaded.compareAndSet(true, false)) return
            launch(Dispatchers.IO) {
                job?.cancel()
                mutex.withLock {
                    modules.asReversed().forEach { it.uninstall() }
                    modules.clear()
                }
            }
        }
    }
}
