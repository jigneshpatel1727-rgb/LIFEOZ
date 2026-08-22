package com.allinmyday;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Backup is explicitly user initiated and stays on the device until the user chooses where to share/save it. */
public final class LocalBackupActivity extends Activity {
    private AllinmydayStore store;
    private TextView preview;
    private final int green = Color.rgb(55,96,61);
    private final int ink = Color.rgb(42,55,45);
    private final int muted = Color.rgb(100,112,103);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        store = new AllinmydayStore(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(24,32,24,24); root.setBackgroundColor(Color.rgb(248,250,247));
        TextView title = new TextView(this); title.setText("Local Backup"); title.setTextSize(26); title.setTextColor(ink); title.setTypeface(null,1); root.addView(title);
        TextView info = new TextView(this); info.setText("Create a portable backup of your Allinmyday profile and local records. Nothing is uploaded automatically."); info.setTextSize(14); info.setTextColor(muted); root.addView(info);
        Button generate = new Button(this); generate.setText("Generate backup"); generate.setAllCaps(false); generate.setTextColor(Color.WHITE); generate.setBackgroundColor(green);
        generate.setOnClickListener(v -> { preview.setText(LocalBackup.export(store)); }); root.addView(generate, new LinearLayout.LayoutParams(-1,58) {{ topMargin=22; }});
        preview = new TextView(this); preview.setText("Backup preview will appear here."); preview.setTextSize(11); preview.setTextColor(muted); preview.setGravity(Gravity.TOP); root.addView(preview, new LinearLayout.LayoutParams(-1,0,1));
        setContentView(root);
    }
}
