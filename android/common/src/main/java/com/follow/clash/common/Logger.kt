package com.follow.clash.common

import android.util.Log
import org.json.JSONObject
import java.util.UUID

enum class LogLevel {
    DEBUG, INFO, WARNING, ERROR, SILENT;

    companion object {
        fun fromOrdinal(o: Int): LogLevel = entries.getOrElse(o) { INFO }
    }
}

// Always writes to logcat; `:remote` additionally forwards to Go for the
// canonical file. `:main` reaches the same file via Dart -> :remote.
object Logger {
    @Volatile
    private var remoteForward: ((Int, String, String) -> Unit)? = null

    fun installRemoteForward(forward: (level: Int, tag: String, payload: String) -> Unit) {
        remoteForward = forward
    }

    fun log(level: LogLevel, tag: String, msg: String) {
        when (level) {
            LogLevel.DEBUG -> Log.d(tag, msg)
            LogLevel.INFO -> Log.i(tag, msg)
            LogLevel.WARNING -> Log.w(tag, msg)
            LogLevel.ERROR -> Log.e(tag, msg)
            LogLevel.SILENT -> {}
        }
        remoteForward?.invoke(level.ordinal, tag, msg)
    }

    fun d(tag: String, msg: String) = log(LogLevel.DEBUG, tag, msg)
    fun i(tag: String, msg: String) = log(LogLevel.INFO, tag, msg)
    fun w(tag: String, msg: String) = log(LogLevel.WARNING, tag, msg)
    fun e(tag: String, msg: String) = log(LogLevel.ERROR, tag, msg)
}

// `data` is itself a JSON string — that's what action.go's parseStringData expects.
fun buildHostLogAction(level: Int, tag: String, payload: String): String {
    val params = JSONObject().apply {
        put("level", level)
        put("tag", tag)
        put("payload", payload)
    }
    return JSONObject().apply {
        put("id", "hostlog-${UUID.randomUUID()}")
        put("method", "forwardHostLog")
        put("data", params.toString())
    }.toString()
}
