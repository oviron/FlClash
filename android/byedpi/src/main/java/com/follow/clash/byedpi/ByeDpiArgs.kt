package com.follow.clash.byedpi

data class ByeDpiConfig(
    val port: Int = 1080,
    val cliArgs: String = "",
    val hostsFilePath: String? = null,
)

object ByeDpiArgs {
    fun build(config: ByeDpiConfig): List<String> = buildList {
        add("ciadpi")
        add("--port"); add(config.port.toString())
        config.hostsFilePath?.let { path ->
            add("--hosts"); add(path)
        }
        if (config.cliArgs.isNotBlank()) {
            addAll(config.cliArgs.trim().split(Regex("\\s+")))
        }
    }
}
