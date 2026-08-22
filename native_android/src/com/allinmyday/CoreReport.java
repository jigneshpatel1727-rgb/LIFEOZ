package com.allinmyday;

import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

/**
 * Presentation-ready report data for the five Allinmyday cores.
 * Kept separate from UI so every core can use the same one-screen/report pattern.
 */
public final class CoreReport {
    public final String core;
    public final int itemCount;
    public final int completedCount;
    public final double totalAmount;
    public final List<AllinmydayStore.Record> records;

    private CoreReport(String core, int itemCount, int completedCount, double totalAmount,
                       List<AllinmydayStore.Record> records) {
        this.core = core;
        this.itemCount = itemCount;
        this.completedCount = completedCount;
        this.totalAmount = totalAmount;
        this.records = records;
    }

    public static CoreReport from(AllinmydayStore store, String core) {
        List<AllinmydayStore.Record> records = store.getRecords(core);
        int completed = 0;
        double total = 0;
        for (AllinmydayStore.Record record : records) {
            if (record.completed) completed++;
            total += record.amount;
        }
        return new CoreReport(core, records.size(), completed, total, records);
    }

    public int completionPercent() {
        if (itemCount == 0) return 0;
        return Math.round((completedCount * 100f) / itemCount);
    }

    public String amountText(String currencyCode) {
        NumberFormat format = NumberFormat.getCurrencyInstance(Locale.getDefault());
        try { format.setCurrency(java.util.Currency.getInstance(currencyCode)); }
        catch (Exception ignored) { }
        return format.format(totalAmount);
    }
}
