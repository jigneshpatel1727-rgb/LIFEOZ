package com.allinmyday;

import android.app.Activity;
import android.content.Intent;

/** Platform-only helper for opening the user-triggered iamyansi voice flow. */
public final class IamyansiVoiceLauncher {
    private IamyansiVoiceLauncher() {}

    public static void open(Activity activity) {
        if (activity == null) return;
        activity.startActivity(new Intent(activity, IamyansiVoiceActivity.class));
    }
}
