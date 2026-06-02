package com.follow.clash.common

import android.content.Context
import org.json.JSONObject
import java.io.File

// Pointer file (filesDir/active-libs.json) naming, per core label, the directory to
// System.load the core .so from. Written atomically by the main process (LibraryPlugin);
// read by :remote (mihomo) and the app process (byedpi). An absent/invalid label means
// the caller falls back to applicationInfo.nativeLibraryDir (the APK-bundled default), so
// a missing or corrupt pointer can never brick core loading.
object ActiveLibs {
    const val MIHOMO = "mihomo"
    const val BYEDPI = "byedpi"

    val MIHOMO_SO = listOf("libclash.so", "libmihomo-jni.so")
    val BYEDPI_SO = listOf("libbyedpi.so")

    private fun file(context: Context) = File(context.filesDir, "active-libs.json")

    fun dirFor(context: Context, label: String, requiredSo: List<String>): String? {
        val dir = try {
            val f = file(context)
            if (!f.exists()) return null
            JSONObject(f.readText()).optString(label, "").takeIf { it.isNotEmpty() }
        } catch (_: Exception) {
            null
        } ?: return null
        val d = File(dir)
        return if (requiredSo.all { File(d, it).exists() }) dir else null
    }

    @Synchronized
    fun setActive(context: Context, label: String, dir: String?) {
        val f = file(context)
        val json = if (f.exists()) {
            runCatching { JSONObject(f.readText()) }.getOrDefault(JSONObject())
        } else {
            JSONObject()
        }
        if (dir == null) json.remove(label) else json.put(label, dir)
        val tmp = File(f.parentFile, "${f.name}.tmp")
        tmp.writeText(json.toString())
        tmp.renameTo(f)
    }
}
