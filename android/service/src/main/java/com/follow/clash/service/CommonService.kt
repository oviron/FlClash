package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import com.follow.clash.common.GlobalState
import com.follow.clash.common.modules.moduleLoader
import com.follow.clash.service.modules.NetworkObserveModule
import com.follow.clash.service.modules.NotificationModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

// Selected by RemoteService.handleStartService when VpnOptions.enable is false:
// the no-TUN, HTTP/SOCKS listener-only codepath.
class CommonService : Service(), IBaseService,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val self: CommonService
        get() = this

    private val loader = moduleLoader {
        install(NetworkObserveModule(self))
        install(NotificationModule(self))
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

    private val binder = LocalBinder()

    override var destroyed = false

    inner class LocalBinder : Binder() {
        fun getService(): CommonService = this@CommonService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override suspend fun start(): Boolean = try {
        loader.load()
        true
    } catch (e: Exception) {
        GlobalState.log("CommonService start failed: $e")
        stop()
        false
    }

    override fun stop() {
        handleDestroy()
        loader.cancel()
        stopSelf()
    }
}
