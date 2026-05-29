package com.follow.clash.byedpi

import android.content.Context
import com.follow.clash.StrategyTestSink
import io.github.oviron.libbyedpi.ByeDpi
import io.github.oviron.libbyedpi.ByeDpiConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
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
        stop()
        job = scope.launch {
            try {
                ByeDpi.load(context.applicationInfo.nativeLibraryDir)
                val params = JSONObject(paramsJson)
                val strategies = params.getJSONArray("strategies")
                val sitesArr = params.getJSONArray("sites")
                val sites = (0 until sitesArr.length()).map { sitesArr.getString(it) }
                val requests = params.optInt("requests", 1).coerceAtLeast(1)
                val timeout = params.optLong("timeout", 5L).coerceAtLeast(1L)
                val concurrency = params.optInt("concurrency", 20).coerceAtLeast(1)
                val total = strategies.length()
                val checker = SiteChecker(TEST_PORT)

                for (i in 0 until total) {
                    if (!isActive) break
                    val entry = strategies.getJSONObject(i)
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
                        checker.checkSites(sites, requests, timeout, concurrency) { site, ok, tot ->
                            success += ok
                            siteResults.put(
                                JSONObject().put("site", site).put("ok", ok).put("total", tot)
                            )
                        }
                    } catch (_: Throwable) {
                        // strategy failed to start / bind → counts as 0 successes
                    }
                    val totalRequests = sites.size * requests
                    val percent = if (totalRequests > 0) success * 100 / totalRequests else 0
                    sink.onProgress(
                        JSONObject()
                            .put("index", i)
                            .put("total", total)
                            .put("id", id)
                            .put("success", success)
                            .put("totalRequests", totalRequests)
                            .put("percent", percent)
                            .put("sites", siteResults)
                            .put("done", i == total - 1)
                            .toString()
                    )
                }
            } catch (e: Throwable) {
                sink.onProgress(JSONObject().put("error", e.message ?: "test failed").toString())
            } finally {
                withTimeoutOrNull(STOP_TIMEOUT_MS) { ByeDpi.stop() }
            }
        }
    }

    @JvmStatic
    fun stop() {
        job?.cancel()
        job = null
        scope.launch { withTimeoutOrNull(STOP_TIMEOUT_MS) { ByeDpi.stop() } }
    }
}
