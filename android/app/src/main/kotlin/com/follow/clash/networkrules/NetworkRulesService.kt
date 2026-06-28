package com.follow.clash.networkrules

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.follow.clash.MainActivity
import com.follow.clash.R
import com.follow.clash.common.startForegroundCompat

// Resident foreground service in the default (UI) process. Its whole job is to
// stay alive so NetworkRulesController keeps observing and deciding while the
// UI is killed and the VPN runs in :remote.
class NetworkRulesService : Service() {

    override fun onCreate() {
        super.onCreate()
        startForegroundCompat(NOTIFICATION_ID, buildNotification())
        NetworkRulesController.start(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        NetworkRulesController.stop()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            if (manager?.getNotificationChannel(CHANNEL) == null) {
                manager?.createNotificationChannel(
                    NotificationChannel(
                        CHANNEL,
                        getString(R.string.network_rules_channel),
                        NotificationManager.IMPORTANCE_LOW,
                    ),
                )
            }
        }
        val open = NotificationCompat.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("FlClash")
            .setContentText(getString(R.string.network_rules_notification))
            .setOngoing(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
        Intent(this, MainActivity::class.java).let {
            it.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            open.setContentIntent(
                android.app.PendingIntent.getActivity(
                    this,
                    0,
                    it,
                    android.app.PendingIntent.FLAG_IMMUTABLE,
                ),
            )
        }
        return open.build()
    }

    companion object {
        const val CHANNEL = "FlClashNetworkRules"
        const val NOTIFICATION_ID = 2
    }
}
