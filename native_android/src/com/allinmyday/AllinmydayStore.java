package com.allinmyday;

import android.content.Context;
import android.content.SharedPreferences;

/** Local Allinmyday-owned profile and records. No third-party database. */
public final class AllinmydayStore {
    private static final String PREFS = "allinmyday_store";
    private final SharedPreferences prefs;

    public AllinmydayStore(Context context) { prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE); }
    public boolean hasProfile() { return !prefs.getString("profile_name", "").trim().isEmpty(); }
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
            .putString("profile_theme", theme == null ? "Nature Green" : theme).apply();
    }
    public long addRecord(String core, String title, double amount, long day, boolean completed) {
        long id = prefs.getLong("next_id", 1L), base = id;
        prefs.edit().putString("record_" + base + "_core", core == null ? "" : core)
            .putString("record_" + base + "_title", title == null ? "" : title)
            .putLong("record_" + base + "_amount_bits", Double.doubleToLongBits(amount))
            .putLong("record_" + base + "_day", day)
            .putBoolean("record_" + base + "_completed", completed)
            .putLong("next_id", id + 1L).apply();
        return base;
    }
    public void close() { }
}
