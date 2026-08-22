package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

/** Secondary LifeOS tools: diary, investments and health. Data stays local. */
public final class LifeToolsActivity extends Activity {
    private AllinmydayStore store;
    private final int green = Color.rgb(55, 96, 61);
    private final int ink = Color.rgb(42, 55, 45);
    private final int muted = Color.rgb(100, 112, 103);
    private final int bg = Color.rgb(248, 250, 247);
    private final int card = Color.rgb(255, 255, 253);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        store = new AllinmydayStore(this);
        render();
    }

    private void render() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(24, 28, 24, 24); root.setBackgroundColor(bg);
        add(root, "ALLINMYDAY", 28, green, true); add(root, "Life Tools", 24, ink, true);
        add(root, "Diary • Investments • Health", 12, muted, false);
        addTool(root, "Diary", "Daily personal diary • later voice-to-text", "Diary");
        addTool(root, "Investments", "Shares • mutual funds • SIP • value tracking", "Investments");
        addTool(root, "Health", "Steps • heart • sleep • device data foundation", "Health");
        add(root, "\nYour information is stored locally for this trial.", 11, muted, false);
        setContentView(new ScrollView(this) {{ addView(root); }});
    }

    private void addTool(LinearLayout root, String title, String subtitle, String core) {
        LinearLayout cardView = new LinearLayout(this); cardView.setOrientation(LinearLayout.VERTICAL); cardView.setPadding(16, 14, 16, 14); cardView.setBackgroundColor(card);
        add(cardView, title, 18, ink, true); add(cardView, subtitle, 12, muted, false);
        Button open = new Button(this); open.setText("Open"); open.setAllCaps(false); open.setTextColor(green); open.setOnClickListener(v -> showTool(core)); cardView.addView(open);
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2); p.topMargin = 10; root.addView(cardView, p);
    }

    private void showTool(String core) {
        CoreReport report = CoreReport.from(store, core);
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(24, 8, 24, 8);
        add(box, core, 23, ink, true); add(box, "Items: " + report.itemCount + " • Progress: " + report.completionPercent() + "%", 12, muted, false);
        if (report.records.isEmpty()) add(box, "No records yet.", 13, muted, false);
        else for (AllinmydayStore.Record r : report.records) add(box, "• " + r.title + (r.amount == 0 ? "" : "  " + format(r.amount)), 14, ink, false);
        Button addButton = new Button(this); addButton.setText("+ Add"); addButton.setAllCaps(false); addButton.setTextColor(Color.WHITE); addButton.setBackgroundColor(green); addButton.setOnClickListener(v -> addRecord(core)); box.addView(addButton);
        new AlertDialog.Builder(this).setView(box).setPositiveButton("Close", null).show();
    }

    private void addRecord(String core) {
        EditText title = new EditText(this); title.setHint(core.equals("Diary") ? "Write today's entry" : core.equals("Investments") ? "Fund / share / SIP" : "Health note or metric");
        EditText amount = new EditText(this); amount.setHint(core.equals("Investments") ? "Current value (optional)" : "Value (optional)");
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(24, 8, 24, 8); box.addView(title); box.addView(amount);
        new AlertDialog.Builder(this).setTitle("Add " + core).setView(box).setNegativeButton("Cancel", null).setPositiveButton("Save", (d,w) -> {
            String t = title.getText().toString().trim(); if (t.isEmpty()) { title.setError("Enter something first"); return; }
            double a = 0; try { if (!amount.getText().toString().trim().isEmpty()) a = Double.parseDouble(amount.getText().toString().trim()); } catch(Exception ignored) {}
            store.addRecord(core, t, a, System.currentTimeMillis(), false); showTool(core);
        }).show();
    }

    private String format(double value) { return store.getCurrency().startsWith("INR") ? "₹" + String.format(java.util.Locale.US, "%.2f", value) : String.format(java.util.Locale.US, "%.2f", value); }

    private void add(LinearLayout root, String value, float size, int color, boolean bold) {
        TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color); t.setPadding(0, 5, 0, 5); if (bold) t.setTypeface(null, android.graphics.Typeface.BOLD); root.addView(t);
    }
}
