package com.allinmyday;

/** Stable local backup contract. Cloud sync can consume this format later without changing app records. */
public final class BackupFormat {
    public static final String VERSION = "ALLINMYDAY_BACKUP_V1";
    public static final String PRODUCT = "Allinmyday";
    private BackupFormat() {}

    public static String header() {
        return VERSION + "\nproduct=" + PRODUCT + "\n";
    }
}
