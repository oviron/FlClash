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
        val config = state.read() ?: return
        job = scope.launch { ByeDpiProxy.start(ByeDpiArgs.build(config)) }
    }

    override fun onUninstall() {
        ByeDpiProxy.stop()
        scope.cancel()
        job = null
    }
}
