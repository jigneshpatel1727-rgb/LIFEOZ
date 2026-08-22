package com.allinmyday;

import java.util.ArrayList;
import java.util.List;

/** Presentation-ready local model for the Calendar core's one-screen report. */
public final class CalendarReportModel {
    public final int total;
    public final int dueSoon;
    public final List<CalendarInsights.Item> upcoming;

    private CalendarReportModel(int total, int dueSoon, List<CalendarInsights.Item> upcoming) {
        this.total = total;
        this.dueSoon = dueSoon;
        this.upcoming = upcoming;
    }

    public static CalendarReportModel from(AllinmydayStore store, long nowMillis) {
        List<CalendarInsights.Item> all = CalendarInsights.upcoming(store, nowMillis);
        int soon = 0;
        for (CalendarInsights.Item item : all) if (item.isDueSoon()) soon++;
        return new CalendarReportModel(all.size(), soon, new ArrayList<>(all));
    }

    public String headline() {
        if (total == 0) return "No upcoming dates";
        if (dueSoon == 0) return total + " upcoming date" + (total == 1 ? "" : "s");
        return dueSoon + " due within 7 days • " + total + " upcoming";
    }
}
