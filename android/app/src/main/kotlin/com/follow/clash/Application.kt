package com.follow.clash

import android.app.Application
import android.content.Context
import com.follow.clash.common.GlobalState
import com.follow.clash.common.Logger
import com.follow.clash.common.buildHostLogAction
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class Application : Application() {

    private val logForwardScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
        Logger.installRemoteForward { level, tag, payload ->
            // :main has no libclash.so — forward over AIDL to :remote where the
            // cgo dispatcher and file sink live. Drop silently if not bound yet.
            logForwardScope.launch {
                runCatching {
                    Service.invokeAction(buildHostLogAction(level, tag, payload), null)
                }
            }
        }
    }
}
