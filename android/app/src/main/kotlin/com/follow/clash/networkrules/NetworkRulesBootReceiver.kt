package com.follow.clash.networkrules

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.follow.clash.BOOT_ACTIONS

// Restarts the resident service after boot / app update, but only while the
// feature is enabled. Disabled by default; toggled by NetworkRulesManager.
class NetworkRulesBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in BOOT_ACTIONS) return
        if (NetworkRulesManager.isEnabled(context)) {
            NetworkRulesManager.start(context)
        }
    }
}
