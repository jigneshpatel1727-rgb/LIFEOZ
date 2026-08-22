package com.allinmyday;

import java.util.ArrayList;
import java.util.List;

/** Presentation-ready local model for the Goals core's one-screen report. */
public final class GoalsReportModel {
    public final int total;
    public final int completed;
    public final int pending;
    public final List<AllinmydayStore.Record> goals;

    private GoalsReportModel(int total, int completed, List<AllinmydayStore.Record> goals) {
        this.total = total;
        this.completed = completed;
        this.pending = total - completed;
        this.goals = goals;
    }

    public static GoalsReportModel from(AllinmydayStore store) {
        List<AllinmydayStore.Record> copy = new ArrayList<>(store.getRecords("Goals"));
        int done = 0;
        for (AllinmydayStore.Record goal : copy) if (goal.completed) done++;
        return new GoalsReportModel(copy.size(), done, copy);
    }

    public int completionPercent() {
        return total == 0 ? 0 : Math.round((completed * 100f) / total);
    }

    public String headline() {
        if (total == 0) return "No goals added yet";
        if (pending == 0) return "All goals completed";
        return pending + " goal" + (pending == 1 ? "" : "s") + " in progress";
    }
}
