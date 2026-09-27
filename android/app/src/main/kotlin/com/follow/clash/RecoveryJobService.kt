package com.follow.clash

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import com.follow.clash.common.GlobalState
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

private const val RECOVERY_JOB_ID = 0x7f1c
private const val RECOVERY_PERIOD_MS = 15 * 60_000L
private const val START_WAIT_MS = 30_000L

// Armed while the user wants the tunnel up: when both processes die nothing else wakes the app.
object RecoveryJob {
    private val scheduler get() = GlobalState.application.getSystemService(JobScheduler::class.java)

    fun schedule() {
        val app = GlobalState.application
        val job = JobInfo.Builder(RECOVERY_JOB_ID, ComponentName(app, RecoveryJobService::class.java))
            .setPeriodic(RECOVERY_PERIOD_MS)
            .build()
        runCatching { scheduler?.schedule(job) }
            .onFailure { GlobalState.log("Recovery job not scheduled: $it") }
    }

    fun cancel() {
        scheduler?.cancel(RECOVERY_JOB_ID)
    }
}

class RecoveryJobService : JobService() {
    override fun onStartJob(params: JobParameters): Boolean {
        GlobalState.launch {
            State.request { handleRecoveryCheck() }
            // Held until the start settles so the process is not frozen halfway through it.
            withTimeoutOrNull(START_WAIT_MS) { State.runStateFlow.first { it == RunState.START } }
            jobFinished(params, false)
        }
        return true
    }

    override fun onStopJob(params: JobParameters): Boolean = false
}
