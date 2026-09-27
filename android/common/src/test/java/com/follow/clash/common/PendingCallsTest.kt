package com.follow.clash.common

import org.junit.Assert.assertEquals
import org.junit.Test

class PendingCallsTest {
    @Test
    fun failAllCompletesEveryPendingCallWithNullOnce() {
        val calls = PendingCalls<String>()
        val results = mutableListOf<Pair<String, String?>>()
        calls.register { results += "a" to it }
        calls.register { results += "b" to it }

        calls.failAll()
        calls.failAll()

        assertEquals(setOf("a" to null, "b" to null), results.toSet())
        assertEquals(2, results.size)
    }

    @Test
    fun completedCallIsNotFailedAndLateResultIsDropped() {
        val calls = PendingCalls<String>()
        val results = mutableListOf<Pair<String, String?>>()
        val done = calls.register { results += "done" to it }
        val dead = calls.register { results += "dead" to it }

        done("ok")
        calls.failAll()
        dead("late")
        done("again")

        assertEquals(listOf("done" to "ok", "dead" to null), results)
    }

    @Test
    fun registryKeepsWorkingAfterFailAll() {
        val calls = PendingCalls<String>()
        calls.register {}
        calls.failAll()
        val results = mutableListOf<String?>()

        val next = calls.register { results += it }
        next("fresh")

        assertEquals(listOf<String?>("fresh"), results)
    }
}
