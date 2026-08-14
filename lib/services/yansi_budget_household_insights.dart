import 'yansi_proactive_suggestions.dart';

/// Phase 1 planning signals for budget and household needs.
/// This layer recommends; it does not place orders or move money.
class YansiBudgetHouseholdInsights {
  const YansiBudgetHouseholdInsights();

  List<YansiProactiveSuggestion> evaluate({
    required double monthlySpend,
    required double monthlyBudget,
    required List<String> householdNeeds,
    double projectedMonthlySpend = 0,
    int lowStockItems = 0,
  }) {
    final result = <YansiProactiveSuggestion>[];

    final projected = projectedMonthlySpend > 0
        ? projectedMonthlySpend
        : monthlySpend;

    if (monthlyBudget > 0 && projected > monthlyBudget) {
      final over = projected - monthlyBudget;
      result.add(YansiProactiveSuggestion(
        title: 'Budget forecast',
        message:
            'Your current spending pattern projects about ${over.toStringAsFixed(0)} over this month’s budget. I can help rebalance the plan.',
        core: 'money',
        priority: 90,
      ));
    } else if (monthlyBudget > 0 && projected >= monthlyBudget * 0.8) {
      result.add(const YansiProactiveSuggestion(
        title: 'Budget awareness',
        message:
            'Your projected spending is approaching the monthly budget. I can help plan the remaining days.',
        core: 'money',
        priority: 78,
      ));
    }

    if (householdNeeds.isNotEmpty) {
      final unique = householdNeeds
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
      if (unique.isNotEmpty) {
        final preview = unique.take(5).join(', ');
        result.add(YansiProactiveSuggestion(
          title: 'Household plan',
          message:
              'Your household list currently includes $preview. I can help organize it into a practical monthly plan.',
          core: 'household',
          priority: 74,
        ));
      }
    }

    if (lowStockItems > 0) {
      result.add(YansiProactiveSuggestion(
        title: 'Household replenishment',
        message:
            'There are $lowStockItems household item${lowStockItems == 1 ? '' : 's'} marked low. I can help prioritize what is needed first.',
        core: 'household',
        priority: 80,
      ));
    }

    result.sort((a, b) => b.priority.compareTo(a.priority));
    return result;
  }
}
