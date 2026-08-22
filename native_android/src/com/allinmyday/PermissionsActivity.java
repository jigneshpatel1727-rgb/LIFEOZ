package com.allinmyday;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/** User-controlled runtime permissions. No third-party permission library. */
public final class PermissionsActivity extends Activity {
    private final int REQ_AUDIO = 101;
    private final int REQ_NOTIFICATIONS = 102;
    private final int green = Color.rgb(55, 96, 61);
    private final int ink = Color.rgb(42, 55, 45);
    private final int muted = Color.rgb(100, 112, 103);
    private final int bg = Color.rgb(248, 250, 247);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        render();
    }

    private void render() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(24, 28, 24, 24); root.setBackgroundColor(bg);
        add(root, "ALLINMYDAY", 28, green, true); add(root, "Permissions", 24, ink, true);
        add(root, "You decide what Allinmyday and iamyansi may access.", 13, muted, false);

        addPermission(root, "Microphone", "Required for voice input and future ambient iamyansi listening.", Manifest.permission.RECORD_AUDIO, REQ_AUDIO);
        if (Build.VERSION.SDK_INT >= 33) addPermission(root, "Notifications", "Required for reminders and permitted background alerts.", Manifest.permission.POST_NOTIFICATIONS, REQ_NOTIFICATIONS);
        else add(root, "Notifications", 16, ink, true);

        add(root, "Sensitive actions remain confirmation-controlled. Permissions can be changed later in Android Settings.", 11, muted, false);
        setContentView(root);
    }

    private void addPermission(LinearLayout root, String title, String description, String permission, int requestCode) {
        add(root, title, 17, ink, true); add(root, description, 12, muted, false);
        Button b = new Button(this); b.setAllCaps(false); b.setText(isGranted(permission) ? "Granted" : "Allow"); b.setTextColor(isGranted(permission) ? green : Color.WHITE); b.setBackgroundColor(isGranted(permission) ? Color.rgb(232, 240, 232) : green);
        b.setOnClickListener(v -> { if (!isGranted(permission)) requestPermissions(new String[]{permission}, requestCode); else render(); }); root.addView(b);
    }

    private boolean isGranted(String permission) { return Build.VERSION.SDK_INT < 23 || checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED; }

    @Override public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) { super.onRequestPermissionsResult(requestCode, permissions, grantResults); render(); }

    private void add(LinearLayout root, String value, float size, int color, boolean bold) { TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color); t.setPadding(0, 5, 0, 5); if (bold) t.setTypeface(null, android.graphics.Typeface.BOLD); root.addView(t); }
}
