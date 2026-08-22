package com.allinmyday;

import android.content.Context;
import android.content.Intent;
import android.speech.RecognizerIntent;

import java.util.ArrayList;
import java.util.Locale;

/**
 * iamyansi voice bridge foundation.
 * Uses Android's built-in speech activity only when the user explicitly starts voice input.
 * No permanent microphone listener and no third-party speech SDK.
 */
public final class IamyansiVoiceBridge {
    public static final int REQUEST_CODE = 4101;

    private IamyansiVoiceBridge() {}

    public static Intent createIntent() {
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
        intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "Speak to iamyansi");
        return intent;
    }

    public static String firstResult(Intent data) {
        if (data == null) return "";
        ArrayList<String> results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
        return results == null || results.isEmpty() ? "" : results.get(0);
    }

    /** Converts simple spoken phrases into a safe local record proposal; execution remains app-controlled. */
    public static Proposal understand(String text) {
        String value = text == null ? "" : text.trim();
        String lower = value.toLowerCase(Locale.ROOT);
        if (lower.isEmpty()) return new Proposal("", "", 0, false);
        String core = "Tasks";
        if (containsAny(lower, "spent", "expense", "paid", "bought")) core = "Expenses";
        else if (containsAny(lower, "goal", "target", "save")) core = "Goals";
        else if (containsAny(lower, "grocery", "groceries", "shopping", "milk", "vegetable")) core = "Household";
        else if (containsAny(lower, "bill", "renewal", "birthday", "appointment", "tomorrow", "date")) core = "Calendar";
        double amount = extractAmount(lower);
        return new Proposal(core, value, amount, false);
    }

    private static boolean containsAny(String value, String... words) {
        for (String word : words) if (value.contains(word)) return true;
        return false;
    }

    private static double extractAmount(String value) {
        String cleaned = value.replaceAll("[^0-9.]", " ").trim();
        if (cleaned.isEmpty()) return 0;
        String[] parts = cleaned.split("\\s+");
        for (String part : parts) {
            try { return Double.parseDouble(part); } catch (NumberFormatException ignored) { }
        }
        return 0;
    }

    public static final class Proposal {
        public final String core;
        public final String text;
        public final double amount;
        public final boolean completed;
        Proposal(String core, String text, double amount, boolean completed) {
            this.core = core; this.text = text; this.amount = amount; this.completed = completed;
        }
    }
}
