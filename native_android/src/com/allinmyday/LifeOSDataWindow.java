package com.allinmyday;

import java.util.Calendar;
import java.util.List;

/** Local date-window analytics for daily, weekly and monthly summaries. */
public final class LifeOSDataWindow {
    private LifeOSDataWindow() {}

    public static Summary summarize(AllinmydayStore store, String core, Window window) {
        long[] range = range(window);
        List<AllinmydayStore.Record> records = store.getRecords(core);
        int count = 0, completed = 0; double total = 0;
        for (AllinmydayStore.Record record : records) {
            if (record.day >= range[0] && record.day < range[1]) {
                count++; total += record.amount; if (record.completed) completed++;
            }
        }
        return new Summary(core, window, count, completed, total, range[0], range[1]);
    }

    private static long[] range(Window window) {
        Calendar end = Calendar.getInstance();
        Calendar start = (Calendar) end.clone();
        if (window == Window.DAY) start.add(Calendar.DAY_OF_YEAR, -1);
        else if (window == Window.WEEK) start.add(Calendar.DAY_OF_YEAR, -7);
        else if (window == Window.MONTH) start.add(Calendar.MONTH, -1);
        else start.add(Calendar.YEAR, -1);
        return new long[]{start.getTimeInMillis(), end.getTimeInMillis() + 1};
    }

    public enum Window { DAY, WEEK, MONTH, YEAR }

    public static final class Summary {
        public final String core; public final Window window; public final int count; public final int completed;
        public final double total; public final long from; public final long to;
        Summary(String core, Window window, int count, int completed, double total, long from, long to) {
            this.core = core; this.window = window; this.count = count; this.completed = completed; this.total = total; this.from = from; this.to = to;
        }
        public int completionPercent() { return count == 0 ? 0 : (completed * 100) / count; }
    }
}
