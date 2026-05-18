package com.follow.clash.common.modules

abstract class Module {
    // Default no-op. onInstall() is preferred for sync modules; modules that
    // must perform asynchronous work during install (e.g. byedpi listener bind)
    // should override onInstallSuspend instead, which is awaited inside the
    // moduleLoader scope without bridging through runBlocking.
    protected open fun onInstall() {}
    protected open suspend fun onInstallSuspend() = onInstall()

    protected abstract fun onUninstall()

    suspend fun install() {
        onInstallSuspend()
    }

    fun uninstall() {
        onUninstall()
    }
}
