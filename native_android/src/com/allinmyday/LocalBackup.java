package com.allinmyday;

/** Builds a portable text snapshot of local Allinmyday records; no cloud service involved. */
public final class LocalBackup {
    private LocalBackup() {}

    public static String export(AllinmydayStore store) {
        StringBuilder out = new StringBuilder(BackupFormat.header());
        out.append("name=").append(escape(store.getName())).append('\n');
        out.append("email=").append(escape(store.getEmail())).append('\n');
        out.append("currency=").append(escape(store.getCurrency())).append('\n');
        out.append("language=").append(escape(store.getLanguage())).append('\n');
        out.append("theme=").append(escape(store.getTheme())).append('\n');
        String[] cores = {"Expenses", "Goals", "Tasks", "Household", "Calendar", "Diary", "Investments", "Health"};
        for (String core : cores) for (AllinmydayStore.Record r : store.getRecords(core)) {
            out.append("record|").append(escape(r.core)).append('|').append(r.id).append('|')
               .append(escape(r.title)).append('|').append(r.amount).append('|').append(r.day).append('|').append(r.completed).append('\n');
        }
        return out.toString();
    }

    private static String escape(String value) {
        return (value == null ? "" : value).replace("\\", "\\\\").replace("\n", "\\n").replace("|", "\\|");
    }
}
