package com.allinmyday;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.ArrayList;
import java.util.List;

/** Local Allinmyday-owned profile and records. No third-party database. */
public final class AllinmydayStore {
    private static final String PREFS = "allinmyday_store";
    private final SharedPreferences prefs;

    public static final class Record {
        public final long id;
        public final String core;
        public final String title;
        public final double amount;
        public final long day;
        public final boolean completed;
        Record(long id, String core, String title, double amount, long day, boolean completed) {
            this.id = id; this.core = core; this.title = title; this.amount = amount;
            this.day = day; this.completed = completed;
        }
    }

    public AllinmydayStore(Context context) {
        prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    public boolean hasProfile() { return !getName().trim().isEmpty(); }
    public String getName() { return prefs.getString("profile_name", ""); }
    public String getEmail() { return prefs.getString("profile_email", ""); }
    public String getCurrency() { return prefs.getString("profile_currency", "INR (₹)"); }
    public String getLanguage() { return prefs.getString("profile_language", "English"); }
    public String getTheme() { return prefs.getString("profile_theme", "Nature Green"); }

    public void saveProfile(String name, String email, String currency, String language, String theme) {
        prefs.edit().putString("profile_name", name == null ? "" : name.trim())
            .putString("profile_email", email == null ? "" : email.trim())
            .putString("profile_currency", currency == null ? "INR (₹)" : currency)
            .putString("profile_language", language == null ? "English" : language)
            .putString("profile_theme", theme == null ? "Nature Green" : theme)
            .apply();
    }

    public long addRecord(String core, String title, double amount, long day, boolean completed) {
        long id = prefs.getLong("next_id", 1L);
        prefs.edit().putString("record_" + id + "_core", core == null ? "" : core)
            .putString("record_" + id + "_title", title == null ? "" : title)
            .putLong("record_" + id + "_amount_bits", Double.doubleToLongBits(amount))
            .putLong("record_" + id + "_day", day)
            .putBoolean("record_" + id + "_completed", completed)
            .putLong("next_id", id + 1L).apply();
        return id;
    }

    /** Returns records newest-first for one of the five LifeOS cores. */
    public List<Record> getRecords(String core) {
        ArrayList<Record> out = new ArrayList<>();
        long next = prefs.getLong("next_id", 1L);
        for (long id = next - 1L; id >= 1L; id--) {
            String savedCore = prefs.getString("record_" + id + "_core", null);
            if (savedCore == null || !savedCore.equals(core)) continue;
            String title = prefs.getString("record_" + id + "_title", "");
            double amount = Double.longBitsToDouble(prefs.getLong("record_" + id + "_amount_bits", 0L));
            long day = prefs.getLong("record_" + id + "_day", 0L);
            boolean completed = prefs.getBoolean("record_" + id + "_completed", false);
            out.add(new Record(id, savedCore, title, amount, day, completed));
        }
        return out;
    }

    public int getRecordCount(String core) { return getRecords(core).size(); }

    public double getTotalAmount(String core) {
        double total = 0;
        for (Record r : getRecords(core)) total += r.amount;
        return total;
    }

    public void setCompleted(long id, boolean completed) {
        prefs.edit().putBoolean("record_" + id + "_completed", completed).apply();
    }

    public void deleteRecord(long id) {
        prefs.edit().remove("record_" + id + "_core")
            .remove("record_" + id + "_title")
            .remove("record_" + id + "_amount_bits")
            .remove("record_" + id + "_day")
            .remove("record_" + id + "_completed").apply();
    }

    /** User-controlled local data reset. Profile and all LifeOS records are removed. */
    public void clearAllLocalData() { prefs.edit().clear().apply(); }
    public void close() { }
}
