import 'lifeos_data_store.dart';

/// First deterministic prediction layer for Yansi.
///
/// It deliberately uses explainable historical data. A later AI model can
/// enrich these predictions, but the app should always be able to explain
/// where a prediction came from.
class YansiPredictionEngine {
  final LifeOSDataStore store;

  const YansiPredictionEngine(this.store);

  Map<String, dynamic> monthlyBudget({
    required double monthlyIncome,
    int lookbackMonths = 3,
  }) {
    final expenses = store.read('expenses');
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - lookbackMonths + 1, 1);

    final totals = <String, double>{};
    for (final row in expenses) {
      final date = DateTime.tryParse(row['date']?.toString() ?? '');
      if (date == null || date.isBefore(cutoff)) continue;
      final category = row['category']?.toString() ?? 'Other';
      final amount = (row['amount'] as num?)?.toDouble() ?? 0;
      totals[category] = (totals[category] ?? 0) + amount;
    }

    final divisor = lookbackMonths <= 0 ? 1 : lookbackMonths;
    final predicted = totals.map(
      (key, value) => MapEntry(key, value / divisor),
    );

    final predictedExpense = predicted.values.fold<double>(0, (a, b) => a + b);
    final projectedBalance = monthlyIncome - predictedExpense;

    return {
      'monthlyIncome': monthlyIncome,
      'predictedExpenses': predictedExpense,
      'projectedBalance': projectedBalance,
      'categories': predicted,
      'basis': 'Average of the last $lookbackMonths months of recorded expenses.',
    };
  }

  List<Map<String, dynamic>> predictedHouseholdRequirements({
    int lookbackMonths = 3,
  }) {
    final records = store.read('household');
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - lookbackMonths + 1, 1);
    final counts = <String, int>{};

    for (final row in records) {
      final date = DateTime.tryParse(row['date']?.toString() ?? '');
      if (date == null || date.isBefore(cutoff)) continue;
      final item = row['item']?.toString().trim();
      if (item == null || item.isEmpty) continue;
      counts[item.toLowerCase()] = (counts[item.toLowerCase()] ?? 0) + 1;
    }

    return counts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => {
              'item': entry.key,
              'confidence': entry.value / lookbackMonths,
              'observations': entry.value,
            })
        .toList()
      ..sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));
  }
}
