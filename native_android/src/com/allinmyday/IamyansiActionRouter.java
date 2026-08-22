package com.allinmyday;

/**
 * Single local boundary between iamyansi understanding and app actions.
 * No UI is rendered here: callers receive a compact proposal and decide
 * whether to execute it or request confirmation.
 */
public final class IamyansiActionRouter {
    private final IamyansiCore core;

    public IamyansiActionRouter(IamyansiCore core) {
        this.core = core == null ? new IamyansiCore() : core;
    }

    public Proposal propose(String targetCore, String spokenText, double amount) {
        IamyansiCore.Response understanding = core.understand(spokenText);
        IamyansiActionGate.Decision gate = IamyansiActionGate.evaluate(targetCore, spokenText, amount);
        String message = gate.requiresConfirmation
                ? gate.message
                : understanding.message;
        return new Proposal(understanding.state, understanding.action, message,
                gate.executableWithoutConfirmation, gate.requiresConfirmation);
    }

    public static final class Proposal {
        public final IamyansiCore.State state;
        public final String action;
        public final String message;
        public final boolean executableWithoutConfirmation;
        public final boolean requiresConfirmation;

        Proposal(IamyansiCore.State state, String action, String message,
                 boolean executableWithoutConfirmation, boolean requiresConfirmation) {
            this.state = state;
            this.action = action;
            this.message = message;
            this.executableWithoutConfirmation = executableWithoutConfirmation;
            this.requiresConfirmation = requiresConfirmation;
        }
    }
}
