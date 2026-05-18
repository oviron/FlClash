package com.follow.clash.byedpi

import android.content.Context
import com.follow.clash.common.modules.Module
import io.github.oviron.libbyedpi.ByeDpi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.withTimeoutOrNull
import java.io.File
import java.time.LocalTime
import java.time.format.DateTimeFormatter

class ByeDpiModule(private val context: Context) : Module() {
    private val state = ByeDpiState(context)
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val restartMutex = Mutex()

    override suspend fun onInstallSuspend() {
        currentRef = this
        ByeDpi.load(context.applicationInfo.nativeLibraryDir)
        startByeDpiSuspend()
    }

    override fun onUninstall() {
        runBlocking {
            withTimeoutOrNull(STOP_TIMEOUT_MS) { ByeDpi.stop() }
                ?: run {
                    trace("stop timed out, forceClose")
                    ByeDpi.forceClose()
                    withTimeoutOrNull(STOP_FORCE_TIMEOUT_MS) { ByeDpi.stop() }
                }
        }
        scope.cancel()
        currentRef = null
    }

    private suspend fun startByeDpiSuspend() {
        val bypass = state.read() ?: run {
            trace("startByeDpi: bypass config disabled, skipping")
            return
        }
        val config = bypass.toByeDpiConfig()
        trace("startByeDpi argv: ${config.args.joinToString(" ")}")
        // mihomo's TUN starts immediately after we return; block here until
        // byedpi listener is bound so the anti-loop invariant holds.
        try {
            withTimeoutOrNull(START_TIMEOUT_MS) { ByeDpi.start(config) }
                ?: trace("byedpi start timed out after ${START_TIMEOUT_MS}ms")
            trace("byedpi state=${ByeDpi.state.value::class.simpleName}")
        } catch (e: Throwable) {
            trace("byedpi start failed: ${e.message}")
        }
    }

    // Called from AIDL Binder thread via Class.forName / getDeclaredMethod
    // reflection. runBlocking here is unavoidable (Binder transact is sync);
    // restartMutex.tryLock prevents UI double-tap races.
    fun restartFromUi(): Boolean = runBlocking {
        if (!restartMutex.tryLock()) {
            trace("restartFromUi: already in progress")
            return@runBlocking false
        }
        try {
            val bypass = state.read() ?: run {
                trace("restartFromUi: bypass config disabled, stopping")
                withTimeoutOrNull(STOP_TIMEOUT_MS) { ByeDpi.stop() }
                return@runBlocking true
            }
            val config = bypass.toByeDpiConfig()
            trace("restartFromUi argv: ${config.args.joinToString(" ")}")
            try {
                ByeDpi.restart(config)
                trace("byedpi restarted")
                true
            } catch (e: Throwable) {
                trace("restart failed: ${e.message}")
                false
            }
        } finally {
            restartMutex.unlock()
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
        } catch (_: Throwable) {
        }
    }

    companion object {
        @Volatile
        private var currentRef: ByeDpiModule? = null

        private val TRACE_TS = DateTimeFormatter.ofPattern("HH:mm:ss.SSS")
        private val TRACE_LOCK = Any()
        private const val TRACE_MAX_BYTES = 256L * 1024L
        private const val START_TIMEOUT_MS = 6_000L
        private const val STOP_TIMEOUT_MS = 3_000L
        private const val STOP_FORCE_TIMEOUT_MS = 1_000L

        @JvmStatic
        fun restartCurrent(): Boolean {
            val ref = currentRef ?: return false
            return ref.restartFromUi()
        }
    }
}
