package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * User-triggered iamyansi voice surface. No permanent orb and no continuous microphone listener.
 * Spoken input is understood locally, then reviewed before a record is created.
 */
public final class IamyansiVoiceActivity extends Activity {
    private AllinmydayStore store;
    private TextView status;
    private final int green = Color.rgb(55,96,61);
    private final int ink = Color.rgb(42,55,45);
    private final int muted = Color.rgb(100,112,103);
    private final int bg = Color.rgb(248,250,247);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        store = new AllinmydayStore(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setGravity(Gravity.CENTER_HORIZONTAL);
        root.setPadding(28,40,28,28); root.setBackgroundColor(bg);
        TextView title = new TextView(this); title.setText("iamyansi"); title.setTextSize(26); title.setTextColor(ink); title.setTypeface(null,1); root.addView(title);
        TextView subtitle = new TextView(this); subtitle.setText("Ambient intelligence • voice only when you ask"); subtitle.setTextSize(13); subtitle.setTextColor(muted); root.addView(subtitle);
        status = new TextView(this); status.setText("Ready when you are."); status.setTextSize(16); status.setTextColor(green); status.setGravity(Gravity.CENTER); root.addView(status, new LinearLayout.LayoutParams(-1,100));
        Button speak = new Button(this); speak.setText("Speak to iamyansi"); speak.setAllCaps(false); speak.setTextColor(Color.WHITE); speak.setBackgroundColor(green); speak.setOnClickListener(v -> startActivityForResult(IamyansiVoiceBridge.createIntent(), IamyansiVoiceBridge.REQUEST_CODE)); root.addView(speak, new LinearLayout.LayoutParams(-1,58));
        TextView privacy = new TextView(this); privacy.setText("Microphone starts only after you tap. iamyansi does not remain as a visible circle."); privacy.setTextSize(11); privacy.setTextColor(muted); privacy.setGravity(Gravity.CENTER); root.addView(privacy, new LinearLayout.LayoutParams(-1,60));
        setContentView(root);
    }

    @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode != IamyansiVoiceBridge.REQUEST_CODE || resultCode != RESULT_OK) return;
        String spoken = IamyansiVoiceBridge.firstResult(data);
        IamyansiPlanner.Plan plan = IamyansiPlanner.plan(spoken);
        if (spoken.isEmpty() || plan.proposal.core.isEmpty()) { status.setText("I didn't understand that. Please try again."); return; }
        status.setText("Understanding…");
        String amount = plan.proposal.amount == 0 ? "" : " • amount " + plan.proposal.amount;
        new AlertDialog.Builder(this)
            .setTitle("iamyansi understood")
            .setMessage(plan.proposal.core + amount + "\n\n\"" + spoken + "\"\n\n" + plan.decision.message)
            .setNegativeButton("Cancel", (d,w) -> status.setText("Cancelled."))
            .setPositiveButton(plan.decision.requiresConfirmation ? "Confirm & Save" : "Save", (d,w) -> {
                store.addRecord(plan.proposal.core, spoken, plan.proposal.amount, System.currentTimeMillis(), false);
                status.setText("Done. Added to " + plan.proposal.core + ".");
            }).show();
    }
}
