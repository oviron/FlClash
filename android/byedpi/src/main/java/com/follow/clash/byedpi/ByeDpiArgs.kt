package com.follow.clash.byedpi

data class ByeDpiConfig(val port: Int = 1080, val cliArgs: String = "")

object ByeDpiArgs {
    fun build(config: ByeDpiConfig): List<String> = buildList {
        add("ciadpi")
        add("--port"); add(config.port.toString())
        if (config.cliArgs.isNotBlank()) {
            addAll(config.cliArgs.trim().split(Regex("\\s+")))
        }
    }
}
