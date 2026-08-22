package com.allinmyday;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

/** Local reminder foundation using Android platform scheduling; no external reminder service. */
public final class ReminderEngine {
    private ReminderEngine() {}

    public static void schedule(Context context, long id, long triggerAtMillis, String title) {
        AlarmManager alarm = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarm == null) return;
        Intent intent = new Intent(context, ReminderReceiver.class);
        intent.putExtra("title", title == null ? "Allinmyday reminder" : title);
        PendingIntent pending = PendingIntent.getBroadcast(context, (int) id, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending);
    }
}
