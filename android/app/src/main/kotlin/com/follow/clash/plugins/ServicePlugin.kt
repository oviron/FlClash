package com.follow.clash.plugins

import com.follow.clash.RunState
import com.follow.clash.Service
import com.follow.clash.State
import com.follow.clash.common.Components
import com.follow.clash.invokeMethodOnMainThread
import com.follow.clash.models.SharedState
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit

// Method-name constants — mirrored on the Dart side in
// lib/plugins/method_names.dart. Renames here MUST land in the same PR
// as the Dart-side rename, or the bridge silently breaks.
private object ServiceMethod {
    const val INIT = "init"
    const val SHUTDOWN = "shutdown"
    const val INVOKE_ACTION = "invokeAction"
    const val GET_RUN_TIME = "getRunTime"
    const val SYNC_STATE = "syncState"
    const val START = "start"
    const val STOP = "stop"
    const val RESTART_BYEDPI = "restartByeDpi"
    const val EVENT = "event"
    const val CRASH = "crash"
}

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    private lateinit var flutterMethodChannel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        ServiceMethod.INIT -> handleInit(result)
        ServiceMethod.SHUTDOWN -> handleShutdown(result)
        ServiceMethod.INVOKE_ACTION -> handleInvokeAction(call, result)
        ServiceMethod.GET_RUN_TIME -> handleGetRunTime(result)
        ServiceMethod.SYNC_STATE -> handleSyncState(call, result)
        ServiceMethod.START -> handleStart(result)
        ServiceMethod.STOP -> handleStop(result)
        ServiceMethod.RESTART_BYEDPI -> handleRestartByeDpi(result)
        else -> result.notImplemented()
    }

    private fun handleRestartByeDpi(result: MethodChannel.Result) {
        launch {
            val ok = Service.restartByeDpi()
            launch(Dispatchers.Main) { result.success(ok) }
        }
    }

    private fun handleInvokeAction(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments<String>()
        if (data == null) {
            result.error("NULL_ARG", "invokeAction expects a String payload", null)
            return
        }
        launch {
            Service.invokeAction(data) {
                result.success(it)
            }
        }
    }

    private fun handleShutdown(result: MethodChannel.Result) {
        Service.unbind()
        result.success(true)
    }

    private fun handleStart(result: MethodChannel.Result) {
        State.handleStartService()
        result.success(true)
    }

    private fun handleStop(result: MethodChannel.Result) {
        State.handleStopService()
        result.success(true)
    }

    val semaphore = Semaphore(10)

    fun handleSendEvent(value: String?) {
        launch(Dispatchers.Main) {
            semaphore.withPermit {
                flutterMethodChannel.invokeMethod(ServiceMethod.EVENT, value)
            }
        }
    }

    private fun onServiceDisconnected(message: String) {
        State.runStateFlow.tryEmit(RunState.STOP)
        flutterMethodChannel.invokeMethodOnMainThread<Any>(ServiceMethod.CRASH, message)
    }

    private fun handleSyncState(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments<String>()
        if (data == null) {
            result.error("NULL_ARG", "syncState expects a String payload", null)
            return
        }
        State.sharedState = Gson().fromJson(data, SharedState::class.java)
        launch {
            State.syncState()
            result.success("")
        }
    }


    fun handleInit(result: MethodChannel.Result) {
        Service.bind()
        launch {
            Service.setEventListener {
                handleSendEvent(it)
            }.onSuccess {
                result.success("")
            }.onFailure {
                result.success(it.message)
            }

        }
        Service.onServiceDisconnected = ::onServiceDisconnected
    }

    private fun handleGetRunTime(result: MethodChannel.Result) {
        launch {
            State.handleSyncState()
            result.success(State.runTime)
        }
    }
}
