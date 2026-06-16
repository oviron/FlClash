package com.follow.clash.plugins

import android.content.Context
import android.os.Build
import com.follow.clash.AarInstaller
import com.follow.clash.BuildConfig
import com.follow.clash.common.ActiveLibs
import com.follow.clash.common.Components
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.github.oviron.libmihomo.Clash
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

// Method-name constants — mirrored on the Dart side in lib/plugins/method_names.dart
// (LibraryMethod). Renames here MUST land in the same PR as the Dart-side rename.
private object LibraryMethod {
    const val EXPECTED_BRIDGE_ABI = "expectedBridgeAbi"
    const val BUNDLED_VERSIONS = "bundledVersions"
    const val DEVICE_ABI = "deviceAbi"
    const val LIST_INSTALLED = "listInstalled"
    const val ACTIVE_DIRS = "activeDirs"
    const val INSTALL_FROM_AAR = "installFromAar"
    const val SET_ACTIVE = "setActive"
    const val CLEAR_ACTIVE = "clearActive"
    const val DELETE_INSTALLED = "deleteInstalled"
}

class LibraryPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var applicationContext: Context
    private lateinit var channel: MethodChannel
    private lateinit var scope: CoroutineScope

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
        channel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/library")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            LibraryMethod.EXPECTED_BRIDGE_ABI -> result.success(
                mapOf(
                    ActiveLibs.MIHOMO to Clash.EXPECTED_BRIDGE_ABI,
                )
            )

            LibraryMethod.BUNDLED_VERSIONS -> result.success(bundledVersions())

            LibraryMethod.DEVICE_ABI ->
                result.success(Build.SUPPORTED_ABIS.firstOrNull() ?: "")

            LibraryMethod.LIST_INSTALLED -> result.success(listInstalled())

            LibraryMethod.ACTIVE_DIRS -> result.success(
                mapOf(
                    ActiveLibs.MIHOMO to
                        ActiveLibs.dirFor(applicationContext, ActiveLibs.MIHOMO, ActiveLibs.MIHOMO_SO),
                )
            )

            LibraryMethod.SET_ACTIVE -> {
                ActiveLibs.setActive(
                    applicationContext,
                    call.argument<String>("label")!!,
                    call.argument<String>("dir"),
                )
                result.success(true)
            }

            LibraryMethod.CLEAR_ACTIVE -> {
                ActiveLibs.setActive(applicationContext, call.argument<String>("label")!!, null)
                result.success(true)
            }

            LibraryMethod.INSTALL_FROM_AAR -> handleInstall(call, result)

            LibraryMethod.DELETE_INSTALLED -> {
                val ok = runCatching { File(call.argument<String>("dir")!!).deleteRecursively() }
                    .getOrDefault(false)
                result.success(ok)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleInstall(call: MethodCall, result: Result) {
        val aarPath = call.argument<String>("aarPath")!!
        val ascPath = call.argument<String>("ascPath")!!
        val sha = call.argument<String>("sha256")!!
        val label = call.argument<String>("label")!!
        val version = call.argument<String>("version")!!
        scope.launch {
            try {
                val abi = Build.SUPPORTED_ABIS.firstOrNull() ?: error("no supported ABI")
                val requiredSo = ActiveLibs.MIHOMO_SO
                val dir = AarInstaller.install(
                    applicationContext, File(aarPath), File(ascPath), sha, abi, requiredSo,
                    "$label-v$version",
                )
                withContext(Dispatchers.Main) { result.success(dir.absolutePath) }
            } catch (e: Throwable) {
                withContext(Dispatchers.Main) { result.error("install_failed", e.message, null) }
            }
        }
    }

    private fun listInstalled(): List<Map<String, Any>> {
        val root = File(applicationContext.filesDir, "libs")
        if (!root.isDirectory) return emptyList()
        return root.listFiles { f -> f.isDirectory && !f.name.endsWith(".tmp") }
            ?.mapNotNull { d ->
                val sep = d.name.indexOf("-v")
                if (sep <= 0) return@mapNotNull null
                mapOf(
                    "label" to d.name.substring(0, sep),
                    "version" to d.name.substring(sep + 2),
                    "dir" to d.absolutePath,
                    "sizeBytes" to d.walkTopDown().filter { it.isFile }.map { it.length() }.sum(),
                )
            } ?: emptyList()
    }

    private fun bundledVersions(): Map<String, String> = buildMap {
        put(ActiveLibs.MIHOMO, BuildConfig.BUNDLED_MIHOMO_VERSION)
    }
}
