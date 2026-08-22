package com.allinmyday;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/** Creates next-day copies for incomplete Tasks without deleting the original record. */
public final class TaskCarryForward {
    private TaskCarryForward() {}

    public static int carryPending(AllinmydayStore store) {
        long today = startOfDay(System.currentTimeMillis());
        long tomorrow = today + 24L * 60L * 60L * 1000L;
        int added = 0;
        List<AllinmydayStore.Record> records = new ArrayList<>(store.getRecords("Tasks"));
        for (AllinmydayStore.Record r : records) {
            if (!r.completed && r.day < today && !store.hasRecordOnDay("Tasks", r.title, tomorrow)) {
                store.addRecord("Tasks", r.title, r.amount, tomorrow, false);
                added++;
            }
        }
        return added;
    }

    private static long startOfDay(long time) {
        Calendar c = Calendar.getInstance(); c.setTimeInMillis(time);
        c.set(Calendar.HOUR_OF_DAY,0); c.set(Calendar.MINUTE,0); c.set(Calendar.SECOND,0); c.set(Calendar.MILLISECOND,0);
        return c.getTimeInMillis();
    }
}
