package com.follow.clash.common.modules

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.atomic.AtomicBoolean

interface ModuleLoaderScope {
    fun <T : Module> install(module: T): T
}

interface ModuleLoader {
    /**
     * Awaits all module installs. Callers (VpnService.start, CommonService.start)
     * MUST NOT proceed to invariant-dependent work (e.g. Clash.startTUN that
     * relies on the byedpi listener being bound) before this returns.
     */
    fun load()

    fun cancel()
}

fun CoroutineScope.moduleLoader(block: suspend ModuleLoaderScope.() -> Unit): ModuleLoader {
    val modules = mutableListOf<Module>()
    var job: Job? = null
    val loaded = AtomicBoolean(false)
    // Per-loader (per-service) mutex. Was previously a file-level singleton,
    // which globally serialized module installs across VpnService /
    // CommonService / RemoteService.
    val mutex = Mutex()

    return object : ModuleLoader {
        override fun load() {
            if (!loaded.compareAndSet(false, true)) return
            // runBlocking inside the service start() path so callers can rely
            // on "modules are installed by the time load() returns" as a
            // synchronous invariant. The mutex.withLock keeps install order
            // sequential and protects against concurrent cancel.
            runBlocking(Dispatchers.IO) {
                val installJob = launch {
                    mutex.withLock {
                        val scope = object : ModuleLoaderScope {
                            override fun <T : Module> install(module: T): T {
                                modules.add(module)
                                return module
                            }
                        }
                        scope.block()
                        for (module in modules) module.install()
                    }
                }
                job = installJob
                installJob.join()
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
