package com.follow.clash

import android.app.Activity
import android.os.Bundle
import com.follow.clash.common.QuickAction
import com.follow.clash.common.action

class TempActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            QuickAction.START.action -> State.request { handleStartServiceAction() }
            QuickAction.STOP.action -> State.request { handleStopServiceAction() }
            QuickAction.TOGGLE.action -> State.request { handleToggleAction() }
        }
        finish()
    }
}
