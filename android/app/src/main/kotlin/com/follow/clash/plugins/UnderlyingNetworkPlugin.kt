package com.follow.clash.plugins

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import androidx.core.content.getSystemService
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

// NOT_VPN-filtered callback so we catch Wi-Fi/cellular flips while the
// VPN itself stays the default network (connectivity_plus misses them).
class UnderlyingNetworkPlugin : FlutterPlugin {
    private lateinit var applicationContext: Context
    private lateinit var channel: MethodChannel
    private val mainHandler = Handler(Looper.getMainLooper())

    private val connectivity by lazy {
        applicationContext.getSystemService<ConnectivityManager>()
    }

    private val request = NetworkRequest.Builder()
        .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        .build()

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            notifyDart("available")
        }

        override fun onLost(network: Network) {
            notifyDart("lost")
        }

        override fun onCapabilitiesChanged(
            network: Network,
            capabilities: NetworkCapabilities
        ) {
            notifyDart("capabilities")
        }
    }

    private fun notifyDart(reason: String) {
        mainHandler.post {
            try {
                channel.invokeMethod("underlyingChanged", reason)
            } catch (e: Throwable) {
                GlobalState.log("UnderlyingNetworkPlugin invoke failed: $e")
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(
            binding.binaryMessenger,
            "${Components.PACKAGE_NAME}/underlying_network"
        )
        try {
            connectivity?.registerNetworkCallback(request, callback)
        } catch (e: Throwable) {
            GlobalState.log("UnderlyingNetworkPlugin register failed: $e")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            connectivity?.unregisterNetworkCallback(callback)
        } catch (_: Throwable) {
        }
    }
}
