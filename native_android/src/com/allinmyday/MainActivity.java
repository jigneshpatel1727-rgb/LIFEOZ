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

/**
 * Allinmyday native application surface.
 * iamyansi is invisible/ambient; it is never rendered as a permanent orb or chatbot.
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

    private void showOnboarding() {
        LinearLayout root = page();
        TextView brand = text("ALLINMYDAY", 30, green); brand.setTypeface(null, android.graphics.Typeface.BOLD); root.addView(brand);
        root.addView(text("One screen. One tap. One report.", 13, muted));
        root.addView(text("\nYour life, your way.", 25, ink));
        root.addView(text("Set up your private LifeOS profile. Your trial data stays on this device.", 14, muted));

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

        Button continueButton = primary("Create / Continue");
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(-1, 58); cp.topMargin = 24; root.addView(continueButton, cp);
        continueButton.setOnClickListener(v -> {
            String n = name.getText().toString().trim();
            if (n.isEmpty()) { name.setError("Enter your name"); return; }
            store.saveProfile(n, email.getText().toString(), currency.getSelectedItem().toString(),
                    language.getSelectedItem().toString(), theme.getSelectedItem().toString());
            showHome();
        });
        setContentView(new ScrollView(this) {{ addView(root); }});
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

        LinearLayout ambient = new LinearLayout(this); ambient.setOrientation(LinearLayout.VERTICAL);
        ambient.setPadding(16, 16, 16, 16); ambient.setBackgroundColor(Color.rgb(235, 243, 235));
        ambient.addView(text("iamyansi", 16, green));
        ambient.addView(text("Works quietly in the background. Listens, understands and helps only when permitted.", 12, muted));
        root.addView(ambient, new LinearLayout.LayoutParams(-1, -2) {{ topMargin = 14; }});

        LinearLayout bottom = new LinearLayout(this); bottom.setGravity(Gravity.CENTER);
        Button settings = secondary("Settings & Privacy"); settings.setOnClickListener(v -> showSettings());
        bottom.addView(settings, new LinearLayout.LayoutParams(-1, 52) {{ topMargin = 16; }});
        root.addView(bottom);
        setContentView(new ScrollView(this) {{ addView(root); }});
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
            .setItems(new String[]{"Profile", "Permissions", "Privacy & local data", "iamyansi controls", "Theme"}, (d, which) -> {
                if (which == 0) showProfile();
                else if (which == 1) showInfo("Permissions", "You control what Allinmyday and iamyansi can access. Sensitive actions require confirmation.");
                else if (which == 2) showInfo("Privacy", "Trial data is stored locally through the Android platform. No external database is used.");
                else if (which == 3) showInfo("iamyansi", "iamyansi is ghost/ambient intelligence. It is not a permanent on-screen chatbot or circle.");
                else showOnboarding();
            }).setNegativeButton("Close", null).show();
    }

    private void showInfo(String title, String message) {
        new AlertDialog.Builder(this).setTitle(title).setMessage(message).setPositiveButton("OK", null).show();
    }

    private void openCore(int index) {
        final String[] cores = {"Expenses", "Goals", "Tasks", "Household", "Calendar"};
        final String core = cores[index];
        LinearLayout box = new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(28, 10, 28, 8);
        box.addView(text(core + "\n\nThis is the first native data screen. Add information here; it is saved locally on this device.", 15, muted));
        EditText title = new EditText(this); title.setHint(index == 0 ? "Expense / description" : "Item / event / task"); title.setSingleLine(true); box.addView(title);
        EditText amount = new EditText(this); amount.setHint("Amount (optional)"); amount.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL); amount.setSingleLine(true); box.addView(amount);
        new AlertDialog.Builder(this).setTitle(core).setView(box).setNegativeButton("Back", null).setPositiveButton("Save", (d,w) -> {
            String t = title.getText().toString().trim();
            if (t.isEmpty()) { Toast.makeText(this, "Enter something first", Toast.LENGTH_SHORT).show(); return; }
            double a = 0; try { if (!amount.getText().toString().trim().isEmpty()) a = Double.parseDouble(amount.getText().toString().trim()); } catch(Exception ignored) {}
            store.addRecord(core, t, a, System.currentTimeMillis(), false);
            Toast.makeText(this, "Saved locally in " + core, Toast.LENGTH_SHORT).show();
        }).show();
    }

    @Override protected void onDestroy() { if (store != null) store.close(); super.onDestroy(); }
}
