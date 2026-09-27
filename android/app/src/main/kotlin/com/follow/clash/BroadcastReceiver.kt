package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.EXTRA_RUN_TIME
import com.follow.clash.common.GlobalState
import com.follow.clash.common.action

class BroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            BroadcastAction.SERVICE_CREATED.action -> {
                GlobalState.log("Receiver service created")
                State.request { handleStartServiceAction() }
            }

            BroadcastAction.SERVICE_DESTROYED.action -> {
                GlobalState.log("Receiver service destroyed")
                // Revoked: even a report the session check drops must not leave recovery armed.
                RecoveryJob.cancel()
                val session = intent.getLongExtra(EXTRA_RUN_TIME, 0L)
                State.request { handleStopServiceAction(session = session) }
            }
        }
    }
}
