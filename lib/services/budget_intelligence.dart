import 'purchase_memory.dart';

/// ============================================================
/// BUDGET INTELLIGENCE ENGINE
/// ============================================================
///
/// Yansi uses historical purchase data to prepare:
///
/// - Monthly spending baseline
/// - Category budgets
/// - Expected monthly spending
/// - Savings target
/// - Spending warnings
/// - Budget status
/// - Savings opportunities
///
/// IMPORTANT:
/// This engine recommends budgets.
/// It does not move money or perform financial transactions.
///
/// The final AI layer will later make these recommendations
/// much more intelligent by considering income, goals, bills,
/// household requirements and calendar events.
/// ============================================================

class BudgetCategory {
  final String category;

  final double historicalAverage;

  final double recommendedBudget;

  final double currentSpent;

  final double remaining;

  final double usagePercent;

  final bool overBudget;

  const BudgetCategory({
    required this.category,
    required this.historicalAverage,
    required this.recommendedBudget,
    required this.currentSpent,
    required this.remaining,
    required this.usagePercent,
    required this.overBudget,
  });
}

class BudgetReport {
  final DateTime month;

  final double historicalMonthlyAverage;

  final double recommendedMonthlyBudget;

  final double currentSpent;

  final double remainingBudget;

  final double recommendedSavings;

  final double projectedMonthlySpending;

  final double spendingUsagePercent;

  final bool overBudget;

  final List<BudgetCategory> categories;

  final List<String> warnings;

  final List<String> suggestions;

  const BudgetReport({
    required this.month,
    required this.historicalMonthlyAverage,
    required this.recommendedMonthlyBudget,
    required this.currentSpent,
    required this.remainingBudget,
    required this.recommendedSavings,
    required this.projectedMonthlySpending,
    required this.spendingUsagePercent,
    required this.overBudget,
    required this.categories,
    required this.warnings,
    required this.suggestions,
  });
}

class BudgetIntelligence {
  final PurchaseMemory purchaseMemory;

  BudgetIntelligence(
    this.purchaseMemory,
  );

  // ==========================================================
  // COMPLETE MONTHLY REPORT
  // ==========================================================

