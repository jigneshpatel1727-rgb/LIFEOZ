package com.allinmyday;

/**
 * Converts iamyansi's local daily summary into a quiet, ambient UI line.
 * No orb, chat window, or permanent assistant surface is created here.
 */
public final class IamyansiDailySummaryPresenter {
    private IamyansiDailySummaryPresenter() {}

    public static String present(AllinmydayStore store) {
        String summary = IamyansiDailySummary.build(store);
        if (summary == null || summary.trim().isEmpty()) {
            return "Everything is quiet for now.";
        }
        return summary.trim();
    }
}
