package com.allinmyday;

import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

/** Local Allinmyday-owned storage using the Android platform SQLite API. */
public final class AllinmydayStore extends SQLiteOpenHelper {
    private static final String DB_NAME = "allinmyday.db";
    private static final int DB_VERSION = 1;

    public AllinmydayStore(Context context) { super(context, DB_NAME, null, DB_VERSION); }

    @Override public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, core TEXT NOT NULL, title TEXT NOT NULL, amount REAL DEFAULT 0, day INTEGER NOT NULL, completed INTEGER DEFAULT 0)");
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_records_core_day ON records(core, day)");
    }

    @Override public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // Future schema migrations are kept inside Allinmyday; existing data is never
        // discarded automatically.
    }

    public long addRecord(String core, String title, double amount, long day, boolean completed) {
        ContentValues values = new ContentValues();
        values.put("core", core); values.put("title", title); values.put("amount", amount);
        values.put("day", day); values.put("completed", completed ? 1 : 0);
        return getWritableDatabase().insert("records", null, values);
    }
}
