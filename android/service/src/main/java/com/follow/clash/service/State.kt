package com.follow.clash.service

import com.follow.clash.common.ServiceDelegate
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow

object State {
    @Volatile
    var options: VpnOptions? = null
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )

    @Volatile
    var runTime: Long = 0L

    // True while RemoteService brings a service up itself; anything else that creates one is the system.
    @Volatile
    var starting = false

    var delegate: ServiceDelegate<IBaseService>? = null
}
