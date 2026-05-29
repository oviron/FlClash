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
        val url = parseUrl(site) ?: return 0
        var ok = 0
        repeat(requests) {
            if (probe(url, timeoutSec)) ok++
        }
        return ok
    }

    private fun parseUrl(site: String): URL? = try {
        URL(if (site.startsWith("http://") || site.startsWith("https://")) site else "https://$site")
    } catch (_: Exception) {
        null
    }

    private fun probe(url: URL, timeoutSec: Long): Boolean {
        var conn: HttpURLConnection? = null
        return try {
            conn = (url.openConnection(proxy) as HttpURLConnection).apply {
                connectTimeout = (timeoutSec * 1000).toInt()
                readTimeout = (timeoutSec * 1000).toInt()
                instanceFollowRedirects = true
                setRequestProperty("Connection", "close")
            }
            val code = conn.responseCode
            val declared = declaredLength(conn)
            val actual = readBody(conn, code, declared)
            declared <= 0L || actual >= declared
        } catch (_: Exception) {
            false
        } finally {
            conn?.disconnect()
        }
    }

    private fun declaredLength(conn: HttpURLConnection): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            conn.contentLengthLong
        } else {
            conn.contentLength.toLong()
        }

    private fun readBody(conn: HttpURLConnection, code: Int, declared: Long): Long {
        return try {
            val ins = (if (code in 200..299) conn.inputStream else conn.errorStream)
                ?: return 0L
            val buf = ByteArray(8192)
            val limit = if (declared > 0) declared else 1024L * 1024
            var actual = 0L
            while (actual < limit) {
                val n = ins.read(buf, 0, minOf(buf.size.toLong(), limit - actual).toInt())
                if (n == -1) break
                actual += n
            }
            actual
        } catch (_: IOException) {
            0L
        }
    }
}
