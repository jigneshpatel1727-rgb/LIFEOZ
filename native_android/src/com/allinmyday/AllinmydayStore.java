package com.allinmyday;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Local Allinmyday-owned storage using the Android platform SharedPreferences API.
 * No database or third-party storage package is required for the native trial.
 */
public final class AllinmydayStore {
    private static final String PREFS = "allinmyday_store";
    private final SharedPreferences prefs;

    public AllinmydayStore(Context context) {
        prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    public long addRecord(String core, String title, double amount, long day, boolean completed) {
        long id = prefs.getLong("next_id", 1L);
        String prefix = "record_" + id + "_";
        prefs.edit()
            .putString(prefix + "core", core == null ? "" : core)
            .putString(prefix + "title", title == null ? "" : title)
            .putLong(prefix + "amount_bits", Double.doubleToLongBits(amount))
            .putLong(prefix + "day", day)
            .putBoolean(prefix + "completed", completed)
            .putLong("next_id", id + 1L)
            .apply();
        return id;
    }

    public void close() { /* platform preferences need no close operation */ }
}
