package com.follow.clash.transfer

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.security.MessageDigest

// The other local build of this app: the CI release and a build from the dev machine.
object Siblings {
    const val ACTION_EXPORT = "com.follow.clash.action.EXPORT_DATA"

    private val packages = listOf("com.follow.clash", "com.follow.clash.dev")

    // SHA-256 of the release key and of the dev machine's debug key.
    private val certs = listOf(
        "305a0187eab5bed4b2e07aad7d1daa497a9c5234aec72d9c9d26ea9e8a2a1940",
        "7079999f1d8e3b408bbce0710e50333d35da6adab9000ce7d0b0f3a45e6bdefb",
    )

    fun find(context: Context): String? =
        packages.firstOrNull { isTrusted(context, it) }

    fun isTrusted(context: Context, packageName: String): Boolean =
        packageName in packages && packageName != context.packageName &&
            runCatching { signedByUs(context.packageManager, packageName) }.getOrDefault(false)

    fun label(context: Context, packageName: String): String {
        val pm = context.packageManager
        return pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0)).toString()
    }

    private fun signedByUs(pm: PackageManager, packageName: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return certs.any {
                pm.hasSigningCertificate(packageName, it.hexToBytes(), PackageManager.CERT_INPUT_SHA256)
            }
        }
        @Suppress("DEPRECATION")
        val signatures = pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES).signatures
            ?: return false
        val digests = signatures.map { it.toByteArray().sha256() }
        return digests.isNotEmpty() && digests.all { it in certs }
    }

    private fun ByteArray.sha256(): String =
        MessageDigest.getInstance("SHA-256").digest(this).joinToString("") { "%02x".format(it) }

    private fun String.hexToBytes(): ByteArray =
        chunked(2).map { it.toInt(16).toByte() }.toByteArray()
}
