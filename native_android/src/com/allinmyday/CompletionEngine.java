package com.allinmyday;

import java.util.List;

/** Local productivity metrics for the Tasks core. */
public final class CompletionEngine {
    private CompletionEngine() {}

    public static Result calculate(AllinmydayStore store) {
        List<AllinmydayStore.Record> records = store.getRecords("Tasks");
        int total = records.size(), completed = 0, pending = 0;
        for (AllinmydayStore.Record r : records) {
            if (r.completed) completed++; else pending++;
        }
        return new Result(total, completed, pending);
    }

    public static final class Result {
        public final int total, completed, pending;
        Result(int total, int completed, int pending) { this.total = total; this.completed = completed; this.pending = pending; }
        public int percent() { return total == 0 ? 0 : (completed * 100) / total; }
    }
}
