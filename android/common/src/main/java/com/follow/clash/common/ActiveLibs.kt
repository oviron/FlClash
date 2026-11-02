package com.follow.clash.common

import android.content.Context
import org.json.JSONObject
import java.io.File

// Pointer file (filesDir/active-libs.json) naming, per core label, the directory to
// System.load the core .so from. Written atomically by the main process (LibraryPlugin);
// read by :remote (mihomo). An absent/invalid label means the caller falls back to
// applicationInfo.nativeLibraryDir (the APK-bundled default), so a missing or corrupt
// pointer can never brick core loading. When :remote cannot load the selected dir it
// swaps the pointer for a failure record under "<label>-failed", kept until the user
// picks a core again or dismisses it.
object ActiveLibs {
    const val MIHOMO = "mihomo"

    val MIHOMO_SO = listOf("libclash.so", "libmihomo-jni.so")

    private fun file(context: Context) = File(context.filesDir, "active-libs.json")

    private fun failedKey(label: String) = "$label-failed"

    private fun read(context: Context): JSONObject = try {
        val f = file(context)
        if (f.exists()) JSONObject(f.readText()) else JSONObject()
    } catch (_: Exception) {
        JSONObject()
    }

    private fun update(context: Context, change: (JSONObject) -> Unit) {
        val f = file(context)
        val json = read(context).also(change)
        val tmp = File(f.parentFile, "${f.name}.tmp")
        tmp.writeText(json.toString())
        tmp.renameTo(f)
    }

    // The selected dir as written, whether or not its files are still there.
    fun pointerFor(context: Context, label: String): String? =
        read(context).optString(label, "").takeIf { it.isNotEmpty() }

    fun dirFor(context: Context, label: String, requiredSo: List<String>): String? {
        val dir = pointerFor(context, label) ?: return null
        return if (missingSo(dir, requiredSo).isEmpty()) dir else null
    }

    fun missingSo(dir: String, requiredSo: List<String>): List<String> =
        requiredSo.filterNot { File(dir, it).exists() }

    // A new selection, the bundled default included, also forgets an earlier failure.
    @Synchronized
    fun setActive(context: Context, label: String, dir: String?) = update(context) { json ->
        if (dir == null) json.remove(label) else json.put(label, dir)
        json.remove(failedKey(label))
    }

    // :remote could not load [dir]: the next start takes the bundled core, and the UI
    // learns which selection failed, why and when.
    @Synchronized
    fun markFailed(context: Context, label: String, dir: String, reason: String) =
        update(context) { json ->
            json.remove(label)
            json.put(
                failedKey(label),
                JSONObject()
                    .put("dir", dir)
                    .put("reason", reason)
                    .put("at", System.currentTimeMillis()),
            )
        }

    // {"dir", "reason", "at": epoch ms} of the last selection that failed to load, or null.
    fun failure(context: Context, label: String): JSONObject? =
        read(context).optJSONObject(failedKey(label))

    @Synchronized
    fun clearFailure(context: Context, label: String) = update(context) { json ->
        json.remove(failedKey(label))
    }
}
