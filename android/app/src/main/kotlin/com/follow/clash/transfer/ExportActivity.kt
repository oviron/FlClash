package com.follow.clash.transfer

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import androidx.core.content.FileProvider
import com.follow.clash.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class TransferFileProvider : FileProvider()

// Hands this build's data to the other local build once the user agrees here.
class ExportActivity : Activity(), CoroutineScope by MainScope() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        val caller = callingActivity?.packageName
        if (intent.action != Siblings.ACTION_EXPORT || caller == null ||
            !Siblings.isTrusted(this, caller)
        ) {
            finish()
            return
        }
        AlertDialog.Builder(this, dialogTheme)
            .setTitle(R.string.transfer_title)
            .setMessage(getString(R.string.transfer_message, Siblings.label(this, caller)))
            .setPositiveButton(R.string.transfer_confirm) { _, _ -> export() }
            .setNegativeButton(android.R.string.cancel) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun export() {
        val progress = AlertDialog.Builder(this, dialogTheme)
            .setMessage(R.string.transfer_progress)
            .setCancelable(false)
            .show()
        launch {
            val archive = runCatching {
                withContext(Dispatchers.IO) {
                    val dir = File(cacheDir, "transfer").apply {
                        deleteRecursively()
                        mkdirs()
                    }
                    File(dir, "transfer.zip").also { TransferArchive.write(this@ExportActivity, it) }
                }
            }
            progress.dismiss()
            archive.onSuccess {
                val uri = FileProvider.getUriForFile(this@ExportActivity, "$packageName.transfer", it)
                // Write lets the other build delete the archive once it has a copy.
                setResult(
                    RESULT_OK,
                    Intent().setData(uri).addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                    ),
                )
            }.onFailure {
                setResult(RESULT_FIRST_USER, Intent().putExtra(EXTRA_ERROR, it.toString()))
            }
            finish()
        }
    }

    private val dialogTheme: Int
        get() {
            val night = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
            return if (night == Configuration.UI_MODE_NIGHT_YES) {
                android.R.style.Theme_DeviceDefault_Dialog_Alert
            } else {
                android.R.style.Theme_DeviceDefault_Light_Dialog_Alert
            }
        }

    override fun onDestroy() {
        cancel()
        super.onDestroy()
    }

    companion object {
        const val EXTRA_ERROR = "error"
    }
}
