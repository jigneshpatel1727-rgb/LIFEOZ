package com.allinmyday;

import java.util.Locale;

/** Compact local context supplied to iamyansi; no network access and no autonomous code changes. */
public final class IamyansiContext {
    private IamyansiContext() {}

    public static Snapshot build(AllinmydayStore store) {
        return new Snapshot(
            store.getName(),
            store.getCurrency(),
            store.getLanguage(),
            store.getTheme(),
            count(store, "Expenses"),
            count(store, "Goals"),
            count(store, "Tasks"),
            count(store, "Household"),
            count(store, "Calendar"));
    }

    private static int count(AllinmydayStore store, String core) { return store.getRecordCount(core); }

    public static final class Snapshot {
        public final String userName, currency, language, theme;
        public final int expenses, goals, tasks, household, calendar;
        Snapshot(String userName, String currency, String language, String theme, int expenses, int goals, int tasks, int household, int calendar) {
            this.userName = userName; this.currency = currency; this.language = language; this.theme = theme;
            this.expenses = expenses; this.goals = goals; this.tasks = tasks; this.household = household; this.calendar = calendar;
        }
        public String brief() {
            return String.format(Locale.US, "%s: expenses=%d, goals=%d, tasks=%d, household=%d, calendar=%d", userName, expenses, goals, tasks, household, calendar);
        }
    }
}