  BudgetReport generateReport({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    final historicalAverage =
        _historicalMonthlyAverage();

    final recommendedBudget =
        _recommendedBudget(
      historicalAverage,
    );

    final currentSpent =
        purchaseMemory.monthlyTotal(
      month: target,
    );

    final categories =
        _buildCategoryBudgets(
      target,
    );

    final remaining =
        recommendedBudget -
            currentSpent;

    final usage =
        recommendedBudget <= 0
            ? 0.0
            : (currentSpent /
                    recommendedBudget) *
                100;

    final projected =
        _projectCurrentMonth(
      currentSpent,
      target,
    );

    final savings =
        _recommendedSavings(
      historicalAverage,
      recommendedBudget,
    );

    final warnings =
        _buildWarnings(
      currentSpent:
          currentSpent,
      budget:
          recommendedBudget,
      projected:
          projected,
      categories:
          categories,
    );

    final suggestions =
        _buildSuggestions(
      currentSpent:
          currentSpent,
      historicalAverage:
          historicalAverage,
      recommendedBudget:
          recommendedBudget,
      projected:
          projected,
      categories:
          categories,
    );

    return BudgetReport(
      month: target,
      historicalMonthlyAverage:
          historicalAverage,
      recommendedMonthlyBudget:
          recommendedBudget,
      currentSpent:
          currentSpent,
      remainingBudget:
          remaining,
      recommendedSavings:
          savings,
      projectedMonthlySpending:
          projected,
      spendingUsagePercent:
          usage,
      overBudget:
          currentSpent >
              recommendedBudget,
      categories:
          List.unmodifiable(
        categories,
      ),
      warnings:
          List.unmodifiable(
        warnings,
      ),
      suggestions:
          List.unmodifiable(
        suggestions,
      ),
    );
  }

  // ==========================================================
  // HISTORICAL MONTHLY AVERAGE
  // ==========================================================

  double _historicalMonthlyAverage() {
    final now =
        DateTime.now();

    double total = 0;

    int monthsWithData = 0;

    // Look at the last 6 months.
    for (int i = 1; i <= 6; i++) {
      final month =
          DateTime(
        now.year,
        now.month - i,
        1,
      );

      final amount =
          purchaseMemory.monthlyTotal(
        month: month,
      );

      if (amount > 0) {
        total += amount;
        monthsWithData++;
      }
    }

    // If there is not enough history,
    // use the current month as an initial baseline.
    if (monthsWithData == 0) {
      final current =
          purchaseMemory.monthlyTotal(
        month: now,
      );

      return current;
    }

    return total / monthsWithData;
  }

  // ==========================================================
  // RECOMMENDED BUDGET
  // ==========================================================
  //
  // Initial local rule:
  //
  // Historical average - 5%
  //
  // Later the AI engine will consider:
  // income
  // fixed bills
  // goals
  // household requirements
  // upcoming events
  // debt
  // user-selected savings target
  // ==========================================================

  double _recommendedBudget(
    double historicalAverage,
  ) {
    if (historicalAverage <= 0) {
      return 0;
    }

    return historicalAverage * 0.95;
  }

  // ==========================================================
  // RECOMMENDED SAVINGS
  // ==========================================================

  double _recommendedSavings(
    double historicalAverage,
    double recommendedBudget,
  ) {
    if (historicalAverage <= 0) {
      return 0;
    }

    if (recommendedBudget <= 0) {
      return historicalAverage * 0.05;
    }

    return historicalAverage -
        recommendedBudget;
  }

  // ==========================================================
  // CATEGORY BUDGETS
  // ==========================================================

  List<BudgetCategory>
      _buildCategoryBudgets(
    DateTime target,
  ) {
    final categories =
        <String, List<double>>{};

    final now =
        DateTime.now();

    // Six months of category history.
    for (int i = 0; i < 6; i++) {
      final month =
          DateTime(
        now.year,
        now.month - i,
        1,
      );

      final monthly =
          purchaseMemory
              .spendingByCategory(
        month: month,
      );

      for (final entry
          in monthly.entries) {
        categories
            .putIfAbsent(
              entry.key,
              () => <double>[],
            )
            .add(entry.value);
      }
    }

    final current =
        purchaseMemory
            .spendingByCategory(
      month: target,
    );

    final result =
        <BudgetCategory>[];

    for (final entry
        in categories.entries) {
      final history =
          entry.value;

      final average =
          history.isEmpty
              ? 0.0
              : history.fold<double>(
                    0,
                    (sum, value) =>
                        sum + value,
                  ) /
                  history.length;

      // Aim for approximately 5% lower
      // than the historical average.
      final recommended =
          average * 0.95;

      final spent =
          current[entry.key] ?? 0.0;

      final remaining =
          recommended - spent;

      final usage =
          recommended <= 0
              ? 0.0
              : (spent /
                      recommended) *
                  100;

      result.add(
        BudgetCategory(
          category:
              entry.key,
          historicalAverage:
              average,
          recommendedBudget:
              recommended,
          currentSpent:
              spent,
          remaining:
              remaining,
          usagePercent:
              usage,
          overBudget:
              spent >
                  recommended,
        ),
      );
    }

    result.sort(
      (a, b) =>
          b.currentSpent.compareTo(
        a.currentSpent,
      ),
    );

    return result;
  }

  // ==========================================================
  // CURRENT MONTH PROJECTION
  // ==========================================================

  double _projectCurrentMonth(
    double currentSpent,
    DateTime month,
  ) {
    if (currentSpent <= 0) {
      return 0;
    }

    final now =
        DateTime.now();

    final sameMonth =
        month.year == now.year &&
        month.month == now.month;

    if (!sameMonth) {
      return currentSpent;
    }

    final day =
        now.day;

    final daysInMonth =
        DateTime(
          now.year,
          now.month + 1,
          0,
        ).day;

    if (day <= 0) {
      return currentSpent;
    }

    return currentSpent *
        (daysInMonth / day);
  }

  // ==========================================================
  // WARNINGS
  // ==========================================================

  List<String> _buildWarnings({
    required double currentSpent,
    required double budget,
    required double projected,
    required List<BudgetCategory>
        categories,
  }) {
    final warnings =
        <String>[];

    if (budget > 0 &&
        currentSpent >
            budget) {
      warnings.add(
        'Your current purchase spending is already above the recommended monthly budget.',
      );
    }

    if (budget > 0 &&
        projected >
            budget * 1.10) {
      warnings.add(
        'Your current spending pattern may take you more than 10% above the recommended monthly budget.',
      );
    }

    for (final category
        in categories) {
      if (category.overBudget) {
        warnings.add(
          '${category.category} is above its recommended budget.',
        );
      }
    }

    return warnings;
  }

  // ==========================================================
  // SUGGESTIONS
  // ==========================================================

  List<String> _buildSuggestions({
    required double currentSpent,
    required double historicalAverage,
    required double recommendedBudget,
    required double projected,
    required List<BudgetCategory>
        categories,
  }) {
    final suggestions =
        <String>[];

    if (recommendedBudget > 0 &&
        currentSpent <
            recommendedBudget * 0.50) {
      suggestions.add(
        'Your spending is currently below half of the recommended monthly budget. Yansi will continue watching the month before making a final prediction.',
      );
    }

    if (projected >
        recommendedBudget &&
        recommendedBudget > 0) {
      suggestions.add(
        'Yansi recommends slowing discretionary spending for the remainder of the month.',
      );
    }

    final highest =
        categories.isEmpty
            ? null
            : categories.first;

    if (highest != null &&
        highest.currentSpent > 0) {
      suggestions.add(
        '${highest.category} is currently your largest purchase category. Yansi will watch this category for savings opportunities.',
      );
    }

    if (historicalAverage > 0 &&
        recommendedBudget > 0) {
      final potential =
          historicalAverage -
              recommendedBudget;

      if (potential > 0) {
        suggestions.add(
          'The current budget target creates a potential monthly saving of approximately ${potential.toStringAsFixed(0)} compared with your historical average.',
        );
      }
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        'Yansi is learning your spending pattern. More personalized budget suggestions will become available as your history grows.',
      );
    }

    return suggestions;
  }

