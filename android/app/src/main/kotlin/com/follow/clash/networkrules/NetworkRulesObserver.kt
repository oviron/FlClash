package com.follow.clash.networkrules

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import androidx.core.content.getSystemService
import com.follow.clash.common.GlobalState
import com.follow.clash.common.networkrules.NetworkSnapshot
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.ConcurrentHashMap

// Single NOT_VPN callback that survives the UI being killed (it lives in the
// resident service). Picks the best underlying network by transport priority,
// coalesces bursts, and emits {snapshot, networkKey} only on real change.
class NetworkRulesObserver(
    context: Context,
    private val onSnapshot: suspend (NetworkSnapshot, Long) -> Unit,
) {
    private val connectivity = context.getSystemService<ConnectivityManager>()
    private val reader = NetworkSnapshotReader(context)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val lock = Mutex()

    // ConcurrentHashMap: written from the ConnectivityManager Binder thread
    // (callbacks) and iterated on Dispatchers.Default in bestNetwork(); its
    // weakly-consistent iteration is safe across that boundary.
    private val networks = ConcurrentHashMap<Network, NetworkCapabilities>()

    private var debounceJob: Job? = null
    private var firstEmit = true
    private var lastSnapshot: NetworkSnapshot? = null
    private var lastKey: Long = Long.MIN_VALUE

    private val request = NetworkRequest.Builder()
        .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        .build()

    // FLAG_INCLUDE_LOCATION_INFO (API 31+) is mandatory or transportInfo's
    // WifiInfo.ssid is redacted to null and WifiNamed rules never match. Caps
    // (with the SSID) arrive via onCapabilitiesChanged, which always fires right
    // after onAvailable, so we populate the map only from there. Still needs
    // ACCESS_FINE_LOCATION granted + location services on for a real SSID.
    private val callback: ConnectivityManager.NetworkCallback =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            object : ConnectivityManager.NetworkCallback(
                ConnectivityManager.NetworkCallback.FLAG_INCLUDE_LOCATION_INFO,
            ) {
                override fun onCapabilitiesChanged(
                    network: Network,
                    capabilities: NetworkCapabilities,
                ) = onCaps(network, capabilities)

                override fun onLost(network: Network) = onNetworkLost(network)
            }
        } else {
            object : ConnectivityManager.NetworkCallback() {
                override fun onCapabilitiesChanged(
                    network: Network,
                    capabilities: NetworkCapabilities,
                ) = onCaps(network, capabilities)

                override fun onLost(network: Network) = onNetworkLost(network)
            }
        }

    private fun onCaps(network: Network, capabilities: NetworkCapabilities) {
        networks[network] = capabilities
        schedule()
    }

    private fun onNetworkLost(network: Network) {
        networks.remove(network)
        schedule()
    }

    fun start() {
        try {
            connectivity?.registerNetworkCallback(request, callback)
        } catch (e: Throwable) {
            GlobalState.log("NetworkRulesObserver register failed: $e")
        }
    }

    fun stop() {
        debounceJob?.cancel()
        scope.cancel()
        try {
            connectivity?.unregisterNetworkCallback(callback)
        } catch (_: Throwable) {
        }
    }

    private fun schedule() {
        debounceJob?.cancel()
        debounceJob = scope.launch {
            if (firstEmit) firstEmit = false else delay(DEBOUNCE_MS)
            emitIfChanged()
        }
    }

    private suspend fun emitIfChanged() {
        val best = bestNetwork()
        val snapshot = reader.read(best?.let { networks[it] })
        val key = NetworkSnapshotReader.networkKey(best)
        lock.withLock {
            if (snapshot == lastSnapshot && key == lastKey) return
            lastSnapshot = snapshot
            lastKey = key
        }
        onSnapshot(snapshot, key)
    }

    // WIFI > ETHERNET > CELLULAR; ties broken by insertion order.
    private fun bestNetwork(): Network? = networks.entries
        .maxByOrNull { transportRank(it.value) }
        ?.takeIf { transportRank(it.value) > 0 }
        ?.key

    private fun transportRank(capabilities: NetworkCapabilities): Int = when {
        capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> 3
        capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> 2
        capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> 1
        else -> 0
    }

    private companion object {
        const val DEBOUNCE_MS = 1500L
    }
}
