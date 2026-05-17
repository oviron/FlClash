package com.follow.clash.byedpi

import android.content.Context
import org.json.JSONObject
import java.io.File

class ByeDpiState(context: Context) {
    private val file = File(context.filesDir, "byedpi-runtime.json")

    fun read(): BypassConfig? {
        if (!file.exists()) return null
        return try {
            val json = JSONObject(file.readText())
            if (!json.optBoolean("enabled", false)) return null
            BypassConfig(
                port = json.optInt("port", 1080),
                cliArgs = json.optString("cliArgs", ""),
                hostsFilePath = json.optString("hostsFile", "").takeIf { it.isNotEmpty() },
            )
        } catch (_: Exception) {
            null
        }
    }
}
