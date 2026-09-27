package com.follow.clash.common

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class RecoveryBudgetTest {
    @Test
    fun allowsAttemptsUpToTheLimitWithinTheWindow() {
        val budget = RecoveryBudget(maxAttempts = 3, windowMs = 60_000)

        assertTrue(budget.tryAcquire(now = 0))
        assertTrue(budget.tryAcquire(now = 1_000))
        assertTrue(budget.tryAcquire(now = 2_000))
        assertFalse(budget.tryAcquire(now = 3_000))
    }

    @Test
    fun attemptsOlderThanTheWindowNoLongerCount() {
        val budget = RecoveryBudget(maxAttempts = 2, windowMs = 60_000)
        budget.tryAcquire(now = 0)
        budget.tryAcquire(now = 10_000)

        assertFalse(budget.tryAcquire(now = 59_999))
        assertTrue(budget.tryAcquire(now = 60_000))
        assertFalse(budget.tryAcquire(now = 60_001))
        assertTrue(budget.tryAcquire(now = 70_000))
    }

    @Test
    fun aRefusedAttemptDoesNotExtendThePause() {
        val budget = RecoveryBudget(maxAttempts = 1, windowMs = 60_000)
        budget.tryAcquire(now = 0)

        assertFalse(budget.tryAcquire(now = 30_000))
        assertTrue(budget.tryAcquire(now = 60_000))
    }
}
