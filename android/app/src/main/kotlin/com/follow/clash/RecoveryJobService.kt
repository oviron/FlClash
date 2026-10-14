package com.follow.clash

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import com.follow.clash.common.GlobalState
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

private const val RECOVERY_JOB_ID = 0x7f1c
private const val RECOVERY_PERIOD_MS = 15 * 60_000L
// Without a flex window the first run may come right after schedule().
private const val RECOVERY_FLEX_MS = 5 * 60_000L
private const val START_WAIT_MS = 30_000L

// Armed while the user wants the tunnel up: when both processes die nothing else wakes the app.
object RecoveryJob {
    private val scheduler get() = GlobalState.application.getSystemService(JobScheduler::class.java)

    fun schedule() {
        val app = GlobalState.application
        val job = JobInfo.Builder(RECOVERY_JOB_ID, ComponentName(app, RecoveryJobService::class.java))
            .setPeriodic(RECOVERY_PERIOD_MS, RECOVERY_FLEX_MS)
            .build()
        runCatching { scheduler?.schedule(job) }
            .onFailure { GlobalState.log("Recovery job not scheduled: $it") }
    }

    fun cancel() {
        scheduler?.cancel(RECOVERY_JOB_ID)
    }

    val isArmed: Boolean get() = scheduler?.getPendingJob(RECOVERY_JOB_ID) != null
}

// Held until the start settles so the process is not frozen or killed halfway through it.
private suspend fun recoverAndSettle() {
    val recovering = CompletableDeferred<Boolean>()
    State.request { recovering.complete(handleRecoveryCheck()) }
    if (recovering.await()) {
        withTimeoutOrNull(START_WAIT_MS) { State.runStateFlow.first { it == RunState.START } }
    }
}

class RecoveryJobService : JobService() {
    override fun onStartJob(params: JobParameters): Boolean {
        GlobalState.launch {
            recoverAndSettle()
            jobFinished(params, false)
        }
        return true
    }

    override fun onStopJob(params: JobParameters): Boolean = false
}

// An update kills both processes; the armed job would bring the tunnel back only on its next period.
class PackageReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val pending = goAsync()
        GlobalState.launch {
            try {
                recoverAndSettle()
            } finally {
                pending.finish()
            }
        }
    }
}
