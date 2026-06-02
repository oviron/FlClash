package com.follow.clash.plugins

import android.content.Context
import com.follow.clash.RunState
import com.follow.clash.Service
import com.follow.clash.State
import com.follow.clash.StrategyTestSink
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
    const val START_STRATEGY_TEST = "startStrategyTest"
    const val STOP_STRATEGY_TEST = "stopStrategyTest"
    const val REQUEST_STOP = "requestStop"
    const val EVENT = "event"
    const val CRASH = "crash"
    const val STRATEGY_TEST_PROGRESS = "strategyTestProgress"
}

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    private lateinit var flutterMethodChannel: MethodChannel
    private var appContext: Context? = null
    @Volatile
    private var attached = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext
        attached = true
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        attached = false
        appContext = null
        flutterMethodChannel.setMethodCallHandler(null)
    }

    private fun launchAttachedMain(action: suspend () -> Unit) {
        launch(Dispatchers.Main) {
            if (attached) action()
        }
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
        ServiceMethod.START_STRATEGY_TEST -> handleStartStrategyTest(call, result)
        ServiceMethod.STOP_STRATEGY_TEST -> handleStopStrategyTest(result)
        ServiceMethod.REQUEST_STOP -> handleRequestStop(result)
        else -> result.notImplemented()
    }

    // bydpi flavor only: StrategyTester is loaded reflectively (classic has no
    // libbyedpi). Progress streams back over STRATEGY_TEST_PROGRESS.
    private fun handleStartStrategyTest(call: MethodCall, result: MethodChannel.Result) {
        val params = call.arguments<String>()
        val ctx = appContext
        if (params == null || ctx == null) {
            result.error("NULL_ARG", "startStrategyTest expects a String payload", null)
            return
        }
        val sink = StrategyTestSink { json ->
            launchAttachedMain {
                flutterMethodChannel.invokeMethod(ServiceMethod.STRATEGY_TEST_PROGRESS, json)
            }
        }
        try {
            Class.forName("com.follow.clash.byedpi.StrategyTester")
                .getDeclaredMethod(
                    "start", Context::class.java, String::class.java, StrategyTestSink::class.java
                )
                .invoke(null, ctx, params, sink)
            result.success(true)
        } catch (e: Throwable) {
            result.error("TEST", e.message ?: "strategy test unavailable", null)
        }
    }

    private fun handleStopStrategyTest(result: MethodChannel.Result) {
        launch {
            try {
                Class.forName("com.follow.clash.byedpi.StrategyTester")
                    .getDeclaredMethod("stopAndWait")
                    .invoke(null)
            } catch (_: Throwable) {
            }
            launchAttachedMain { result.success(true) }
        }
    }

    private fun handleRestartByeDpi(result: MethodChannel.Result) {
        launch {
            val ok = Service.restartByeDpi()
            launchAttachedMain { result.success(ok) }
        }
    }

    private fun handleRequestStop(result: MethodChannel.Result) {
        launch {
            Service.requestStop()
            launchAttachedMain { result.success(true) }
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
                launchAttachedMain { result.success(it) }
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
        launchAttachedMain {
            semaphore.withPermit {
                flutterMethodChannel.invokeMethod(ServiceMethod.EVENT, value)
            }
        }
    }

    private fun onServiceDisconnected(message: String) {
        State.runStateFlow.tryEmit(RunState.STOP)
        if (attached) {
            flutterMethodChannel.invokeMethodOnMainThread<Any>(ServiceMethod.CRASH, message)
        }
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
            launchAttachedMain { result.success("") }
        }
    }


    fun handleInit(result: MethodChannel.Result) {
        Service.bind()
        launch {
            Service.setEventListener {
                handleSendEvent(it)
            }.onSuccess {
                launchAttachedMain { result.success("") }
            }.onFailure {
                launchAttachedMain { result.success(it.message) }
            }
        }
        Service.onServiceDisconnected = ::onServiceDisconnected
    }

    private fun handleGetRunTime(result: MethodChannel.Result) {
        launch {
            State.handleSyncState()
            launchAttachedMain { result.success(State.runTime) }
        }
    }
}
