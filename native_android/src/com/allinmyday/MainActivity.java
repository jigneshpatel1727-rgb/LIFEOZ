package com.allinmyday;

import android.app.Activity;
import android.app.AlertDialog;
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

import java.text.DateFormat;
import java.util.Date;

/**
 * Allinmyday native application surface.
 * iamyansi is invisible/ambient; it is never rendered as a permanent orb, label, or chatbot.
 */
public final class MainActivity extends Activity {
    private IamyansiCore iamyansi;
    private AllinmydayStore store;

    private int green;
    private int ink;
    private int muted;
    private int bg;
    private int card;
    private boolean darkTheme;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        store = new AllinmydayStore(this);
        iamyansi = new IamyansiCore();
        applyTheme(store.getTheme());
        if (store.hasProfile() && store.hasLoginPin()) showLogin();
        else showOnboarding();
    }

    private void applyTheme(String theme) {
        if ("Ocean Blue".equals(theme)) {
            green = Color.rgb(35, 91, 130); ink = Color.rgb(32, 50, 64); muted = Color.rgb(90, 108, 122);
            bg = Color.rgb(244, 249, 252); card = Color.WHITE; darkTheme = false;
        } else if ("Sunset Orange".equals(theme)) {
            green = Color.rgb(179, 95, 50); ink = Color.rgb(68, 52, 44); muted = Color.rgb(112, 98, 88);
            bg = Color.rgb(255, 248, 242); card = Color.WHITE; darkTheme = false;
        } else if ("Midnight Dark".equals(theme)) {
            green = Color.rgb(126, 108, 196); ink = Color.rgb(240, 242, 248); muted = Color.rgb(169, 175, 188);
            bg = Color.rgb(15, 18, 28); card = Color.rgb(27, 31, 44); darkTheme = true;
        } else if ("Lavender Purple".equals(theme)) {
            green = Color.rgb(113, 93, 150); ink = Color.rgb(52, 45, 65); muted = Color.rgb(105, 98, 118);
            bg = Color.rgb(249, 247, 252); card = Color.WHITE; darkTheme = false;
        } else if ("Minimal White".equals(theme)) {
            green = Color.rgb(70, 78, 78); ink = Color.rgb(40, 45, 45); muted = Color.rgb(105, 108, 108);
            bg = Color.rgb(252, 252, 250); card = Color.WHITE; darkTheme = false;
        } else {
            green = Color.rgb(55, 96, 61); ink = Color.rgb(42, 55, 45); muted = Color.rgb(100, 112, 103);
            bg = Color.rgb(248, 250, 247); card = Color.rgb(255, 255, 253); darkTheme = false;
        }
        getWindow().setNavigationBarColor(bg);
        getWindow().setStatusBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(darkTheme ? 0 : View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
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
        b.setTextSize(14); b.setAllCaps(false);
        b.setBackgroundColor(darkTheme ? Color.rgb(42, 48, 63) : Color.rgb(232, 240, 232)); return b;
    }

    private LinearLayout page() {
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(24, 28, 24, 24); root.setBackgroundColor(bg); return root;
    }

    private ScrollView scroll(LinearLayout root) {
        ScrollView s = new ScrollView(this); s.addView(root); return s;
    }

    private TextView brand() {
        TextView brand = text("ALLINMYDAY", 30, green);
        brand.setTypeface(null, android.graphics.Typeface.BOLD);
        brand.setGravity(Gravity.CENTER);
        return brand;
    }

    private void showOnboarding() {
        LinearLayout root = page();
        root.addView(brand());
        TextView motto = text("One screen. One tap. One report.", 13, muted); motto.setGravity(Gravity.CENTER); root.addView(motto);
        root.addView(text("\nCreate your private profile", 25, ink));
        root.addView(text("Allinmyday works locally. No external database is required for this trial.", 14, muted));

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

        root.addView(text("Local login PIN", 14, muted));
        EditText pin = new EditText(this); pin.setHint("4–8 digit PIN");
        pin.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_VARIATION_PASSWORD); root.addView(pin);
        EditText confirm = new EditText(this); confirm.setHint("Confirm PIN");
        confirm.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_VARIATION_PASSWORD); root.addView(confirm);
        root.addView(text("This is a local device login gate, not a cloud account.", 11, muted));

        Button create = primary("Create profile & Continue");
        root.addView(create, new LinearLayout.LayoutParams(-1, 58) {{ topMargin = 22; }});
        create.setOnClickListener(v -> {
            String n = name.getText().toString().trim();
            String p = pin.getText().toString().trim();
            String c = confirm.getText().toString().trim();
            if (n.isEmpty()) { name.setError("Enter your name"); return; }
            if (p.length() < 4 || p.length() > 8) { pin.setError("Use 4–8 digits"); return; }
            if (!p.equals(c)) { confirm.setError("PINs do not match"); return; }
            store.saveProfile(n, email.getText().toString(), currency.getSelectedItem().toString(),
                    language.getSelectedItem().toString(), theme.getSelectedItem().toString(), p);
            applyTheme(store.getTheme());
            showHome();
        });

        if (store.hasProfile()) {
            Button back = secondary("Back to login");
            back.setOnClickListener(v -> showLogin());
            root.addView(back, new LinearLayout.LayoutParams(-1, 52) {{ topMargin = 8; }});
        }
        setContentView(scroll(root));
    }

    private void showLogin() {
        applyTheme(store.getTheme());
        LinearLayout root = page();
        root.addView(brand());
        TextView motto = text("One screen. One tap. One report.", 13, muted); motto.setGravity(Gravity.CENTER); root.addView(motto);
        root.addView(text("\nWelcome back", 27, ink));
        root.addView(text(store.getName(), 18, green));
        root.addView(text("Enter your local PIN to open Allinmyday.", 14, muted));

        EditText pin = new EditText(this); pin.setHint("PIN");
        pin.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_VARIATION_PASSWORD); root.addView(pin);
        Button login = primary("Sign in"); root.addView(login, new LinearLayout.LayoutParams(-1, 58) {{ topMargin = 18; }});
        login.setOnClickListener(v -> {
            if (store.verifyLoginPin(pin.getText().toString())) showHome();
            else pin.setError("Incorrect PIN");
        });
        Button useDifferent = secondary("Create / use a different local profile");
        useDifferent.setOnClickListener(v -> showOnboarding());
        root.addView(useDifferent, new LinearLayout.LayoutParams(-1, 52) {{ topMargin = 8; }});
        root.addView(text("Your profile and trial records remain on this device.", 11, muted), new LinearLayout.LayoutParams(-1, 40) {{ topMargin = 18; }});
        setContentView(root);
    }

    private void showHome() {
        applyTheme(store.getTheme());
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
        box.addView(text("Local login: Enabled", 16, muted));
        new AlertDialog.Builder(this).setView(box).setPositiveButton("Edit", (d,w) -> showOnboarding()).setNegativeButton("Close", null).show();
    }

    private void showSettings() {
        new AlertDialog.Builder(this)
            .setTitle("Allinmyday Settings")
            .setItems(new String[]{"Profile", "Permissions", "Privacy & local data", "iamyansi controls", "Theme", "Lock app", "Reset local data"}, (d, which) -> {
                if (which == 0) showProfile();
                else if (which == 1) showInfo("Permissions", "You control what Allinmyday and iamyansi can access. Sensitive actions require confirmation.");
                else if (which == 2) showInfo("Privacy", "Trial data is stored locally through Android platform storage. No external database is used.");
                else if (which == 3) showInfo("iamyansi", "iamyansi is ghost/ambient intelligence. It works behind the interface and is not a permanent on-screen chatbot or circle.");
                else if (which == 4) showOnboarding();
                else if (which == 5) showLogin();
                else confirmReset();
            }).setNegativeButton("Close", null).show();
    }

    private void confirmReset() {
        new AlertDialog.Builder(this).setTitle("Delete local data?")
            .setMessage("This removes the local profile, login gate and all saved LifeOS records from this device.")
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
        header.addView(text(core, 24, ink), new LinearLayout.LayoutParams(0, -2, 1)); root.addView(header);
        root.addView(text("\nONE SCREEN • ONE REPORT", 11, green));
        root.addView(text("Items: " + report.itemCount + "    Completed: " + report.completedCount + "    Progress: " + report.completionPercent() + "%", 15, ink));
        root.addView(text("Total value: " + formatAmount(report.totalAmount), 18, green));
        Button add = primary("+ Add"); add.setOnClickListener(v -> showAddRecord(core));
        root.addView(add, new LinearLayout.LayoutParams(-1, 54) {{ topMargin = 14; }});
        if (report.records.isEmpty()) root.addView(text("\nNothing recorded yet. Add your first item and it will stay on this device.", 14, muted));
        else {
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
        row.addView(text((record.amount == 0 ? "" : formatAmount(record.amount) + " • ") + date + (record.completed ? " • Completed" : " • Pending"), 11, muted));
        LinearLayout actions = new LinearLayout(this); actions.setGravity(Gravity.RIGHT);
        Button done = secondary(record.completed ? "Undo" : "Done"); done.setOnClickListener(v -> { store.setCompleted(record.id, !record.completed); showCoreReport(core); });
        Button delete = secondary("Delete"); delete.setOnClickListener(v -> { store.deleteRecord(record.id); showCoreReport(core); });
        actions.addView(done, new LinearLayout.LayoutParams(90, 44)); actions.addView(delete, new LinearLayout.LayoutParams(90, 44) {{ leftMargin = 8; }});
        row.addView(actions); root.addView(row, new LinearLayout.LayoutParams(-1, -2) {{ topMargin = 8; }});
    }

    private void showAddRecord(String core) {
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(24, 8, 24, 4);
        EditText title = new EditText(this);
        title.setHint(core.equals("Calendar") ? "Event / due date" : core.equals("Household") ? "Shopping item" : core.equals("Goals") ? "Goal" : core.equals("Tasks") ? "Task" : "Expense / description");
        title.setSingleLine(true); box.addView(title);
        EditText amount = new EditText(this); amount.setHint("Amount (optional)"); amount.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL); amount.setSingleLine(true); box.addView(amount);
        new AlertDialog.Builder(this).setTitle("Add to " + core).setView(box).setNegativeButton("Cancel", null).setPositiveButton("Save", (d,w) -> {
            String t = title.getText().toString().trim(); if (t.isEmpty()) { title.setError("Enter something first"); return; }
            double a = 0; try { if (!amount.getText().toString().trim().isEmpty()) a = Double.parseDouble(amount.getText().toString().trim()); } catch(Exception ignored) {}
            store.addRecord(core, t, a, System.currentTimeMillis(), false); showCoreReport(core);
        }).show();
    }

    @Override protected void onDestroy() { if (store != null) store.close(); super.onDestroy(); }
}
