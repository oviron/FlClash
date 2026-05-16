package com.follow.clash.byedpi

import android.content.Context
import com.follow.clash.common.modules.Module
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeoutOrNull
import java.io.File
import java.time.LocalTime
import java.time.format.DateTimeFormatter

class ByeDpiModule(private val context: Context) : Module() {
    private val state = ByeDpiState(context)
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val mutex = Mutex()
    private var job: Job? = null

    override fun onInstall() {
        currentRef = this
        startByeDpi()
    }

    override fun onUninstall() {
        stopByeDpi()
        scope.cancel()
        currentRef = null
    }

    private fun startByeDpi() {
        val config = state.read() ?: run {
            trace("startByeDpi: config=null, skipping")
            return
        }
        val args = ByeDpiArgs.build(config)
        trace("startByeDpi argv: ${args.joinToString(" ")}")
        job = scope.launch {
            val rc = ByeDpiProxy.start(args)
            trace("byedpi exited rc=$rc")
        }
    }

    private fun stopByeDpi() {
        ByeDpiProxy.stop()
        val joined = runBlocking {
            withTimeoutOrNull(STOP_JOIN_TIMEOUT_MS) { job?.join() }
        }
        if (joined == null) {
            trace("stopByeDpi: join timed out — forceClose")
            ByeDpiProxy.forceClose()
            runBlocking {
                withTimeoutOrNull(STOP_FORCE_TIMEOUT_MS) { job?.join() }
            }
        }
        job = null
    }

    fun restartFromUi(): Boolean = runBlocking {
        if (!mutex.tryLock()) {
            trace("restartFromUi: already in progress")
            return@runBlocking false
        }
        try {
            trace("restartFromUi: stop + reload")
            stopByeDpi()
            startByeDpi()
            true
        } finally {
            mutex.unlock()
        }
    }

    private fun trace(line: String) {
        try {
            val dir = context.getExternalFilesDir(null) ?: return
            val file = File(dir, "byedpi-trace.log")
            val ts = LocalTime.now().format(TRACE_TS)
            synchronized(TRACE_LOCK) {
                if (file.length() > TRACE_MAX_BYTES) file.writeText("")
                file.appendText("$ts $line\n")
            }
        } catch (_: Throwable) {}
    }

    companion object {
        @Volatile
        private var currentRef: ByeDpiModule? = null

        private val TRACE_TS = DateTimeFormatter.ofPattern("HH:mm:ss.SSS")
        private val TRACE_LOCK = Any()
        private const val TRACE_MAX_BYTES = 256L * 1024L
        private const val STOP_JOIN_TIMEOUT_MS = 3_000L
        private const val STOP_FORCE_TIMEOUT_MS = 1_000L

        @JvmStatic
        fun restartCurrent(): Boolean {
            val ref = currentRef ?: return false
            return ref.restartFromUi()
        }
    }
}
