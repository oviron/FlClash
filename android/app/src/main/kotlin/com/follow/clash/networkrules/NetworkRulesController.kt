package com.follow.clash.networkrules

import android.content.Context
import android.os.SystemClock
import com.follow.clash.RunState
import com.follow.clash.Service
import com.follow.clash.State
import com.follow.clash.common.GlobalState
import com.follow.clash.common.networkrules.NetworkDecision
import com.follow.clash.common.networkrules.NetworkResolution
import com.follow.clash.common.networkrules.NetworkRulesCodec
import com.follow.clash.common.networkrules.NetworkRulesEngine
import com.follow.clash.common.networkrules.NetworkRuleType
import com.follow.clash.common.networkrules.decideManualSwitch
import com.follow.clash.common.networkrules.NetworkSnapshot
import com.follow.clash.common.networkrules.RulesMirror
import com.follow.clash.service.models.NotificationParams
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.File
import java.util.concurrent.atomic.AtomicLong

data class NetworkRulesStatus(
    val type: NetworkRuleType,
    val ssid: String?,
    val decision: NetworkDecision,
    val reason: String,
    val overridden: Boolean,
)

private data class ManualOverride(
    val networkKey: Long,
    val running: Boolean? = null,
    val profileId: Int? = null,
)

// The brain: reads the rules mirror, computes the decision for the current
// network and actuates the VPN through the same headless seam the boot path
// uses (State.handleStart/StopServiceAction, serialised by State.runLock).
// Manual toggles win until the network actually changes (keyed by networkKey).
object NetworkRulesController {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val mutex = Mutex()
    private val swapSeq = AtomicLong(0)

    private var observer: NetworkRulesObserver? = null
    private var runStateJob: Job? = null

    private var currentKey: Long = NO_NETWORK
    private var override: ManualOverride? = null
    private var lastEngineDesired: Boolean? = null
    // The profile the engine last applied via the FOREGROUND path; null after a
    // headless apply (Dart's activeProfileId is then stale and unattributable).
    // Manual-switch detection only arms while this is non-null.
    private var lastEngineProfileId: Int? = null
    private var engineGuardUntil: Long = 0

    @Volatile
    private var lastSnapshot: NetworkSnapshot? = null

    @Volatile
    private var lastSnapshotKey: Long = NO_NETWORK

    @Volatile
    var status: NetworkRulesStatus? = null
        private set

    @Volatile
    var statusListener: ((NetworkRulesStatus) -> Unit)? = null

    // Set while the Flutter engine is attached. When present, a profile switch
    // is routed through Dart (applyProfile) so the UI/providers stay coherent
    // instead of the resident swapping config.yaml directly.
    @Volatile
    var profileSwitchListener: ((Int) -> Unit)? = null

    fun start(context: Context) {
        if (observer != null) return
        observer = NetworkRulesObserver(context.applicationContext) { snapshot, key ->
            onSnapshot(snapshot, key)
        }.also { it.start() }
        runStateJob = scope.launch {
            State.runStateFlow.drop(1).collect { onRunStateChanged(it) }
        }
    }

    fun stop() {
        observer?.stop()
        observer = null
        runStateJob?.cancel()
        runStateJob = null
        mutexReset()
    }

    private fun mutexReset() {
        override = null
        lastEngineDesired = null
        lastEngineProfileId = null
        currentKey = NO_NETWORK
    }

    // Re-run the last decision after the rules mirror changed (rule edited /
    // default toggled) so the user sees the effect without a network change.
    fun reevaluate() {
        val snapshot = lastSnapshot ?: return
        scope.launch { onSnapshot(snapshot, lastSnapshotKey) }
    }

