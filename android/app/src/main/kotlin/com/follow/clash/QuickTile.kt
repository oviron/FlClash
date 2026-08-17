package com.follow.clash

import android.app.Activity
import android.app.StatusBarManager
import android.content.ComponentName
import android.graphics.drawable.Icon
import android.os.Build
import androidx.core.content.ContextCompat

// A Quick Settings tile is never placed automatically; the user has to drag it
// in from the QS editor. Android 13 added a system prompt that does it in one
// tap, so the app can offer it instead of explaining where the pencil is.
object QuickTile {
    const val RESULT_UNSUPPORTED = -1
    const val RESULT_NO_ACTIVITY = -2

    fun requestAdd(activity: Activity?, label: String, onResult: (Int) -> Unit) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            onResult(RESULT_UNSUPPORTED)
            return
        }
        if (activity == null) {
            onResult(RESULT_NO_ACTIVITY)
            return
        }
        val manager = ContextCompat.getSystemService(activity, StatusBarManager::class.java)
        if (manager == null) {
            onResult(RESULT_UNSUPPORTED)
            return
        }
        manager.requestAddTileService(
            ComponentName(activity, TileService::class.java),
            label,
            // Non-transitive R: the tile drawable lives in the :service module,
            // same one the manifest points the TileService at.
            Icon.createWithResource(activity, com.follow.clash.service.R.drawable.ic),
            { it.run() },
            { onResult(it) },
        )
    }
}
