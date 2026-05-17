package com.follow.clash.byedpi

import io.github.oviron.libbyedpi.ByeDpiConfig

/**
 * FlClash-domain config persisted by the user in the bypass settings UI.
 * Translated into a library-level [ByeDpiConfig] by [toByeDpiConfig]
 * before being handed to [io.github.oviron.libbyedpi.ByeDpi].
 */
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
