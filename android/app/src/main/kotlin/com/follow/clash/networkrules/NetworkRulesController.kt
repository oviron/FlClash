package com.follow.clash.networkrules

import android.content.Context
import android.os.SystemClock
import com.follow.clash.RunState
import com.follow.clash.State
import com.follow.clash.common.GlobalState
import com.follow.clash.common.networkrules.NetworkDecision
import com.follow.clash.common.networkrules.NetworkRulesCodec
import com.follow.clash.common.networkrules.NetworkRulesEngine
import com.follow.clash.common.networkrules.NetworkRuleType
import com.follow.clash.common.networkrules.NetworkSnapshot
import com.follow.clash.common.networkrules.RulesMirror
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.File

data class NetworkRulesStatus(
    val type: NetworkRuleType,
    val ssid: String?,
    val decision: NetworkDecision,
    val reason: String,
    val overridden: Boolean,
)

private data class ManualOverride(val networkKey: Long, val running: Boolean)

// The brain: reads the rules mirror, computes the decision for the current
// network and actuates the VPN through the same headless seam the boot path
// uses (State.handleStart/StopServiceAction, serialised by State.runLock).
// Manual toggles win until the network actually changes (keyed by networkKey).
object NetworkRulesController {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val mutex = Mutex()

    private var observer: NetworkRulesObserver? = null
    private var runStateJob: Job? = null

    private var currentKey: Long = NO_NETWORK
    private var override: ManualOverride? = null
    private var lastEngineDesired: Boolean? = null
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
        val decision: NetworkDecision
        val reason: String
        val overridden: Boolean
        mutex.withLock {
            if (key != currentKey) {
                override = null
                currentKey = key
            }
            val mirror = readMirror()
            decision = NetworkRulesEngine.resolve(mirror, snapshot)
            reason = buildReason(mirror, snapshot, decision)
            overridden = override?.networkKey == key
        }
        publish(NetworkRulesStatus(snapshot.type, snapshot.ssid, decision, reason, overridden))
        if (!overridden) actuate(decision)
    }

    // Sets lastEngineDesired + the guard window atomically under the mutex, then
    // performs the (suspending) State call OUTSIDE the lock so we never hold our
    // mutex across State.runLock. The emission that results lands inside the
    // guard window and is classified as engine-initiated, not a manual toggle.
    private suspend fun actuate(decision: NetworkDecision) {
        val running = State.runStateFlow.value == RunState.START
        var action: (suspend () -> Unit)? = null
        mutex.withLock {
            when (decision) {
                NetworkDecision.START -> {
                    lastEngineDesired = true
                    if (!running) {
                        engineGuardUntil = SystemClock.elapsedRealtime() + GUARD_MS
                        action = State::handleStartServiceAction
                    }
                }

                NetworkDecision.STOP -> {
                    lastEngineDesired = false
                    if (running) {
                        engineGuardUntil = SystemClock.elapsedRealtime() + GUARD_MS
                        action = State::handleStopServiceAction
                    }
                }

                NetworkDecision.LEAVE_AS_IS -> Unit
            }
        }
        action?.invoke()
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
                override = ManualOverride(currentKey, running)
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
        val matched = NetworkRulesEngine.evaluate(mirror.rules, snapshot)
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
    private const val GUARD_MS = 6000L
    private const val NO_NETWORK = Long.MIN_VALUE
}
