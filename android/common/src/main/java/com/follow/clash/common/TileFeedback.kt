package com.follow.clash.common

// The panel-open tile visibly flips state on its own; a toast on top of that
// only repeats it. Collapsed, the panel closes and the toast is the only
// feedback left, so it stays for every non-tile caller too.
fun shouldShowTileActionToast(fromTile: Boolean, collapsePanel: Boolean): Boolean =
    !fromTile || collapsePanel

fun tileSubtitle(profileName: String, isRunning: Boolean): String? =
    profileName.takeIf { isRunning && it.isNotBlank() }
