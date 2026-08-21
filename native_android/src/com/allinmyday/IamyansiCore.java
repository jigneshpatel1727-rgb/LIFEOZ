package com.allinmyday;

import java.util.Locale;

/**
 * Local Allinmyday-owned iamyansi action core.
 * This is intentionally deterministic and permission-safe; it does not call
 * an external AI service or SDK. A future model can be connected behind this
 * interface without changing the app's action boundary.
 */
public final class IamyansiCore {
    public enum State { IDLE, UNDERSTANDING, WORKING, DONE, NEEDS_CONFIRMATION }

    public static final class Response {
        public final State state;
        public final String message;
        public final String action;
        public final boolean sensitive;
        Response(State state, String message, String action, boolean sensitive) {
            this.state = state; this.message = message; this.action = action; this.sensitive = sensitive;
        }
    }

    public Response understand(String spokenOrTypedText) {
        if (spokenOrTypedText == null || spokenOrTypedText.trim().isEmpty()) {
            return new Response(State.IDLE, "I'm here.", "none", false);
        }
        String s = spokenOrTypedText.trim().toLowerCase(Locale.ROOT);
        if (s.contains("expense") || s.contains("spent") || s.contains("paid")) {
            return new Response(State.UNDERSTANDING, "I can organize that expense.", "expense", false);
        }
        if (s.contains("task") || s.contains("todo") || s.contains("remind")) {
            return new Response(State.UNDERSTANDING, "I can organize that task.", "task", false);
        }
        if (s.contains("delete") || s.contains("send") || s.contains("pay") || s.contains("transfer")) {
            return new Response(State.NEEDS_CONFIRMATION, "I'll need your confirmation before that action.", "sensitive", true);
        }
        return new Response(State.UNDERSTANDING, "I'm understanding that.", "general", false);
    }
}
