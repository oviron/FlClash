package com.follow.clash.common

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.flow.onStart

// Emits params whenever a visible notification refresh is due. The ticker only
// runs while the screen is on — with it off nobody can read the traffic text,
// and an always-on 2s tick kept waking the service process all night. A single
// onStart emission still guarantees the initial startForeground update, and a
// params change (start/stop, profile switch) refreshes even with the screen off.
@OptIn(ExperimentalCoroutinesApi::class)
fun <P : Any> notificationRefreshFlow(
    screenOn: Flow<Boolean>,
    params: Flow<P?>,
    tickMillis: Long,
): Flow<P> {
    val ticks = screenOn
        .distinctUntilChanged()
        .flatMapLatest { on ->
            if (on) tickerFlow(tickMillis, 0) else emptyFlow()
        }
        .onStart { emit(Unit) }
    return combine(ticks, params) { _, p -> p }.mapNotNull { it }
}
