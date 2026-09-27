package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent


// Fast-boot firmware (Xiaomi, HTC and others) can skip BOOT_COMPLETED and send QUICKBOOT_POWERON instead.
val BOOT_ACTIONS = setOf(
    Intent.ACTION_BOOT_COMPLETED,
    Intent.ACTION_MY_PACKAGE_REPLACED,
    "android.intent.action.QUICKBOOT_POWERON",
    "com.htc.intent.action.QUICKBOOT_POWERON",
)

class AutoStartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in BOOT_ACTIONS) return
        State.request { handleStartServiceAction() }
    }
}
