package com.follow.clash.byedpi

import android.content.Context
import com.follow.clash.common.modules.Module
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class ByeDpiModule(context: Context) : Module() {
    private val state = ByeDpiState(context)
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var job: Job? = null

    override fun onInstall() {
        if (!state.enabled) return
        val args = ByeDpiArgs.build(state.toConfig())
        job = scope.launch { ByeDpiProxy.start(args) }
    }

    override fun onUninstall() {
        ByeDpiProxy.stop()
        scope.cancel()
        job = null
    }
}
