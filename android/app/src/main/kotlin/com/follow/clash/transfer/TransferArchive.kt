package com.follow.clash.transfer

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import org.json.JSONObject
import java.io.File
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

// Packs everything the other build needs into the backup archive the app restores
// (lib/common/backup_task.dart), plus transfer.json with what a backup leaves out.
object TransferArchive {
    private const val PREFS = "FlutterSharedPreferences"
    private const val PREFIX = "flutter."
    private val extraKeys = setOf("happHwid", "inboundAuth")
    private const val SNAPSHOT_PREFIX = "groupsSnapshot."
    private val geoFiles = listOf("GEOIP.metadb", "ASN.mmdb", "GEOIP.dat", "GEOSITE.dat")

    fun write(context: Context, target: File) {
        val home = context.filesDir
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).all
        ZipOutputStream(target.outputStream().buffered()).use { zip ->
            val db = File(home, "database.sqlite")
            if (db.exists()) {
                val snapshot = File(target.parentFile, "database.snapshot")
                snapshotDatabase(db, snapshot)
                zip.putFile("database.sqlite", snapshot)
                snapshot.delete()
            }
            val config = JSONObject(prefs["${PREFIX}config"] as? String ?: "{}")
                .put("version", prefs["${PREFIX}version"] ?: 0)
            zip.putBytes("config.json", config.toString().toByteArray())
            val extras = JSONObject()
            for ((key, value) in prefs) {
                val name = key.removePrefix(PREFIX)
                if (value is String && key.startsWith(PREFIX) && isExtra(name)) {
                    extras.put(name, value)
                }
            }
            zip.putBytes("transfer.json", JSONObject().put("prefs", extras).toString().toByteArray())
            for (name in geoFiles) {
                File(home, name).takeIf { it.isFile }?.let { zip.putFile(name, it) }
            }
            // Profiles hold the shared provider cache too, so nothing is fetched again.
            for (dir in listOf("profiles", "scripts")) {
                File(home, dir).walkTopDown()
                    .filter { it.isFile && !it.name.endsWith(".tmp") }
                    .forEach { zip.putFile(it.relativeTo(home).invariantSeparatorsPath, it) }
            }
        }
    }

    private fun isExtra(name: String) = name in extraKeys || name.startsWith(SNAPSHOT_PREFIX)

    // A consistent copy while the app may be writing; VACUUM INTO needs SQLite 3.27.
    private fun snapshotDatabase(db: File, to: File) {
        to.delete()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val done = runCatching {
                SQLiteDatabase.openDatabase(
                    db.path,
                    null,
                    SQLiteDatabase.OPEN_READONLY or SQLiteDatabase.NO_LOCALIZED_COLLATORS,
                ).use { it.execSQL("VACUUM INTO ?", arrayOf(to.path)) }
            }.isSuccess
            if (done) return
            to.delete()
        }
        db.copyTo(to, overwrite = true)
    }

    private fun ZipOutputStream.putFile(name: String, file: File) {
        putNextEntry(ZipEntry(name))
        file.inputStream().use { it.copyTo(this) }
        closeEntry()
    }

    private fun ZipOutputStream.putBytes(name: String, bytes: ByteArray) {
        putNextEntry(ZipEntry(name))
        write(bytes)
        closeEntry()
    }
}
