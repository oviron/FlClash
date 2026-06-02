package com.follow.clash.networkrules

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// Restarts the resident service after boot / app update, but only while the
// feature is enabled. Disabled by default; toggled by NetworkRulesManager.
class NetworkRulesBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                if (NetworkRulesManager.isEnabled(context)) {
                    NetworkRulesManager.start(context)
                }
            }
        }
    }
}
