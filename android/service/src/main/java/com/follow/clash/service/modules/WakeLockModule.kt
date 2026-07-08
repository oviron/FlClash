package com.follow.clash.service.modules

import android.app.Service
import android.content.Intent
import android.os.PowerManager
import androidx.core.content.getSystemService
import com.follow.clash.common.modules.Module
import com.follow.clash.common.receiveBroadcastFlow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

// Owns the tunnel PARTIAL_WAKE_LOCK and holds it only while it earns its keep:
// released after a grace period once the screen goes off, or immediately on
// Doze, and re-acquired on screen-on. The WifiLock stays always-on in
// VpnService (cheaper). Modelled on SuspendModule's screen flow.
class WakeLockModule(private val service: Service) : Module() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private var wakeLock: PowerManager.WakeLock? = null
    private var releaseJob: Job? = null

    private fun isScreenOn(): Boolean =
        service.getSystemService<PowerManager>()?.isInteractive ?: true

    private val isDeviceIdleMode: Boolean
        get() = service.getSystemService<PowerManager>()?.isDeviceIdleMode ?: true

    private fun acquire() {
        releaseJob?.cancel()
        releaseJob = null
        if (wakeLock == null) {
            val pm = service.getSystemService<PowerManager>() ?: return
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "FlClash::VpnTunnel"
            ).apply { acquire() }
        }
    }

    private fun release() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
    }

    private fun onScreen(isScreenOn: Boolean) {
        if (isScreenOn) {
            acquire()
            return
        }
        if (isDeviceIdleMode) {
            releaseJob?.cancel()
            releaseJob = null
            release()
            return
        }
        if (releaseJob == null) {
            releaseJob = scope.launch {
                delay(GRACE_MS)
                if (!isScreenOn()) {
                    release()
                }
                releaseJob = null
            }
        }
    }

    override fun onInstall() {
        scope.launch {
            service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
            }.map { intent ->
                intent.action == Intent.ACTION_SCREEN_ON
            }.onStart {
                emit(isScreenOn())
            }.collect { onScreen(it) }
        }
    }

    override fun onUninstall() {
        releaseJob?.cancel()
        release()
        scope.cancel()
    }

    companion object {
        private const val GRACE_MS = 120_000L
    }
}
