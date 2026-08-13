/// Produces explainable financial signals from LifeOS expense data.
class YansiFinancialIntelligenceEngine {
  const YansiFinancialIntelligenceEngine();

  Map<String, dynamic> analyze(List<Map<String, dynamic>> expenses) {
    double total = 0;
    final categories = <String, double>{};
    for (final expense in expenses) {
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
      final category = (expense['category'] ?? 'other').toString();
      total += amount;
      categories[category] = (categories[category] ?? 0) + amount;
    }
    final topCategory = categories.entries.isEmpty
        ? null
        : (categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
    return {
      'totalObserved': total,
      'categoryTotals': Map.unmodifiable(categories),
      'topCategory': topCategory?.key,
      'topCategoryAmount': topCategory?.value,
      'signal': topCategory == null ? 'insufficient_data' : 'spending_pattern_available',
    };
  }
}
