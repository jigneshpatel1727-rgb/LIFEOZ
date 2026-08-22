package com.allinmyday;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Presentation-ready local model for the Household core's one-screen shopping report. */
public final class HouseholdReportModel {
    public final int total;
    public final int completed;
    public final int pending;
    public final List<AllinmydayStore.Record> items;

    private HouseholdReportModel(int total, int completed, List<AllinmydayStore.Record> items) {
        this.total = total;
        this.completed = completed;
        this.pending = total - completed;
        this.items = items;
    }

    public static HouseholdReportModel from(AllinmydayStore store) {
        List<AllinmydayStore.Record> source = store.getRecords("Household");
        List<AllinmydayStore.Record> copy = new ArrayList<>(source);
        int done = 0;
        for (AllinmydayStore.Record item : copy) if (item.completed) done++;
        return new HouseholdReportModel(copy.size(), done, copy);
    }

    public int completionPercent() {
        return total == 0 ? 0 : Math.round((completed * 100f) / total);
    }

    public String headline() {
        if (total == 0) return "Shopping list is empty";
        if (pending == 0) return "All household items completed";
        return pending + " item" + (pending == 1 ? "" : "s") + " still needed";
    }

    public static String classify(String title) {
        String s = title == null ? "" : title.toLowerCase(Locale.US);
        if (containsAny(s, "milk", "curd", "yogurt", "bread", "egg", "rice", "flour", "dal", "atta")) return "Kitchen staples";
        if (containsAny(s, "soap", "shampoo", "detergent", "cleaner", "tissue", "toilet")) return "Home supplies";
        if (containsAny(s, "vegetable", "fruit", "apple", "banana", "tomato", "potato", "onion")) return "Fresh produce";
        return "Household";
    }

    private static boolean containsAny(String value, String... terms) {
        for (String term : terms) if (value.contains(term)) return true;
        return false;
    }
}
