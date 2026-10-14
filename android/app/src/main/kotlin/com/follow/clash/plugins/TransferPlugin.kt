package com.follow.clash.plugins

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.follow.clash.common.Components
import com.follow.clash.transfer.ExportActivity
import com.follow.clash.transfer.Siblings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

// Method names mirrored in lib/plugins/method_names.dart.
private object TransferMethod {
    const val SIBLING = "sibling"
    const val PULL = "pull"
}

// Fetches the other local build's data archive (see transfer/ExportActivity.kt).
class TransferPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var applicationContext: Context
    private lateinit var channel: MethodChannel
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var binding: ActivityPluginBinding? = null
    private var pending: Pair<String, MethodChannel.Result>? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/transfer")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            TransferMethod.SIBLING -> result.success(
                Siblings.find(applicationContext)?.let { Siblings.label(applicationContext, it) },
            )

            TransferMethod.PULL -> pull(call.arguments as String, result)
            else -> result.notImplemented()
        }
    }

    private fun pull(path: String, result: MethodChannel.Result) {
        val activity = binding?.activity
        val sibling = Siblings.find(applicationContext)
        if (activity == null || sibling == null || pending != null) {
            result.success(false)
            return
        }
        pending = path to result
        activity.startActivityForResult(
            Intent(Siblings.ACTION_EXPORT).setPackage(sibling),
            REQUEST_CODE,
        )
    }

    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val (path, result) = pending ?: return true
        pending = null
        val uri = data?.data
        when {
            resultCode == Activity.RESULT_OK && uri != null -> scope.launch {
                runCatching {
                    withContext(Dispatchers.IO) {
                        val resolver = applicationContext.contentResolver
                        resolver.openInputStream(uri)!!.use { input ->
                            File(path).outputStream().use { input.copyTo(it) }
                        }
                        runCatching { resolver.delete(uri, null, null) }
                    }
                }.fold(
                    onSuccess = { result.success(true) },
                    onFailure = { result.error("transfer", it.toString(), null) },
                )
            }

            resultCode == Activity.RESULT_FIRST_USER -> result.error(
                "transfer",
                data?.getStringExtra(ExportActivity.EXTRA_ERROR),
                null,
            )

            else -> result.success(false)
        }
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(::onActivityResult)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        binding = null
        pending?.second?.success(false)
        pending = null
    }

    private companion object {
        const val REQUEST_CODE = 1101
    }
}
