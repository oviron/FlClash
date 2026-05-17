package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import com.follow.clash.common.modules.moduleLoader
import com.follow.clash.service.modules.NetworkObserveModule
import com.follow.clash.service.modules.NotificationModule
import com.follow.clash.service.modules.SuspendModule
import io.github.oviron.libmihomo.Clash
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class CommonService : Service(), IBaseService,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val self: CommonService
        get() = this

    private val loader = moduleLoader {
        install(NetworkObserveModule(self))
        install(NotificationModule(self))
        install(SuspendModule(self))
    }

    override fun onCreate() {
        super.onCreate()
        LibraryLoader.load(this)
        handleCreate()
    }

    override fun onDestroy() {
        loader.cancel()
        handleDestroy()
        super.onDestroy()
    }

    override fun onLowMemory() {
        if (Clash.isLoaded()) Clash.forceGC()
        super.onLowMemory()
    }

    private val binder = LocalBinder()

    override var destroyed = false

    inner class LocalBinder : Binder() {
        fun getService(): CommonService = this@CommonService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun start() {
        try {
            loader.load()
        } catch (_: Exception) {
            stop()
        }
    }

    override fun stop() {
        handleDestroy()
        loader.cancel()
        stopSelf()
    }
}
