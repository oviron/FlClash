package com.follow.clash.byedpi

import io.github.oviron.libbyedpi.ByeDpiConfig

data class BypassConfig(
    val port: Int = 1080,
    val cliArgs: String = "",
    val hostsFilePath: String? = null,
) {
    fun toByeDpiConfig(): ByeDpiConfig = ByeDpiConfig(buildList {
        add("--port"); add(port.toString())
        hostsFilePath?.let { path ->
            add("--hosts"); add(path)
        }
        if (cliArgs.isNotBlank()) {
            addAll(cliArgs.trim().split(Regex("\\s+")))
        }
    })
}
