package com.follow.clash.service

import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.EXTRA_RUN_TIME
import com.follow.clash.common.GlobalState
import com.follow.clash.common.sendBroadcast

// The app hears only about transitions it did not ask for (always-on start, revoke):
// it already has the reply for the ones it did, and a late broadcast about those
// would undo whatever the user did next.
interface IBaseService {
    var destroyed: Boolean

    fun handleCreate() {
        destroyed = false
        GlobalState.log("Service create")
        if (!State.starting) BroadcastAction.SERVICE_CREATED.sendBroadcast()
    }

    fun handleDestroy(requested: Boolean = false) {
        if (destroyed) return
        destroyed = true
        GlobalState.log("Service destroy")
        if (requested) return
        BroadcastAction.SERVICE_DESTROYED.sendBroadcast {
            putExtra(EXTRA_RUN_TIME, State.runTime)
        }
    }

    suspend fun start(): Boolean

    fun stop()
}
