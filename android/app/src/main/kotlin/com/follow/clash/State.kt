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
import com.follow.clash.common.LifecycleSequencer
import com.follow.clash.common.RecoveryBudget
import com.follow.clash.common.shouldShowTileActionToast
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.flow.MutableStateFlow
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

    private val lifecycle = LifecycleSequencer(GlobalState)

    private val runLock = lifecycle.lock

    // A tunnel that dies on every start pauses instead of looping.
    private val recoveryBudget = RecoveryBudget(maxAttempts = 3, windowMs = 10 * 60_000L)

    var runTime: Long = 0

    // A UI process restarted without Flutter still needs the tile's profile name and collapse choice.
    var sharedState: SharedState = GlobalState.application.sharedState

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

    // Entry points go through here so requests reach the lock, or Dart, in the order they were made.
    fun request(action: suspend State.() -> Unit) {
        lifecycle.launch { action() }
    }

    suspend fun handleToggleAction(fromTile: Boolean = false) {
        var action: (suspend () -> Unit)?
        runLock.withLock {
            dropStaleStartLocked()
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> suspend { handleStopServiceAction(fromTile) }
                RunState.STOP -> suspend { handleStartServiceAction(fromTile) }
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

    // A start waiting for consent stays PENDING: it binds a fresh :remote when it commits.
    suspend fun handleRemoteDied() {
        val lost = runLock.withLock {
            runTime = 0
            (runStateFlow.value == RunState.START).also {
                if (it) runStateFlow.tryEmit(RunState.STOP)
            }
        }
        if (lost) recoverTunnel()
    }

    // True when a recovery start went out. A stop since the job fired has disarmed it.
    suspend fun handleRecoveryCheck(): Boolean {
        handleSyncState()
        val lost = runLock.withLock { runStateFlow.value == RunState.STOP && RecoveryJob.isArmed }
        return lost && recoverTunnel()
    }

    // Under runLock so it lands after, never before, a start committing now.
    suspend fun disarmRecovery() {
        runLock.withLock { RecoveryJob.cancel() }
    }

    private suspend fun recoverTunnel(): Boolean {
        if (!recoveryBudget.tryAcquire()) {
            GlobalState.log("Tunnel recovery paused: too many restarts")
            return false
        }
        GlobalState.log("Recovering the tunnel")
        handleStartServiceAction()
        return true
    }

    // A START left behind by a service that died unseen would reject every later start.
    private suspend fun dropStaleStartLocked() {
        if (runStateFlow.value != RunState.START) return
        Service.bind()
        runTime = Service.queryRunTime() ?: return
        if (runTime == 0L) runStateFlow.tryEmit(RunState.STOP)
    }

    // With Flutter attached, Dart queues the request and checks the state when it runs;
    // checking here would drop a start that follows a stop Dart has not run yet.
    suspend fun handleStartServiceAction(fromTile: Boolean = false) {
        if (flutterEngine != null) {
            tilePlugin?.handleStart()
            return
        }
        runLock.withLock {
            dropStaleStartLocked()
            if (runStateFlow.value != RunState.STOP) {
                return
            }
            startServiceWithPref(fromTile)
        }
    }

    // session is the run time a service-destroyed report belongs to; 0 when the stop is not such a report.
    suspend fun handleStopServiceAction(fromTile: Boolean = false, session: Long = 0L) {
        runLock.withLock {
            // A late report about an earlier tunnel must not stop the one running now.
            if (session != 0L && session != runTime) {
                return
            }
            if (flutterEngine != null) {
                tilePlugin?.handleStop()
                return
            }
            // A stop during PENDING still cancels the start that is waiting to commit.
            if (runStateFlow.value == RunState.STOP) {
                return
            }
            if (shouldShowTileActionToast(fromTile, sharedState.quickTileCollapsePanel)) {
                GlobalState.application.showToast(sharedState.stopTip)
            }
            handleStopService()
        }
    }

    fun handleStartService() {
        val ticket = lifecycle.startTicket()
        val appPlugin = flutterEngine?.plugin<AppPlugin>()
        if (appPlugin != null) {
            appPlugin.requestNotificationsPermission {
                startService(ticket)
            }
            return
        }
        startService(ticket)
    }

    private fun startServiceWithPref(fromTile: Boolean) {
        val ticket = lifecycle.startTicket()
        lifecycle.launch {
            runLock.withLock {
                if (lifecycle.isCancelled(ticket) || runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                sharedState = GlobalState.application.sharedState
                setupAndStart(fromTile, ticket)
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

    private suspend fun setupAndStart(fromTile: Boolean, ticket: Long) {
        Service.bind()
        syncState()
        if (shouldShowTileActionToast(fromTile, sharedState.quickTileCollapsePanel)) {
            GlobalState.application.showToast(sharedState.startTip)
        }
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
                    startService(ticket)
                } else {
                    GlobalState.application.showToast(it)
                }
            },
        )
    }

    private suspend fun prepareVpn(): Boolean =
        appPlugin?.prepareVpn() ?: (VpnService.prepare(GlobalState.application) == null)

    private fun startService(ticket: Long) {
        lifecycle.launch {
            if (!enterPending(ticket)) return@launch
            var settled = false
            try {
                val options = sharedState.vpnOptions ?: return@launch
                // The consent dialog stays open as long as the user leaves it, so it is awaited
                // outside runLock; PENDING keeps other starts and stops out meanwhile.
                if (options.enable && !prepareVpn()) return@launch
                val started = runLock.withLock {
                    settled = true
                    commitStartLocked(ticket, options)
                }
                if (started) appPlugin?.activity?.let(::requestBatteryExemptionOnce)
            } finally {
                // Once settled, a PENDING seen here belongs to a later stop.
                if (!settled && runStateFlow.value == RunState.PENDING) {
                    runStateFlow.tryEmit(RunState.STOP)
                }
            }
        }
    }

    private suspend fun enterPending(ticket: Long): Boolean = runLock.withLock {
        dropStaleStartLocked()
        val ready = !lifecycle.isCancelled(ticket) && runStateFlow.value == RunState.STOP
        if (ready) runStateFlow.tryEmit(RunState.PENDING)
        ready
    }

    // A stop requested while the consent dialog was open has cancelled the ticket.
    private suspend fun commitStartLocked(ticket: Long, options: VpnOptions): Boolean {
        var started = false
        try {
            if (!lifecycle.isCancelled(ticket)) {
                runTime = startRemote(options)
                started = runTime != 0L
                if (started) RecoveryJob.schedule()
            }
        } finally {
            runStateFlow.tryEmit(if (started) RunState.START else RunState.STOP)
        }
        return started
    }

    // No reply is not a failed start: the start may still land, so it is cancelled
    // behind itself to leave both processes stopped.
    private suspend fun startRemote(options: VpnOptions): Long {
        Service.startService(options, runTime)?.let { return it }
        Service.queryRunTime()?.takeIf { it != 0L }?.let { return it }
        Service.stopService()
        return 0L
    }

    fun handleStopService() {
        lifecycle.cancelStarts()
        lifecycle.launch {
            runLock.withLock {
                RecoveryJob.cancel()
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



