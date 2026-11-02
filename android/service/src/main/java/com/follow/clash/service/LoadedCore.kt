package com.follow.clash.service

import android.content.Context
import com.follow.clash.common.ActiveLibs
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

// Which libclash.so copies this process has mapped, for the UI to tell the selected core from
// the one that runs. A selected libclash.so without DT_SONAME loads but stays unused:
// libmihomo-jni.so's DT_NEEDED then resolves to the APK copy, so both show up in the maps.
object LoadedCore {
    private const val CORE_SO = "libclash.so"

    // {"selected": dir the loader used or null for the APK copy,
    //  "cores": "selected" | "bundled" | other dir, per mapped libclash.so,
    //  "failed": {"dir", "reason", "at"} of a selection that failed to load, or null}
    fun describe(context: Context): String {
        val selected = LibraryLoader.loadedFrom
        val roles = buildMap {
            put(canonical(context.applicationInfo.nativeLibraryDir), "bundled")
            selected?.let { put(canonical(it), "selected") }
        }
        val cores = mappedCoreDirs().map { roles[it] ?: it }
        return JSONObject()
            .put("selected", selected ?: JSONObject.NULL)
            .put("cores", JSONArray(cores))
            .put("failed", ActiveLibs.failure(context, ActiveLibs.MIHOMO) ?: JSONObject.NULL)
            .toString()
    }

    private fun mappedCoreDirs(): List<String> = runCatching {
        File("/proc/self/maps").useLines { lines ->
            lines.mapNotNull { line -> line.indexOf('/').takeIf { it >= 0 }?.let(line::substring) }
                .map { it.removeSuffix(" (deleted)") }
                .filter { File(it).name == CORE_SO }
                .mapNotNull { File(it).parent }
                .map(::canonical)
                .distinct()
                .toList()
        }
    }.getOrDefault(emptyList())

    private fun canonical(path: String): String = runCatching { File(path).canonicalPath }.getOrDefault(path)
}
