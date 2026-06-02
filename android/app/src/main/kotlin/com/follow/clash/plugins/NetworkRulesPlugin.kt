package com.follow.clash.plugins

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.networkrules.NetworkRulesController
import com.follow.clash.networkrules.NetworkRulesManager
import com.follow.clash.networkrules.NetworkRulesStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// Method names mirrored in lib/plugins/method_names.dart; renames must land in
// the same PR as the Dart side or the bridge silently breaks.
private object NetworkRulesMethod {
    const val SET_ENABLED = "setEnabled"
    const val GET_STATUS = "getStatus"
    const val REEVALUATE = "reevaluate"
    const val STATUS_CHANGED = "statusChanged"
}

class NetworkRulesPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var applicationContext: Context
    private lateinit var channel: MethodChannel
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(
            binding.binaryMessenger,
            "${Components.PACKAGE_NAME}/network_rules",
        )
        channel.setMethodCallHandler(this)
        NetworkRulesController.statusListener = { pushStatus(it) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        NetworkRulesController.statusListener = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            NetworkRulesMethod.SET_ENABLED -> {
                val enabled = call.arguments as? Boolean ?: false
                if (enabled) {
                    NetworkRulesManager.start(applicationContext)
                } else {
                    NetworkRulesManager.stop(applicationContext)
                }
                result.success(true)
            }

            NetworkRulesMethod.GET_STATUS -> result.success(
                NetworkRulesController.status?.let { encode(it) },
            )

            NetworkRulesMethod.REEVALUATE -> {
                NetworkRulesController.reevaluate()
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun pushStatus(status: NetworkRulesStatus) {
        mainHandler.post {
            try {
                channel.invokeMethod(NetworkRulesMethod.STATUS_CHANGED, encode(status))
            } catch (e: Throwable) {
                GlobalState.log("NetworkRulesPlugin push failed: $e")
            }
        }
    }

    private fun encode(status: NetworkRulesStatus): Map<String, Any?> = mapOf(
        "type" to status.type.name,
        "ssid" to status.ssid,
        "decision" to status.decision.name,
        "reason" to status.reason,
        "overridden" to status.overridden,
    )
}
