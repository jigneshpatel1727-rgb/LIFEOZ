package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Receipt capture foundation. Camera capture is user initiated; OCR remains a future native module. */
public final class ReceiptScanActivity extends Activity {
    private static final int REQUEST_CAMERA = 4201;
    private Uri outputUri;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(24, 32, 24, 24); root.setBackgroundColor(Color.rgb(248,250,247));
        TextView title = new TextView(this); title.setText("Receipt & Grocery Capture"); title.setTextSize(25); title.setTextColor(Color.rgb(42,55,45)); title.setTypeface(null, 1); root.addView(title);
        TextView note = new TextView(this); note.setText("Capture a bill with your camera. Allinmyday will later read items and prices locally before saving them to Household or Expenses."); note.setTextSize(14); note.setTextColor(Color.rgb(100,112,103)); root.addView(note);
        Button camera = new Button(this); camera.setText("Open Camera"); camera.setAllCaps(false); camera.setTextColor(Color.WHITE); camera.setBackgroundColor(Color.rgb(55,96,61));
        camera.setOnClickListener(v -> openCamera()); root.addView(camera, new LinearLayout.LayoutParams(-1,58) {{ topMargin = 24; }});
        TextView privacy = new TextView(this); privacy.setText("Camera opens only after you choose it. No automatic capture."); privacy.setTextSize(11); privacy.setTextColor(Color.rgb(100,112,103)); root.addView(privacy);
        setContentView(root);
    }

    private void openCamera() {
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (intent.resolveActivity(getPackageManager()) != null) startActivityForResult(intent, REQUEST_CAMERA);
        else new AlertDialog.Builder(this).setMessage("No camera application is available on this device.").setPositiveButton("OK", null).show();
    }
}
