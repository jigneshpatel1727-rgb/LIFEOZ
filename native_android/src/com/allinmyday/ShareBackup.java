package com.allinmyday;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

/** Uses Android's standard share/save chooser; no sharing provider is bundled or required. */
public final class ShareBackup {
    private ShareBackup() {}

    public static Intent create(String backupText) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_SUBJECT, "Allinmyday backup");
        intent.putExtra(Intent.EXTRA_TEXT, backupText == null ? "" : backupText);
        return Intent.createChooser(intent, "Save or share Allinmyday backup");
    }
}
