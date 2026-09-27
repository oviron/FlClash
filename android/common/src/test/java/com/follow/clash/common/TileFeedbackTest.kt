package com.follow.clash.common

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class TileFeedbackTest {

    @Test
    fun `non-tile callers always keep the toast`() {
        assertEquals(true, shouldShowTileActionToast(fromTile = false, collapsePanel = true))
        assertEquals(true, shouldShowTileActionToast(fromTile = false, collapsePanel = false))
    }

    @Test
    fun `a tile tap keeps the toast only when the panel collapses`() {
        assertEquals(true, shouldShowTileActionToast(fromTile = true, collapsePanel = true))
        assertEquals(false, shouldShowTileActionToast(fromTile = true, collapsePanel = false))
    }

    @Test
    fun `subtitle shows the profile name only while running`() {
        assertEquals("Work", tileSubtitle("Work", isRunning = true))
        assertNull(tileSubtitle("Work", isRunning = false))
    }

    @Test
    fun `subtitle hides a blank profile name even while running`() {
        assertNull(tileSubtitle("", isRunning = true))
        assertNull(tileSubtitle("   ", isRunning = true))
    }
}
