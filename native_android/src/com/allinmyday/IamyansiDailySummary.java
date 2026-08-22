package com.allinmyday;

/**
 * Local, deterministic daily summary for iamyansi.
 * Keeps the ambient assistant concise and avoids exposing a chat-style UI.
 */
public final class IamyansiDailySummary {
    private IamyansiDailySummary() {}

    public static String build(AllinmydayStore store) {
        CompletionEngine.Result tasks = CompletionEngine.calculate(store);
        GoalsReportModel goals = GoalsReportModel.from(store);
        CoreReport expenses = CoreReport.from(store, "Expenses");
        CoreReport calendar = CoreReport.from(store, "Calendar");
        CoreReport household = CoreReport.from(store, "Household");

        if (tasks.pending > 0) {
            return tasks.pending + " task" + (tasks.pending == 1 ? "" : "s")
                    + " still need attention.";
        }
        if (calendar.itemCount > 0 && calendar.completedCount < calendar.itemCount) {
            return "You have " + (calendar.itemCount - calendar.completedCount)
                    + " calendar item" + (calendar.itemCount - calendar.completedCount == 1 ? "" : "s")
                    + " to review.";
        }
        if (goals.pending > 0) {
            return goals.pending + " goal" + (goals.pending == 1 ? "" : "s") + " in progress.";
        }
        if (household.itemCount > 0 && household.completedCount < household.itemCount) {
            return (household.itemCount - household.completedCount)
                    + " household item" + (household.itemCount - household.completedCount == 1 ? "" : "s")
                    + " remain.";
        }
        if (expenses.itemCount > 0) {
            return "Your expense records are up to date.";
        }
        return "Everything is quiet for now.";
    }
}
