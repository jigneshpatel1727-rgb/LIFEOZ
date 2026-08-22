package com.allinmyday;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Searches only the user's locally stored Allinmyday records. */
public final class AllinmydaySearch {
    private AllinmydaySearch() {}

    public static List<AllinmydayStore.Record> search(AllinmydayStore store, String query) {
        String q = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        ArrayList<AllinmydayStore.Record> result = new ArrayList<>();
        String[] cores = {"Expenses", "Goals", "Tasks", "Household", "Calendar", "Diary", "Investments", "Health"};
        for (String core : cores) {
            for (AllinmydayStore.Record record : store.getRecords(core)) {
                if (q.isEmpty() || record.title.toLowerCase(Locale.ROOT).contains(q) || core.toLowerCase(Locale.ROOT).contains(q)) result.add(record);
            }
        }
        return result;
    }
}
