package com.follow.clash.common.modules

abstract class Module {
    protected abstract fun onInstall()
    protected abstract fun onUninstall()

    fun install() {
        onInstall()
    }

    fun uninstall() {
        onUninstall()
    }
}
