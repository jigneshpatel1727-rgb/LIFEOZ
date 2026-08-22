package com.allinmyday;

/** Local planner: understand -> gate -> propose. It never executes sensitive actions by itself. */
public final class IamyansiPlanner {
    private IamyansiPlanner() {}

    public static Plan plan(String spokenText) {
        IamyansiVoiceBridge.Proposal proposal = IamyansiVoiceBridge.understand(spokenText);
        IamyansiActionGate.Decision gate = IamyansiActionGate.evaluate(proposal.core, proposal.text, proposal.amount);
        return new Plan(proposal, gate);
    }

    public static final class Plan {
        public final IamyansiVoiceBridge.Proposal proposal;
        public final IamyansiActionGate.Decision decision;
        Plan(IamyansiVoiceBridge.Proposal proposal, IamyansiActionGate.Decision decision) {
            this.proposal = proposal; this.decision = decision;
        }
        public boolean ready() { return decision.executableWithoutConfirmation && !decision.requiresConfirmation; }
    }
}
