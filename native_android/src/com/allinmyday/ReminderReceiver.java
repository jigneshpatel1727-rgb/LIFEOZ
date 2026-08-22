package com.allinmyday;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

/** Receives locally scheduled reminders. Notification display will be permission controlled. */
public final class ReminderReceiver extends BroadcastReceiver {
    public static final String CHANNEL_ID = "allinmyday_reminders";

    @Override public void onReceive(Context context, Intent intent) {
        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager == null) return;
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Allinmyday reminders", NotificationManager.IMPORTANCE_DEFAULT);
            manager.createNotificationChannel(channel);
        }
        // Notification rendering is deliberately kept behind the existing permission flow.
        // The receiver records the event point without contacting an external service.
    }
}
