package com.follow.clash

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import com.follow.clash.common.GlobalState
import com.follow.clash.common.QuickAction
import com.follow.clash.common.quickIntent
import com.follow.clash.common.toPendingIntent

class VpnWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        manager.updateAppWidget(ids, views(context))
        State.request { handleSyncState() }
    }

    companion object {
        fun refresh() {
            val app = GlobalState.application
            val manager = AppWidgetManager.getInstance(app) ?: return
            val ids = manager.getAppWidgetIds(ComponentName(app, VpnWidget::class.java))
            if (ids.isNotEmpty()) manager.updateAppWidget(ids, views(app))
        }

        private fun views(context: Context): RemoteViews {
            val runState = State.runStateFlow.value
            val status = when (runState) {
                RunState.START -> R.string.widget_on
                RunState.PENDING -> R.string.widget_pending
                RunState.STOP -> R.string.widget_off
            }
            val background = when (runState) {
                RunState.START -> R.drawable.widget_bg_on
                else -> R.drawable.widget_bg_off
            }
            return RemoteViews(context.packageName, R.layout.vpn_widget).apply {
                setTextViewText(R.id.widget_profile, State.sharedState.currentProfileName)
                setTextViewText(R.id.widget_status, context.getString(status))
                setInt(R.id.widget_root, "setBackgroundResource", background)
                setOnClickPendingIntent(R.id.widget_root, QuickAction.TOGGLE.quickIntent.toPendingIntent)
            }
        }
    }
}
