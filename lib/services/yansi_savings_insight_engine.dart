/// Turns observed spending patterns into cautious, explainable saving insights.
class YansiSavingsInsightEngine {
  const YansiSavingsInsightEngine();

  List<String> suggest({
    required Map<String, dynamic> financialAnalysis,
    double threshold = 0.30,
  }) {
    final totals = Map<String, dynamic>.from(
      (financialAnalysis['categoryTotals'] as Map?) ?? const {},
    );
    final total = (financialAnalysis['totalObserved'] as num?)?.toDouble() ?? 0;
    if (total <= 0) return const ['Collect more verified expense data before suggesting savings changes.'];

    final suggestions = <String>[];
    totals.forEach((category, value) {
      final amount = (value as num).toDouble();
      if (amount / total >= threshold) {
        suggestions.add('$category is a significant observed spending category; review it for possible savings.');
      }
    });
    return List.unmodifiable(suggestions);
  }
}
