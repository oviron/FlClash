package com.follow.clash.byedpi

import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.URL

// Port of romanvht/ByeByeDPI SiteCheckUtils: probe each site through the local
// SOCKS proxy. Success = a response arrives AND the body is not truncated — a
// cut body (actual < declared Content-Length) signals a mid-stream RST/block.
class SiteChecker(proxyPort: Int) {
    private val proxy = Proxy(Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", proxyPort))

    suspend fun checkSites(
        sites: List<String>,
        requestsPerSite: Int,
        timeoutSec: Long,
        concurrency: Int,
        onSite: (site: String, success: Int, total: Int) -> Unit,
    ): Unit = withContext(Dispatchers.IO) {
        val sem = Semaphore(concurrency.coerceAtLeast(1))
        sites.map { site ->
            async {
                sem.withPermit {
                    val ok = checkSite(site, requestsPerSite, timeoutSec)
                    onSite(site, ok, requestsPerSite)
                }
            }
        }.awaitAll()
    }

    private fun checkSite(site: String, requests: Int, timeoutSec: Long): Int {
        val url = try {
            URL(if (site.startsWith("http://") || site.startsWith("https://")) site else "https://$site")
        } catch (_: Exception) {
            return 0
        }
        var ok = 0
        repeat(requests) {
            var conn: HttpURLConnection? = null
            try {
                conn = (url.openConnection(proxy) as HttpURLConnection).apply {
                    connectTimeout = (timeoutSec * 1000).toInt()
                    readTimeout = (timeoutSec * 1000).toInt()
                    instanceFollowRedirects = true
                    setRequestProperty("Connection", "close")
                }
                val code = conn.responseCode
                val declared = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    conn.contentLengthLong
                } else {
                    conn.contentLength.toLong()
                }
                var actual = 0L
                try {
                    val ins = if (code in 200..299) conn.inputStream else conn.errorStream
                    if (ins != null) {
                        val buf = ByteArray(8192)
                        val limit = if (declared > 0) declared else 1024L * 1024
                        while (actual < limit) {
                            val toRead = minOf(buf.size.toLong(), limit - actual).toInt()
                            val n = ins.read(buf, 0, toRead)
                            if (n == -1) break
                            actual += n
                        }
                    }
                } catch (_: IOException) {
                }
                if (declared <= 0L || actual >= declared) ok++
            } catch (_: Exception) {
            } finally {
                conn?.disconnect()
            }
        }
        return ok
    }
}