    private suspend fun onSnapshot(snapshot: NetworkSnapshot, key: Long) {
        lastSnapshot = snapshot
        lastSnapshotKey = key
        val resolution: NetworkResolution
        val reason: String
        val overridden: Boolean
        mutex.withLock {
            if (key != currentKey) {
                override = null
                currentKey = key
            }
            val mirror = readMirror()
            resolution = NetworkRulesEngine.resolveFull(mirror, snapshot)
            // A foreground-applied profile is echoed back as activeProfileId; a
            // divergence (outside the guard window) is the user switching by
            // hand -> pin the profile so the engine stops fighting on this key.
            val manualProfile = decideManualSwitch(
                mirror.activeProfileId,
                lastEngineProfileId,
                engineGuardUntil,
                SystemClock.elapsedRealtime(),
            )
            if (manualProfile != null) {
                override = ManualOverride(key, override?.running, manualProfile)
            }
            reason = buildReason(mirror, snapshot, resolution.decision)
            overridden = override?.networkKey == key
        }
        publish(
            NetworkRulesStatus(snapshot.type, snapshot.ssid, resolution.decision, reason, overridden),
        )
        if (!overridden) actuate(resolution)
    }

    // Sets lastEngineDesired + the guard window atomically under the mutex, then
    // performs the (suspending) State call OUTSIDE the lock so we never hold our
    // mutex across State.runLock. The emission that results lands inside the
    // guard window and is classified as engine-initiated, not a manual toggle.
    private suspend fun actuate(resolution: NetworkResolution) {
        val foreground = profileSwitchListener
        val running = State.runStateFlow.value == RunState.START
        // A profile target applies only when the core is, or is about to be, up.
        val profileTarget = resolution.profileId
            ?.takeIf { running || resolution.decision == NetworkDecision.START }
        var startAction: (suspend () -> Unit)? = null
        mutex.withLock {
            when (resolution.decision) {
                NetworkDecision.START -> {
                    lastEngineDesired = true
                    if (!running) {
                        engineGuardUntil = SystemClock.elapsedRealtime() + GUARD_MS
                        startAction = State::handleStartServiceAction
                    }
                }

                NetworkDecision.STOP -> {
                    lastEngineDesired = false
                    if (running) {
                        engineGuardUntil = SystemClock.elapsedRealtime() + GUARD_MS
                        startAction = State::handleStopServiceAction
                    }
                }

                NetworkDecision.LEAVE_AS_IS -> Unit
            }
            if (profileTarget != null) {
                // Only a foreground apply is attributable to the engine (Dart
                // echoes it back via activeProfileId); a headless apply is not,
                // so disarm manual detection until the next foreground apply.
                lastEngineProfileId = if (foreground != null) profileTarget else null
                engineGuardUntil = SystemClock.elapsedRealtime() + GUARD_MS
            }
        }
        // File IO + binder calls run OUTSIDE the mutex (never held across State).
        if (profileTarget != null) {
            applyResolvedProfile(profileTarget, foreground, running, resolution)
        }
        startAction?.invoke()
    }

    // Headless hot-swap updates mihomo routing (config.yaml) and the
    // notification, but NOT the VpnService per-app allow/deny set: that is bound
    // to the TUN fd at establish() and re-applying it would drop the tunnel.
    private suspend fun applyResolvedProfile(
        profileTarget: Int,
        foreground: ((Int) -> Unit)?,
        running: Boolean,
        resolution: NetworkResolution,
    ) {
        when {
            foreground != null -> foreground(profileTarget)
            running -> applyProfileHot(
                profileTarget,
                resolution.selectedMap,
                resolution.profileName,
            )
            // Cold boot: stage config + selectedMap so quickSetup boots it.
            swapConfig(profileTarget) -> State.pendingSelectedMap = resolution.selectedMap
        }
    }

    // Live profile swap: overwrite config.yaml from the pre-baked cache and tell
    // the running core to re-apply. applyConfig re-reads config.yaml without
    // touching the TUN fd, so the VPN never drops.
    private suspend fun applyProfileHot(
        profileId: Int,
        selectedMap: Map<String, String>,
        profileName: String?,
    ) {
        if (!swapConfig(profileId)) return
        val data = Gson().toJson(mapOf("selected-map" to selectedMap))
        val envelope = Gson().toJson(
            mapOf("id" to "nr-$profileId", "method" to "setupConfig", "data" to data),
        )
        val result = Service.invokeAction(envelope, null)
        if (result.isFailure) {
            GlobalState.log("network-rules: hot apply failed for profile $profileId: ${result.exceptionOrNull()}")
            return
        }
        // Retitle the notification only after the core accepted the config; on
        // failure it keeps showing the actually-active profile.
        if (profileName != null) {
            Service.updateNotificationParams(
                NotificationParams(title = profileName, stopText = State.sharedState.stopText),
            )
        }
    }

