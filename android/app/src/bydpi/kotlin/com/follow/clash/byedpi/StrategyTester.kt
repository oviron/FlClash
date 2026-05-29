package com.follow.clash.byedpi

import android.content.Context
import com.follow.clash.StrategyTestSink
import io.github.oviron.libbyedpi.ByeDpi
import io.github.oviron.libbyedpi.ByeDpiConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.coroutineContext
import org.json.JSONArray
import org.json.JSONObject

// App-process strategy tester (bydpi flavor only), invoked reflectively from
// ServicePlugin. Runs byedpi as a standalone SOCKS proxy on a dedicated test
// port — NO VpnService tun — so probes hit the raw network. The Dart caller
// guarantees the VPN is down first. Emits one JSON object per finished strategy
// through [StrategyTestSink]; the last carries done=true (or {"error":...}).
object StrategyTester {
    private const val TEST_PORT = 10800
    private const val STOP_TIMEOUT_MS = 3_000L

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    @Volatile
    private var job: Job? = null

    @JvmStatic
    fun start(context: Context, paramsJson: String, sink: StrategyTestSink) {
        job?.cancel()
        job = scope.launch {
            try {
                ByeDpi.load(context.applicationInfo.nativeLibraryDir)
                if (!ByeDpi.isLoaded()) {
                    sink.onProgress(
                        JSONObject().put("error", "byedpi failed to load").toString()
                    )
                    return@launch
                }
                runAll(JSONObject(paramsJson), sink)
            } catch (e: Throwable) {
                sink.onProgress(
                    JSONObject().put("error", e.message ?: "test failed").toString()
                )
            } finally {
                safeStopSuspend()
            }
        }
    }

    @JvmStatic
    fun stop() {
        job?.cancel()
        job = null
        if (ByeDpi.isLoaded()) {
            scope.launch { safeStopSuspend() }
        }
    }

    private class Cfg(
        val sites: List<String>,
        val requests: Int,
        val timeout: Long,
        val concurrency: Int,
    )

    private suspend fun runAll(params: JSONObject, sink: StrategyTestSink) {
        val strategies = params.getJSONArray("strategies")
        val sitesArr = params.getJSONArray("sites")
        val cfg = Cfg(
            sites = (0 until sitesArr.length()).map { sitesArr.getString(it) },
            requests = params.optInt("requests", 1).coerceAtLeast(1),
            timeout = params.optLong("timeout", 5L).coerceAtLeast(1L),
            concurrency = params.optInt("concurrency", 20).coerceAtLeast(1),
        )
        val total = strategies.length()
        val checker = SiteChecker(TEST_PORT)

        for (i in 0 until total) {
            if (!coroutineContext.isActive) break
            sink.onProgress(testOne(checker, strategies.getJSONObject(i), i, total, cfg))
        }
    }

    private suspend fun testOne(
        checker: SiteChecker,
        entry: JSONObject,
        index: Int,
        total: Int,
        cfg: Cfg,
    ): String {
        val id = entry.getString("id")
        val args = entry.optString("args", "")
        val argv = buildList {
            add("--port"); add(TEST_PORT.toString())
            if (args.isNotBlank()) addAll(args.trim().split(Regex("\\s+")))
        }
        var success = 0
        val siteResults = JSONArray()
        try {
            ByeDpi.restart(ByeDpiConfig(argv))
            checker.checkSites(cfg.sites, cfg.requests, cfg.timeout, cfg.concurrency) { site, ok, tot ->
                success += ok
                siteResults.put(JSONObject().put("site", site).put("ok", ok).put("total", tot))
            }
        } catch (_: Throwable) {
            // strategy failed to start / bind → counts as 0 successes
        }
        val totalRequests = cfg.sites.size * cfg.requests
        val percent = if (totalRequests > 0) success * 100 / totalRequests else 0
        return JSONObject()
            .put("index", index)
            .put("total", total)
            .put("id", id)
            .put("success", success)
            .put("totalRequests", totalRequests)
            .put("percent", percent)
            .put("sites", siteResults)
            .put("done", index == total - 1)
            .toString()
    }

    private suspend fun safeStopSuspend() {
        if (!ByeDpi.isLoaded()) return
        try {
            withTimeoutOrNull(STOP_TIMEOUT_MS) { ByeDpi.stop() }
        } catch (_: Throwable) {
        }
    }
}
