package com.follow.clash

import android.content.Context
import org.bouncycastle.openpgp.PGPObjectFactory
import org.bouncycastle.openpgp.PGPPublicKey
import org.bouncycastle.openpgp.PGPPublicKeyRingCollection
import org.bouncycastle.openpgp.PGPSignatureList
import org.bouncycastle.openpgp.PGPUtil
import org.bouncycastle.openpgp.operator.bc.BcKeyFingerprintCalculator
import org.bouncycastle.openpgp.operator.bc.BcPGPContentVerifierBuilderProvider
import java.io.File
import java.security.MessageDigest
import java.util.zip.ZipFile

// On-device equivalent of setup.dart's build-time check: SHA-256 + detached OpenPGP
// signature verification of a downloaded wrapper .aar against the pinned signing key,
// then extraction of the per-ABI .so into app-internal storage. Uses BouncyCastle's
// lightweight (Bc*) OpenPGP operators so no JCE provider registration is required.
object AarInstaller {
    private const val SIGNER_FPR = "1139C91B6525883E6783DCF04A94DA488A4C5033"
    private const val PUBKEY_ASSET = "oviron-signing.pub.asc"

    class InstallException(message: String) : Exception(message)

    fun install(
        context: Context,
        aar: File,
        asc: File,
        expectedSha256: String,
        abi: String,
        requiredSo: List<String>,
        dirName: String,
    ): File {
        val sha = sha256(aar)
        if (!sha.equals(expectedSha256, ignoreCase = true)) {
            throw InstallException("SHA-256 mismatch: expected $expectedSha256, got $sha")
        }
        if (!verifyDetached(context, aar, asc)) {
            throw InstallException("GPG signature verification failed")
        }
        val libsRoot = File(context.filesDir, "libs").apply { mkdirs() }
        val tmp = File(libsRoot, "$dirName.tmp")
        if (tmp.exists()) tmp.deleteRecursively()
        tmp.mkdirs()
        extractSo(aar, abi, requiredSo, tmp)
        for (so in requiredSo) {
            if (!File(tmp, so).exists()) {
                tmp.deleteRecursively()
                throw InstallException("missing $so for $abi in AAR")
            }
        }
        val dest = File(libsRoot, dirName)
        if (dest.exists()) dest.deleteRecursively()
        if (!tmp.renameTo(dest)) {
            tmp.deleteRecursively()
            throw InstallException("failed to finalize ${dest.absolutePath}")
        }
        return dest
    }

    private fun sha256(f: File): String {
        val md = MessageDigest.getInstance("SHA-256")
        f.inputStream().use { ins ->
            val buf = ByteArray(8192)
            var n = ins.read(buf)
            while (n > 0) {
                md.update(buf, 0, n)
                n = ins.read(buf)
            }
        }
        return md.digest().joinToString("") { "%02x".format(it) }
    }

    private fun verifyDetached(context: Context, data: File, asc: File): Boolean {
        val keyRings = context.assets.open(PUBKEY_ASSET).use { pk ->
            PGPPublicKeyRingCollection(PGPUtil.getDecoderStream(pk), BcKeyFingerprintCalculator())
        }
        val sig = asc.inputStream().use { s ->
            val factory = PGPObjectFactory(PGPUtil.getDecoderStream(s), BcKeyFingerprintCalculator())
            (factory.nextObject() as? PGPSignatureList)?.takeIf { !it.isEmpty }?.get(0)
        } ?: return false
        // Trust ONLY the pinned key: select it by the signature's keyID, then assert its
        // fingerprint. This replicates setup.dart importing only the pinned key.
        val key: PGPPublicKey = keyRings.getPublicKey(sig.keyID) ?: return false
        val fpr = key.fingerprint.joinToString("") { "%02X".format(it) }
        if (!fpr.equals(SIGNER_FPR, ignoreCase = true)) return false
        sig.init(BcPGPContentVerifierBuilderProvider(), key)
        data.inputStream().use { ins ->
            val buf = ByteArray(8192)
            var n = ins.read(buf)
            while (n > 0) {
                sig.update(buf, 0, n)
                n = ins.read(buf)
            }
        }
        return sig.verify()
    }

    private fun extractSo(aar: File, abi: String, requiredSo: List<String>, dest: File) {
        ZipFile(aar).use { zip ->
            for (so in requiredSo) {
                val entry = zip.getEntry("jni/$abi/$so") ?: continue
                zip.getInputStream(entry).use { ins ->
                    File(dest, so).outputStream().use { out -> ins.copyTo(out) }
                }
            }
        }
    }
}
