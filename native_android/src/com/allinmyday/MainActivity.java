package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import java.text.DateFormat;
import java.util.Date;

/**
 * Allinmyday native application surface.
 * iamyansi is invisible/ambient; it is never rendered as a permanent orb, label, or chatbot.
 */
public final class MainActivity extends Activity {
    private IamyansiCore iamyansi;
    private AllinmydayStore store;
    private final int green = Color.rgb(55, 96, 61);
    private final int green2 = Color.rgb(79, 122, 83);
    private final int ink = Color.rgb(42, 55, 45);
    private final int muted = Color.rgb(100, 112, 103);
    private final int bg = Color.rgb(248, 250, 247);
    private final int card = Color.rgb(255, 255, 253);

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setNavigationBarColor(bg);
        getWindow().setStatusBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        iamyansi = new IamyansiCore();
        store = new AllinmydayStore(this);
        if (store.hasProfile()) showHome(); else showOnboarding();
    }

    private TextView text(String value, float size, int color) {
        TextView t = new TextView(this);
        t.setText(value); t.setTextSize(size); t.setTextColor(color);
        t.setPadding(0, 5, 0, 5); return t;
    }

    private Button primary(String value) {
        Button b = new Button(this); b.setText(value); b.setTextColor(Color.WHITE);
        b.setTextSize(15); b.setAllCaps(false); b.setBackgroundColor(green); return b;
    }

    private Button secondary(String value) {
        Button b = new Button(this); b.setText(value); b.setTextColor(green);
        b.setTextSize(14); b.setAllCaps(false); b.setBackgroundColor(Color.rgb(232, 240, 232)); return b;
    }

    private LinearLayout page() {
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(24, 28, 24, 24); root.setBackgroundColor(bg); return root;
    }

    private ScrollView scroll(LinearLayout root) {
        ScrollView s = new ScrollView(this); s.addView(root); return s;
    }

    private void showOnboarding() {
        LinearLayout root = page();
        TextView brand = text("ALLINMYDAY", 30, green); brand.setTypeface(null, android.graphics.Typeface.BOLD); root.addView(brand);
        root.addView(text("One screen. One tap. One report.", 13, muted));
        root.addView(text("\nWelcome to your LifeOS", 25, ink));
        root.addView(text("Create your private profile. Your trial data stays on this device.", 14, muted));

        EditText name = new EditText(this); name.setHint("Your name"); root.addView(name);
        EditText email = new EditText(this); email.setHint("Email (optional)");
        email.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS); root.addView(email);
        root.addView(text("Currency", 14, muted));
        Spinner currency = new Spinner(this); currency.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item,
            new String[]{"INR (₹)", "USD ($)", "EUR (€)", "GBP (£)", "AED (د.إ)"})); root.addView(currency);
        root.addView(text("Language", 14, muted));
        Spinner language = new Spinner(this); language.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item,
            new String[]{"English", "Hindi", "Gujarati"})); root.addView(language);
        root.addView(text("Theme", 14, muted));
        Spinner theme = new Spinner(this); theme.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item,
            new String[]{"Nature Green", "Ocean Blue", "Sunset Orange", "Midnight Dark", "Lavender Purple", "Minimal White"})); root.addView(theme);

        Button continueButton = primary("Create profile & Continue");
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(-1, 58); cp.topMargin = 24; root.addView(continueButton, cp);
        continueButton.setOnClickListener(v -> {
            String n = name.getText().toString().trim();
            if (n.isEmpty()) { name.setError("Enter your name"); return; }
            store.saveProfile(n, email.getText().toString(), currency.getSelectedItem().toString(),
                    language.getSelectedItem().toString(), theme.getSelectedItem().toString());
            showHome();
        });
        setContentView(scroll(root));
    }

    private void showHome() {
        LinearLayout root = page();
        LinearLayout header = new LinearLayout(this); header.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout titles = new LinearLayout(this); titles.setOrientation(LinearLayout.VERTICAL);
        titles.addView(text("ALLINMYDAY", 25, green));
        titles.addView(text("One screen. One tap. One report.", 11, muted));
        header.addView(titles, new LinearLayout.LayoutParams(0, -2, 1));
        Button profile = secondary("Profile"); profile.setOnClickListener(v -> showProfile()); header.addView(profile);
        root.addView(header);

        root.addView(text("\nGood day, " + store.getName(), 23, ink));
        root.addView(text("Your life, organized quietly.", 13, muted));
        root.addView(text("\nYOUR FIVE CORES", 13, green));

        addCore(root, "Expenses", "Track • analyze • save smarter", "₹", 0);
        addCore(root, "Goals", "Plan • achieve • grow", "◎", 1);
        addCore(root, "Tasks", "Organize • focus • complete", "✓", 2);
        addCore(root, "Household", "Daily needs • shopping list", "□", 3);
        addCore(root, "Calendar", "Bills • renewals • important dates", "□", 4);

        TextView privacy = text("Private by design • Works offline • You control permissions", 11, muted);
        privacy.setGravity(Gravity.CENTER); root.addView(privacy, new LinearLayout.LayoutParams(-1, 40) {{ topMargin = 14; }});

        Button settings = secondary("Settings & Privacy"); settings.setOnClickListener(v -> showSettings());
        root.addView(settings, new LinearLayout.LayoutParams(-1, 52) {{ topMargin = 8; }});
        setContentView(scroll(root));
    }

    private void addCore(LinearLayout root, String title, String subtitle, String icon, int index) {
        LinearLayout row = new LinearLayout(this); row.setGravity(Gravity.CENTER_VERTICAL); row.setPadding(16, 12, 10, 12); row.setBackgroundColor(card);
        TextView symbol = text(icon, 25, green); symbol.setGravity(Gravity.CENTER); row.addView(symbol, new LinearLayout.LayoutParams(48, 60));
        LinearLayout words = new LinearLayout(this); words.setOrientation(LinearLayout.VERTICAL);
        words.addView(text(title, 17, ink)); words.addView(text(subtitle, 11, muted));
        row.addView(words, new LinearLayout.LayoutParams(0, -2, 1));
        Button open = secondary("Open"); open.setOnClickListener(v -> openCore(index)); row.addView(open);
        LinearLayout.LayoutParams rp = new LinearLayout.LayoutParams(-1, 76); rp.topMargin = 8; root.addView(row, rp);
    }

    private void showProfile() {
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(30, 18, 30, 8);
        box.addView(text("Your Profile", 25, ink));
        box.addView(text("Name: " + store.getName(), 16, muted));
        box.addView(text("Email: " + (store.getEmail().isEmpty() ? "Not added" : store.getEmail()), 16, muted));
        box.addView(text("Currency: " + store.getCurrency(), 16, muted));
        box.addView(text("Language: " + store.getLanguage(), 16, muted));
        box.addView(text("Theme: " + store.getTheme(), 16, muted));
        new AlertDialog.Builder(this).setView(box).setPositiveButton("Edit", (d,w) -> showOnboarding()).setNegativeButton("Close", null).show();
    }

    private void showSettings() {
        new AlertDialog.Builder(this)
            .setTitle("Allinmyday Settings")
            .setItems(new String[]{"Profile", "Permissions", "Privacy & local data", "iamyansi controls", "Theme", "Reset local data"}, (d, which) -> {
                if (which == 0) showProfile();
                else if (which == 1) showInfo("Permissions", "You control what Allinmyday and iamyansi can access. Sensitive actions require confirmation.");
                else if (which == 2) showInfo("Privacy", "Trial data is stored locally through Android platform storage. No external database is used.");
                else if (which == 3) showInfo("iamyansi", "iamyansi is ghost/ambient intelligence. It works behind the interface and is not a permanent on-screen chatbot or circle.");
                else if (which == 4) showOnboarding();
                else confirmReset();
            }).setNegativeButton("Close", null).show();
    }

    private void confirmReset() {
        new AlertDialog.Builder(this).setTitle("Delete local data?")
            .setMessage("This removes the local profile and all saved LifeOS records from this device.")
            .setNegativeButton("Cancel", null).setPositiveButton("Delete", (d,w) -> {
                store.clearAllLocalData(); showOnboarding();
            }).show();
    }

    private void showInfo(String title, String message) {
        new AlertDialog.Builder(this).setTitle(title).setMessage(message).setPositiveButton("OK", null).show();
    }

    private void openCore(int index) {
        final String[] cores = {"Expenses", "Goals", "Tasks", "Household", "Calendar"};
        showCoreReport(cores[index]);
    }

    /** One-screen report shared by all five cores. */
    private void showCoreReport(String core) {
        CoreReport report = CoreReport.from(store, core);
        LinearLayout root = page();
        LinearLayout header = new LinearLayout(this); header.setGravity(Gravity.CENTER_VERTICAL);
        Button back = secondary("‹ Back"); back.setOnClickListener(v -> showHome()); header.addView(back, new LinearLayout.LayoutParams(90, 50));
        header.addView(text(core, 24, ink), new LinearLayout.LayoutParams(0, -2, 1));
        root.addView(header);

        root.addView(text("\nONE SCREEN • ONE REPORT", 11, green));
        root.addView(text("Items: " + report.itemCount + "    Completed: " + report.completedCount + "    Progress: " + report.completionPercent() + "%", 15, ink));
        root.addView(text("Total value: " + formatAmount(report.totalAmount), 18, green));

        Button add = primary("+ Add");
        add.setOnClickListener(v -> showAddRecord(core));
        root.addView(add, new LinearLayout.LayoutParams(-1, 54) {{ topMargin = 14; }});

        if (report.records.isEmpty()) {
            root.addView(text("\nNothing recorded yet. Add your first item and it will stay on this device.", 14, muted));
        } else {
            root.addView(text("\nRecent records", 14, green));
            for (AllinmydayStore.Record record : report.records) addRecordRow(root, core, record);
        }
        setContentView(scroll(root));
    }

    private String formatAmount(double amount) {
        if (amount == 0) return store.getCurrency().startsWith("INR") ? "₹0" : "0";
        return store.getCurrency().startsWith("INR") ? "₹" + String.format(java.util.Locale.US, "%.2f", amount) : String.format(java.util.Locale.US, "%.2f", amount);
    }

    private void addRecordRow(LinearLayout root, String core, AllinmydayStore.Record record) {
        LinearLayout row = new LinearLayout(this); row.setOrientation(LinearLayout.VERTICAL); row.setPadding(16, 10, 12, 10); row.setBackgroundColor(card);
        String date = record.day == 0 ? "" : DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT).format(new Date(record.day));
        row.addView(text(record.title, 16, ink));
        String detail = (record.amount == 0 ? "" : formatAmount(record.amount) + " • ") + date + (record.completed ? " • Completed" : " • Pending");
        row.addView(text(detail, 11, muted));
        LinearLayout actions = new LinearLayout(this); actions.setGravity(Gravity.RIGHT);
        Button done = secondary(record.completed ? "Undo" : "Done");
        done.setOnClickListener(v -> { store.setCompleted(record.id, !record.completed); showCoreReport(core); });
        Button delete = secondary("Delete");
        delete.setOnClickListener(v -> { store.deleteRecord(record.id); showCoreReport(core); });
        actions.addView(done, new LinearLayout.LayoutParams(90, 44));
        actions.addView(delete, new LinearLayout.LayoutParams(90, 44) {{ leftMargin = 8; }});
        row.addView(actions);
        root.addView(row, new LinearLayout.LayoutParams(-1, -2) {{ topMargin = 8; }});
    }

    private void showAddRecord(String core) {
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(24, 8, 24, 4);
        EditText title = new EditText(this); title.setHint(core.equals("Calendar") ? "Event / due date" : core.equals("Household") ? "Shopping item" : core.equals("Goals") ? "Goal" : core.equals("Tasks") ? "Task" : "Expense / description"); title.setSingleLine(true); box.addView(title);
        EditText amount = new EditText(this); amount.setHint("Amount (optional)"); amount.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL); amount.setSingleLine(true); box.addView(amount);
        new AlertDialog.Builder(this).setTitle("Add to " + core).setView(box).setNegativeButton("Cancel", null).setPositiveButton("Save", (d,w) -> {
            String t = title.getText().toString().trim();
            if (t.isEmpty()) { Toast.makeText(this, "Enter something first", Toast.LENGTH_SHORT).show(); return; }
            double a = 0; try { if (!amount.getText().toString().trim().isEmpty()) a = Double.parseDouble(amount.getText().toString().trim()); } catch(Exception ignored) {}
            store.addRecord(core, t, a, System.currentTimeMillis(), false);
            showCoreReport(core);
        }).show();
    }

    @Override protected void onDestroy() { if (store != null) store.close(); super.onDestroy(); }
}
