package com.follow.clash.byedpi

import android.content.Context
import android.content.SharedPreferences

class ByeDpiState(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("byedpi", Context.MODE_PRIVATE)

    val enabled: Boolean get() = prefs.getBoolean(KEY_ENABLED, false)
    val port: Int get() = prefs.getInt(KEY_PORT, 1080)
    val cliArgs: String get() = prefs.getString(KEY_CLI_ARGS, "") ?: ""

    fun toConfig() = ByeDpiConfig(port = port, cliArgs = cliArgs)

    companion object {
        const val KEY_ENABLED = "byedpi_enabled"
        const val KEY_PORT = "byedpi_port"
        const val KEY_CLI_ARGS = "byedpi_cli_args"
    }
}
