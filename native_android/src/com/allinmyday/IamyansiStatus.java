package com.allinmyday;

/** Small state model for ambient iamyansi feedback; UI may choose voice/status text without drawing an AI orb. */
public final class IamyansiStatus {
    public enum State { IDLE, UNDERSTANDING, WORKING, NEEDS_CONFIRMATION, DONE, ERROR }
    private State state = State.IDLE;
    private String message = "";

    public State getState() { return state; }
    public String getMessage() { return message; }

    public void set(State next, String text) {
        state = next == null ? State.IDLE : next;
        message = text == null ? "" : text;
    }

    public void reset() { set(State.IDLE, ""); }
}
