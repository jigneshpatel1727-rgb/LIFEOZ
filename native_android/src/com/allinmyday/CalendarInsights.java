package com.allinmyday;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Local calendar intelligence for bills, renewals, birthdays and service/checkup dates. */
public final class CalendarInsights {
    private CalendarInsights() {}

    public static final class Item {
        public final AllinmydayStore.Record record;
        public final String category;
        public final long daysFromToday;
        Item(AllinmydayStore.Record record, String category, long daysFromToday) {
            this.record = record; this.category = category; this.daysFromToday = daysFromToday;
        }
        public boolean isUpcoming() { return daysFromToday >= 0; }
        public boolean isDueSoon() { return daysFromToday >= 0 && daysFromToday <= 7; }
    }

    public static List<Item> upcoming(AllinmydayStore store, long nowMillis) {
        List<Item> out = new ArrayList<>();
        long today = DateBucket.startOfDay(nowMillis);
        for (AllinmydayStore.Record r : store.getRecords("Calendar")) {
            if (r.day < today) continue;
            long days = (DateBucket.startOfDay(r.day) - today) / 86400000L;
            out.add(new Item(r, classify(r.title), days));
        }
        return out;
    }

    public static String classify(String title) {
        String s = title == null ? "" : title.toLowerCase(Locale.US);
        if (containsAny(s, "insurance", "policy", "premium", "renewal")) return "Insurance / Renewal";
        if (containsAny(s, "bill", "electric", "electricity", "water", "gas", "internet", "emi", "payment")) return "Bill / Payment";
        if (containsAny(s, "birthday", "birth day", "anniversary")) return "Birthday / Anniversary";
        if (containsAny(s, "service", "servicing", "vehicle", "car", "bike", "maintenance")) return "Vehicle / Service";
        if (containsAny(s, "doctor", "medical", "checkup", "check-up", "health")) return "Health / Checkup";
        return "Important Date";
    }

    private static boolean containsAny(String value, String... terms) {
        for (String term : terms) if (value.contains(term)) return true;
        return false;
    }
}
