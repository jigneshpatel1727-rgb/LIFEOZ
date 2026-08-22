package com.allinmyday;

import java.util.Calendar;

/** Calendar boundaries used by local reports and carry-forward processing. */
public final class DateBucket {
    private DateBucket() {}

    public static long startOfDay(long millis) { return start(millis, Calendar.DAY_OF_YEAR); }
    public static long startOfWeek(long millis) { return start(millis, Calendar.WEEK_OF_YEAR); }
    public static long startOfMonth(long millis) { return start(millis, Calendar.MONTH); }
    public static long startOfYear(long millis) { return start(millis, Calendar.YEAR); }

    private static long start(long millis, int field) {
        Calendar c = Calendar.getInstance(); c.setTimeInMillis(millis);
        if (field == Calendar.DAY_OF_YEAR) { c.set(Calendar.HOUR_OF_DAY,0); c.set(Calendar.MINUTE,0); c.set(Calendar.SECOND,0); c.set(Calendar.MILLISECOND,0); }
        else if (field == Calendar.WEEK_OF_YEAR) { c.set(Calendar.DAY_OF_WEEK,c.getFirstDayOfWeek()); c.set(Calendar.HOUR_OF_DAY,0); c.set(Calendar.MINUTE,0); c.set(Calendar.SECOND,0); c.set(Calendar.MILLISECOND,0); }
        else if (field == Calendar.MONTH) { c.set(Calendar.DAY_OF_MONTH,1); c.set(Calendar.HOUR_OF_DAY,0); c.set(Calendar.MINUTE,0); c.set(Calendar.SECOND,0); c.set(Calendar.MILLISECOND,0); }
        else { c.set(Calendar.DAY_OF_YEAR,1); c.set(Calendar.HOUR_OF_DAY,0); c.set(Calendar.MINUTE,0); c.set(Calendar.SECOND,0); c.set(Calendar.MILLISECOND,0); }
        return c.getTimeInMillis();
    }
}
