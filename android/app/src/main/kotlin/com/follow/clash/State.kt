package com.follow.clash

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.PowerManager
import android.provider.Settings
import androidx.core.content.edit
import androidx.core.net.toUri
import com.follow.clash.common.GlobalState
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.models.NotificationParams
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

private const val NATIVE_PREFS = "native_state"
private const val BATTERY_EXEMPTION_ASKED = "battery_exemption_asked"

// Asked once after the first successful start; OEM battery savers otherwise kill the tunnel.
private fun requestBatteryExemptionOnce(activity: Activity) {
    val app = GlobalState.application
    val prefs = app.getSharedPreferences(NATIVE_PREFS, Context.MODE_PRIVATE)
    if (prefs.getBoolean(BATTERY_EXEMPTION_ASKED, false)) return
    val power = app.getSystemService(PowerManager::class.java) ?: return
    if (power.isIgnoringBatteryOptimizations(app.packageName)) return
    val intent = Intent(
        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
        "package:${app.packageName}".toUri(),
    )
    activity.runOnUiThread {
        runCatching { activity.startActivity(intent) }
            .onSuccess { prefs.edit { putBoolean(BATTERY_EXEMPTION_ASKED, true) } }
            .onFailure { GlobalState.log("Battery exemption request failed: $it") }
    }
}

enum class RunState {
    START, PENDING, STOP
}


object State {

    val runLock = Mutex()

    var runTime: Long = 0

    var sharedState: SharedState = SharedState()

    // Staged by NetworkRulesController before a headless start so a cold boot
    // picks up the target profile's proxy selections, not the last profile's.
    @Volatile
    var pendingSelectedMap: Map<String, String>? = null

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)

    var flutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

    suspend fun handleToggleAction() {
        var action: (suspend () -> Unit)?
        runLock.withLock {
            dropStaleStartLocked()
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> ::handleStopServiceAction
                RunState.STOP -> ::handleStartServiceAction
            }
        }
        action?.invoke()
    }

    suspend fun handleSyncState() {
        runLock.withLock {
            // Only startService leaves PENDING outside the lock, while it waits for VPN consent.
            if (runStateFlow.value == RunState.PENDING) return
            try {
                Service.bind()
                runTime = Service.getRunTime()
                val runState = when (runTime == 0L) {
                    true -> RunState.STOP
                    false -> RunState.START
                }
                runStateFlow.tryEmit(runState)
            } catch (_: Exception) {
                runStateFlow.tryEmit(RunState.STOP)
            }
        }
    }

    // A START left behind by a service that died unseen would reject every later start.
    private suspend fun dropStaleStartLocked() {
        if (runStateFlow.value != RunState.START) return
        Service.bind()
        runTime = Service.queryRunTime() ?: return
        if (runTime == 0L) runStateFlow.tryEmit(RunState.STOP)
    }

    suspend fun handleStartServiceAction() {
        runLock.withLock {
            dropStaleStartLocked()
            if (runStateFlow.value != RunState.STOP) {
                return
            }
            tilePlugin?.handleStart()
            if (flutterEngine != null) {
                return
            }
            startServiceWithPref()
        }

    }

    suspend fun handleStopServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.START) {
                return
            }
            tilePlugin?.handleStop()
            if (flutterEngine != null) {
                return
            }
            GlobalState.application.showToast(sharedState.stopTip)
            handleStopService()
        }
    }

    fun handleStartService() {
        val appPlugin = flutterEngine?.plugin<AppPlugin>()
        if (appPlugin != null) {
            appPlugin.requestNotificationsPermission {
                startService()
            }
            return
        }
        startService()
    }

    private fun startServiceWithPref() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                sharedState = GlobalState.application.sharedState
                setupAndStart()
            }
        }
    }

    suspend fun syncState() {
        Service.updateNotificationParams(
            NotificationParams(
                title = sharedState.currentProfileName,
                stopText = sharedState.stopText,
            )
        )
    }

    private suspend fun setupAndStart() {
        Service.bind()
        syncState()
        GlobalState.application.showToast(sharedState.startTip)
        val initParams = mutableMapOf<String, Any>()
        initParams["home-dir"] = GlobalState.application.filesDir.path
        initParams["version"] = android.os.Build.VERSION.SDK_INT
        val initParamsString = Gson().toJson(initParams)
        val params = sharedState.setupParams
        val pending = pendingSelectedMap
        pendingSelectedMap = null
        val effectiveParams = if (pending != null && params != null) {
            params.copy(selectedMap = pending)
        } else {
            params
        }
        val setupParamsString = Gson().toJson(effectiveParams)
        Service.quickSetup(
            initParamsString,
            setupParamsString,
            onStarted = null,
            onResult = {
                if (it.isEmpty()) {
                    startService()
                } else {
                    GlobalState.application.showToast(it)
                }
            },
        )
    }

    private suspend fun prepareVpn(): Boolean =
        appPlugin?.prepareVpn() ?: (VpnService.prepare(GlobalState.application) == null)

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                dropStaleStartLocked()
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                runStateFlow.tryEmit(RunState.PENDING)
            }
            try {
                val options = sharedState.vpnOptions ?: return@launch
                // The consent dialog stays open as long as the user leaves it, so it is awaited
                // outside runLock; PENDING keeps other starts and stops out meanwhile.
                if (options.enable && !prepareVpn()) return@launch
                val started = runLock.withLock {
                    // A timed-out AIDL reply does not mean the service failed to start.
                    runTime = Service.startService(options, runTime)
                        .takeIf { it != 0L } ?: Service.getRunTime()
                    if (runTime != 0L) runStateFlow.tryEmit(RunState.START)
                    runTime != 0L
                }
                if (started) appPlugin?.activity?.let(::requestBatteryExemptionOnce)
            } finally {
                if (runStateFlow.value == RunState.PENDING) {
                    runStateFlow.tryEmit(RunState.STOP)
                }
            }
        }
    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.START) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)
                    runTime = Service.stopService()
                    runStateFlow.tryEmit(RunState.STOP)
                } finally {
                    if (runStateFlow.value == RunState.PENDING) {
                        runStateFlow.tryEmit(RunState.START)
                    }
                }
            }
        }
    }
}