  // ==========================================================
  // SAVINGS TARGET
  // ==========================================================
  //
  // User can eventually provide a target.
  //
  // Example:
  // "Yansi, I want to save ₹20,000 every month."
  //
  // This method prepares the calculation.
  // ==========================================================

  double calculateRequiredMonthlySaving({
    required double targetAmount,
    required int months,
  }) {
    if (targetAmount <= 0 ||
        months <= 0) {
      return 0;
    }

    return targetAmount /
        months;
  }

  // ==========================================================
  // DISCRETIONARY SPENDING
  // ==========================================================

  double discretionarySpending({
    DateTime? month,
  }) {
    final categories =
        purchaseMemory
            .spendingByCategory(
      month: month,
    );

    const fixedLikeCategories = [
      'Bills',
      'Medical',
      'Household',
    ];

    double discretionary = 0;

    for (final entry
        in categories.entries) {
      if (!fixedLikeCategories
          .contains(entry.key)) {
        discretionary +=
            entry.value;
      }
    }

    return discretionary;
  }

  // ==========================================================
  // BUDGET STATUS MESSAGE
  // ==========================================================

  String statusMessage({
    DateTime? month,
  }) {
    final report =
        generateReport(
      month: month,
    );

    if (report.recommendedMonthlyBudget <=
        0) {
      return 'Yansi is still learning your spending pattern.';
    }

    if (report.overBudget) {
      return 'Your current spending is above the recommended budget. I will help you identify where we can save.';
    }

    if (report.spendingUsagePercent >=
        80) {
      return 'You are approaching your recommended monthly budget.';
    }

    if (report.spendingUsagePercent >=
        50) {
      return 'Your spending is currently within the planned range.';
    }

    return 'Your spending is currently well within the recommended range.';
  }

  // ==========================================================
  // YANSI SAVING MESSAGE
  // ==========================================================

  String savingMessage({
    DateTime? month,
  }) {
    final report =
        generateReport(
      month: month,
    );

    if (report.recommendedSavings <=
        0) {
      return 'Yansi needs more spending history before calculating a reliable savings opportunity.';
    }

    return 'Based on your current history, Yansi sees a potential monthly saving of approximately ${report.recommendedSavings.toStringAsFixed(0)}.';
  }
}
