package com.allinmyday;

/** Centralizes short, non-chatty ambient feedback for iamyansi. */
public final class IamyansiFeedback {
    private IamyansiFeedback() {}

    public static String forState(IamyansiStatus.State state, String core) {
        if (state == null) return "";
        switch (state) {
            case UNDERSTANDING: return "Understanding.";
            case WORKING: return "Working on it.";
            case NEEDS_CONFIRMATION: return "I need your confirmation.";
            case DONE: return core == null || core.isEmpty() ? "Done." : "Done. Added to " + core + ".";
            case ERROR: return "I couldn't complete that.";
            default: return "";
        }
    }
}
