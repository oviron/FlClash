package com.follow.clash.networkrules

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.follow.clash.common.GlobalState
import com.follow.clash.common.networkrules.NetworkRulesCodec
import java.io.File

// Lifecycle entry points shared by the plugin (UI toggle) and the boot
// receiver. The feature is "on" iff the master toggle is on in the mirror.
object NetworkRulesManager {

    fun isEnabled(context: Context): Boolean {
        val file = File(context.applicationContext.filesDir, "network-rules.json")
        if (!file.exists()) return false
        return try {
            NetworkRulesCodec.parse(file.readText()).enabled
        } catch (_: Throwable) {
            false
        }
    }

    fun start(context: Context) {
        val app = context.applicationContext
        setBootReceiverEnabled(app, true)
        val intent = Intent(app, NetworkRulesService::class.java)
        try {
            ContextCompat.startForegroundService(app, intent)
        } catch (e: Throwable) {
            // Android 16 can reject a specialUse FGS start from a BOOT_COMPLETED
            // receiver. Degrade to a normal start instead of crashing; the
            // service promotes itself in onCreate via startForegroundCompat.
            GlobalState.log("network-rules FGS start failed, falling back: $e")
            try {
                app.startService(intent)
            } catch (e2: Throwable) {
                GlobalState.log("network-rules service start failed: $e2")
            }
        }
    }

    fun stop(context: Context) {
        val app = context.applicationContext
        setBootReceiverEnabled(app, false)
        app.stopService(Intent(app, NetworkRulesService::class.java))
    }

    private fun setBootReceiverEnabled(context: Context, enabled: Boolean) {
        val state = if (enabled) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        } else {
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }
        context.packageManager.setComponentEnabledSetting(
            ComponentName(context, NetworkRulesBootReceiver::class.java),
            state,
            PackageManager.DONT_KILL_APP,
        )
    }
}
