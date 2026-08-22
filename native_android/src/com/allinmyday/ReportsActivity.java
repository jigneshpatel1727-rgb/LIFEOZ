package com.allinmyday;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Cross-core local report. No external analytics service. */
public final class ReportsActivity extends Activity {
    private AllinmydayStore store;
    private final int green = Color.rgb(55, 96, 61);
    private final int ink = Color.rgb(42, 55, 45);
    private final int muted = Color.rgb(100, 112, 103);
    private final int bg = Color.rgb(248, 250, 247);
    private final int card = Color.rgb(255, 255, 253);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        store = new AllinmydayStore(this);
        getWindow().setNavigationBarColor(bg);
        getWindow().setStatusBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(24, 28, 24, 24);
        root.setBackgroundColor(bg);
        addText(root, "ALLINMYDAY", 28, green, true);
        addText(root, "Reports & Insights", 24, ink, true);
        addText(root, "One screen • One report • Local data", 12, muted, false);
        addText(root, "\nUser: " + store.getName(), 15, ink, false);

        String[] cores = {"Expenses", "Goals", "Tasks", "Household", "Calendar"};
        for (String core : cores) {
            CoreReport report = CoreReport.from(store, core);
            LinearLayout row = new LinearLayout(this);
            row.setOrientation(LinearLayout.VERTICAL);
            row.setPadding(16, 12, 16, 12);
            row.setBackgroundColor(card);
            addText(row, core, 17, ink, true);
            addText(row, "Items: " + report.itemCount + "   Completed: " + report.completedCount + "   Progress: " + report.completionPercent() + "%", 12, muted, false);
            addText(row, "Value: " + format(report.totalAmount), 14, green, false);
            LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2);
            p.topMargin = 8;
            root.addView(row, p);
        }

        addText(root, "\nPrivacy: report calculations are performed locally on this device.", 11, muted, false);
        setContentView(root);
    }

    private void addText(LinearLayout root, String value, float size, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(value); t.setTextSize(size); t.setTextColor(color); t.setPadding(0, 4, 0, 4);
        if (bold) t.setTypeface(null, android.graphics.Typeface.BOLD);
        root.addView(t);
    }

    private String format(double value) {
        if (store.getCurrency().startsWith("INR")) return "₹" + String.format(java.util.Locale.US, "%.2f", value);
        return String.format(java.util.Locale.US, "%.2f", value);
    }
}
