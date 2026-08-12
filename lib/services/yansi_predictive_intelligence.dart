import 'lifeos_data_store.dart';

/// Deterministic, explainable prediction layer for Yansi.
/// Predictions are derived from stored records and are explicitly labelled.
class YansiPredictiveIntelligence {
  final LifeOSDataStore store;

  const YansiPredictiveIntelligence(this.store);

  Map<String, dynamic> monthlyBudget({double? plannedIncome}) {
    final rows = store.read('money');
    final expenses = rows
        .where((r) => r['type'] == 'expense')
        .map((r) => (r['amount'] as num?)?.toDouble() ?? 0)
        .toList();
    final income = plannedIncome ?? rows
        .where((r) => r['type'] == 'income')
        .fold<double>(0, (s, r) => s + ((r['amount'] as num?)?.toDouble() ?? 0));

    final average = expenses.isEmpty
        ? 0.0
        : expenses.reduce((a, b) => a + b) / expenses.length;
    final projected = average * 30;

    return {
      'type': 'prediction',
      'period': 'monthly',
      'incomeBasis': income,
      'projectedExpense': projected,
      'projectedBalance': income - projected,
      'sampleCount': expenses.length,
      'confidence': expenses.length < 5 ? 'low' : expenses.length < 20 ? 'medium' : 'higher',
      'explainable': 'Based on recorded expense history; not a guarantee.',
    };
  }

  List<Map<String, dynamic>> predictedHouseholdList() {
    final rows = store.read('household');
    final counts = <String, int>{};
    for (final row in rows) {
      final name = row['item']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      counts[name.toLowerCase()] = (counts[name.toLowerCase()] ?? 0) + 1;
    }
    return counts.entries
        .where((e) => e.value >= 2)
        .map((e) => {'item': e.key, 'occurrences': e.value, 'predicted': true})
        .toList()
      ..sort((a, b) => (b['occurrences'] as int).compareTo(a['occurrences'] as int));
  }

  Map<String, dynamic> behaviour() {
    final money = store.read('money');
    final tasks = store.read('tasks');
    final expenses = money.where((r) => r['type'] == 'expense').fold<double>(
      0, (s, r) => s + ((r['amount'] as num?)?.toDouble() ?? 0));
    final completed = tasks.where((r) => r['completed'] == true).length;
    final completionRate = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return {
      'type': 'observation',
      'expenseRecords': money.where((r) => r['type'] == 'expense').length,
      'totalRecordedExpenses': expenses,
      'taskCompletionRate': completionRate,
      'suggestion': completionRate < 0.5
          ? 'Consider prioritizing fewer tasks at a time.'
          : 'Your recorded task completion pattern is healthy.',
      'note': 'This is an observation from LifeOS records, not a judgement.',
    };
  }
}
