package com.follow.clash.service

import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.GlobalState
import com.follow.clash.common.sendBroadcast

interface IBaseService {
    var destroyed: Boolean

    fun handleCreate() {
        destroyed = false
        GlobalState.log("Service create")
        BroadcastAction.SERVICE_CREATED.sendBroadcast()
    }

    fun handleDestroy() {
        if (destroyed) return
        destroyed = true
        GlobalState.log("Service destroy")
        BroadcastAction.SERVICE_DESTROYED.sendBroadcast()
    }

    fun start()

    fun stop()
}
