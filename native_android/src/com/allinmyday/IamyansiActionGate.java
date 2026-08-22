package com.allinmyday;

import java.util.Locale;

/**
 * Safety gate for iamyansi proposals. Understanding and proposing are separate from execution.
 * Sensitive actions require explicit confirmation before the app may execute them.
 */
public final class IamyansiActionGate {
    private IamyansiActionGate() {}

    public static Decision evaluate(String core, String text, double amount) {
        String value = text == null ? "" : text.toLowerCase(Locale.ROOT);
        boolean sensitive = amount > 0 || contains(value, "delete", "remove", "transfer", "pay", "send", "buy", "sell", "invest");
        if (core == null || core.trim().isEmpty()) return new Decision(false, true, "I need to understand what you want me to do.");
        if (sensitive) return new Decision(false, true, "I understood the request. Please confirm before I make this change.");
        return new Decision(true, false, "Ready to add this to " + core + ".");
    }

    private static boolean contains(String value, String... terms) {
        for (String term : terms) if (value.contains(term)) return true;
        return false;
    }

    public static final class Decision {
        public final boolean executableWithoutConfirmation;
        public final boolean requiresConfirmation;
        public final String message;
        Decision(boolean executableWithoutConfirmation, boolean requiresConfirmation, String message) {
            this.executableWithoutConfirmation = executableWithoutConfirmation;
            this.requiresConfirmation = requiresConfirmation;
            this.message = message;
        }
    }
}
