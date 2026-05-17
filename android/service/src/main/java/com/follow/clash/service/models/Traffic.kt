package com.follow.clash.service.models

import com.follow.clash.common.GlobalState
import com.follow.clash.common.formatBytes
import com.google.gson.Gson
import io.github.oviron.libmihomo.Clash

data class Traffic(
    val up: Long,
    val down: Long,
)

val Traffic.speedText: String
    get() = "${up.formatBytes}/s↑  ${down.formatBytes}/s↓"

fun Clash.getSpeedTrafficText(): String {
    try {
        val res = getTraffic()
        val traffic = Gson().fromJson(res, Traffic::class.java)
        return traffic.speedText
    } catch (e: Exception) {
        GlobalState.log(e.message + "")
        return ""
    }
}