    // Atomically replace config.yaml with the cached profile config. Returns
    // false on a cache miss (deleted/never-baked profile) so the caller leaves
    // the profile dimension untouched and never boots into a missing config.
    // The resident is the only writer while headless (Dart's foreground path
    // takes over once attached); a unique tmp per swap keeps two overlapping
    // resident swaps from clobbering each other's rename.
    private fun swapConfig(profileId: Int): Boolean {
        val filesDir = GlobalState.application.filesDir
        val cache = File(filesDir, "$CACHE_DIR/$profileId.yaml")
        if (!cache.exists()) {
            GlobalState.log("network-rules: cache miss for profile $profileId, leaving profile")
            return false
        }
        val tmp = File(filesDir, "$CONFIG_FILE.${swapSeq.getAndIncrement()}.tmp")
        return try {
            val target = File(filesDir, CONFIG_FILE)
            cache.copyTo(tmp, overwrite = true)
            if (!tmp.renameTo(target)) {
                tmp.copyTo(target, overwrite = true)
            }
            true
        } catch (e: Throwable) {
            GlobalState.log("network-rules: config swap failed for $profileId: $e")
            false
        } finally {
            if (tmp.exists()) tmp.delete()
        }
    }

    // A run-state flip outside the engine's own guard window AND differing from
    // what the engine last asked for is a manual toggle; record it so the engine
    // stops fighting the user on this network. Guard read + override write are
    // under the mutex so they are atomic w.r.t. actuate().
    private suspend fun onRunStateChanged(state: RunState) {
        if (state == RunState.PENDING) return
        val running = state == RunState.START
        mutex.withLock {
            if (SystemClock.elapsedRealtime() < engineGuardUntil) return@withLock
            if (running != lastEngineDesired) {
                override = ManualOverride(
                    currentKey,
                    running,
                    override?.takeIf { it.networkKey == currentKey }?.profileId,
                )
            }
        }
    }

    private fun readMirror(): RulesMirror {
        val file = File(GlobalState.application.filesDir, MIRROR_FILE)
        if (!file.exists()) return NetworkRulesCodec.disabled
        return try {
            NetworkRulesCodec.parse(file.readText())
        } catch (e: Throwable) {
            GlobalState.log("network-rules mirror read failed: $e")
            NetworkRulesCodec.disabled
        }
    }

    private fun buildReason(
        mirror: RulesMirror,
        snapshot: NetworkSnapshot,
        decision: NetworkDecision,
    ): String {
        val matched = NetworkRulesEngine.evaluate(mirror.rules, snapshot, mirror.activeProfileId)
        val where = describe(snapshot)
        return if (matched != null) {
            "rule matched on $where -> ${decision.name}"
        } else {
            "no rule on $where -> default ${decision.name}"
        }
    }

    private fun describe(snapshot: NetworkSnapshot): String = when (snapshot.type) {
        NetworkRuleType.WIFI -> "wifi:${snapshot.ssid ?: "<unknown>"}"
        NetworkRuleType.CELLULAR -> "cellular"
        NetworkRuleType.ETHERNET -> "ethernet"
        NetworkRuleType.NONE -> "none"
    }

    private fun publish(next: NetworkRulesStatus) {
        status = next
        statusListener?.invoke(next)
    }

    private const val MIRROR_FILE = "network-rules.json"
    private const val CACHE_DIR = "network-rules-cache"
    private const val CONFIG_FILE = "config.yaml"
    private const val GUARD_MS = 6000L
    private const val NO_NETWORK = Long.MIN_VALUE
}
