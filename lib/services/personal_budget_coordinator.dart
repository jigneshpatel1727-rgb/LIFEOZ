import 'financial_memory.dart';
import 'purchase_memory.dart';
import 'bill_analysis.dart';
import 'household_intelligence.dart';

/// ============================================================
/// PERSONAL BUDGET COORDINATOR
/// ============================================================
///
/// Yansi's financial coordination layer.
///
/// Combines:
///
/// Financial Profile
///       +
/// Income
///       +
/// Fixed commitments
///       +
/// Savings target
///       +
/// Financial goals
///       +
/// Purchase history
///       +
/// Household requirements
///       +
/// Bill analysis
///
///              ↓
///
///        PERSONAL PLAN
///
/// This is a recommendation engine.
/// It does NOT move money, make bank transactions,
/// or perform financial actions without explicit user
/// authorization.
///
/// Historical records remain permanent.
/// ============================================================

class PersonalBudgetPlan {
  final double monthlyIncome;

  final double monthlyCommitments;

  final double historicalSpending;

  final double householdEstimate;

  final double recommendedSavings;

  final double availableForVariableSpending;

  final double currentMonthSpending;

  final double projectedMonthSpending;

  final double remainingVariableBudget;

  final double financialGoalRequirement;

  final bool spendingRisk;

  final bool savingsRisk;

  final bool goalRisk;

  final List<String> warnings;

  final List<String> suggestions;

  final List<String> actions;

  const PersonalBudgetPlan({
    required this.monthlyIncome,
    required this.monthlyCommitments,
    required this.historicalSpending,
    required this.householdEstimate,
    required this.recommendedSavings,
    required this.availableForVariableSpending,
    required this.currentMonthSpending,
    required this.projectedMonthSpending,
    required this.remainingVariableBudget,
    required this.financialGoalRequirement,
    required this.spendingRisk,
    required this.savingsRisk,
    required this.goalRisk,
    required this.warnings,
    required this.suggestions,
    required this.actions,
  });
}

class PersonalBudgetCoordinator {
  final FinancialMemory financialMemory;

  final PurchaseMemory purchaseMemory;

  final BillAnalysis billAnalysis;

  final HouseholdIntelligence householdIntelligence;

  PersonalBudgetCoordinator({
    required this.financialMemory,
    required this.purchaseMemory,
    required this.billAnalysis,
    required this.householdIntelligence,
  });

  // ==========================================================
  // CREATE PERSONAL PLAN
  // ==========================================================

  PersonalBudgetPlan createPlan({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    final profile =
        financialMemory.getProfile();

    final monthlyIncome =
        profile.monthlyIncome;

    final monthlyCommitments =
        profile.monthlyCommitments;

    final historicalSpending =
        _historicalAverageSpending();

    final householdReport =
        householdIntelligence
            .generateReport();

    final householdEstimate =
        householdReport
            .estimatedMonthlyCost;

    final goalRequirement =
        financialMemory
            .requiredMonthlySavingForGoals();

    final userSavingsTarget =
        profile.monthlySavingsTarget;

    final recommendedSavings =
        _recommendedSavings(
      monthlyIncome:
          monthlyIncome,
      monthlyCommitments:
          monthlyCommitments,
      goalRequirement:
          goalRequirement,
      userTarget:
          userSavingsTarget,
    );

    final available =
        monthlyIncome -
            monthlyCommitments -
            recommendedSavings;

    final currentSpending =
        purchaseMemory.monthlyTotal(
      month: target,
    );

    final projectedSpending =
        _projectSpending(
      currentSpending,
      target,
    );

    final remaining =
        available -
            currentSpending;

    final spendingRisk =
        available > 0 &&
            projectedSpending >
                available;

    final savingsRisk =
        monthlyIncome > 0 &&
            recommendedSavings > 0 &&
            projectedSpending +
                    monthlyCommitments >
                monthlyIncome -
                    recommendedSavings;

    final goalRisk =
        goalRequirement > 0 &&
            recommendedSavings <
                goalRequirement;

    final warnings =
        _buildWarnings(
      monthlyIncome:
          monthlyIncome,
      monthlyCommitments:
          monthlyCommitments,
      available:
          available,
      currentSpending:
          currentSpending,
      projectedSpending:
          projectedSpending,
      recommendedSavings:
          recommendedSavings,
      goalRequirement:
          goalRequirement,
      spendingRisk:
          spendingRisk,
      savingsRisk:
          savingsRisk,
      goalRisk:
          goalRisk,
    );

    final suggestions =
        _buildSuggestions(
      monthlyIncome:
          monthlyIncome,
      monthlyCommitments:
          monthlyCommitments,
      historicalSpending:
          historicalSpending,
      householdEstimate:
          householdEstimate,
      recommendedSavings:
          recommendedSavings,
      available:
          available,
      currentSpending:
          currentSpending,
      projectedSpending:
          projectedSpending,
      goalRequirement:
          goalRequirement,
      billSuggestions:
          billAnalysis
              .analyze(
            month: target,
          )
              .suggestions,
    );

    final actions =
        _buildActions(
      spendingRisk:
          spendingRisk,
      savingsRisk:
          savingsRisk,
      goalRisk:
          goalRisk,
      householdReport:
          householdReport,
    );

    return PersonalBudgetPlan(
      monthlyIncome:
          monthlyIncome,
      monthlyCommitments:
          monthlyCommitments,
      historicalSpending:
          historicalSpending,
      householdEstimate:
          householdEstimate,
      recommendedSavings:
          recommendedSavings,
      availableForVariableSpending:
          available,
      currentMonthSpending:
          currentSpending,
      projectedMonthSpending:
          projectedSpending,
      remainingVariableBudget:
          remaining,
      financialGoalRequirement:
          goalRequirement,
      spendingRisk:
          spendingRisk,
      savingsRisk:
          savingsRisk,
      goalRisk:
          goalRisk,
      warnings:
          List.unmodifiable(
        warnings,
      ),
      suggestions:
          List.unmodifiable(
        suggestions,
      ),
      actions:
          List.unmodifiable(
        actions,
      ),
    );
  }

  // ==========================================================
  // HISTORICAL SPENDING
  // ==========================================================

  double _historicalAverageSpending() {
    final now =
        DateTime.now();

    double total = 0;

    int months = 0;

    for (int i = 1; i <= 6; i++) {
      final month =
          DateTime(
        now.year,
        now.month - i,
        1,
      );

      final value =
          purchaseMemory.monthlyTotal(
        month: month,
      );

      if (value > 0) {
        total += value;
        months++;
      }
    }

    if (months == 0) {
      return purchaseMemory
          .monthlyTotal();
    }

    return total / months;
  }

  // ==========================================================
  // SAVINGS CALCULATION
  // ==========================================================

  double _recommendedSavings({
    required double monthlyIncome,
    required double monthlyCommitments,
    required double goalRequirement,
    required double userTarget,
  }) {
    if (userTarget > 0) {
      return userTarget;
    }

    if (goalRequirement > 0) {
      return goalRequirement;
    }

    if (monthlyIncome <= 0) {
      return 0;
    }

    // Initial planning rule.
    //
    // Later the AI will personalize this based on:
    // income stability
    // goals
    // obligations
    // emergency reserve
    // historical spending
    //
    return monthlyIncome * 0.10;
  }

  // ==========================================================
  // CURRENT MONTH PROJECTION
  // ==========================================================

  double _projectSpending(
    double currentSpending,
    DateTime month,
  ) {
    if (currentSpending <= 0) {
      return 0;
    }

    final now =
        DateTime.now();

    final sameMonth =
        month.year == now.year &&
        month.month == now.month;

    if (!sameMonth) {
      return currentSpending;
    }

    final daysPassed =
        now.day;

    final daysInMonth =
        DateTime(
          now.year,
          now.month + 1,
          0,
        ).day;

    if (daysPassed <= 0) {
      return currentSpending;
    }

    return currentSpending *
        daysInMonth /
        daysPassed;
  }

  // ==========================================================
  // WARNINGS
  // ==========================================================

  List<String> _buildWarnings({
    required double monthlyIncome,
    required double monthlyCommitments,
    required double available,
    required double currentSpending,
    required double projectedSpending,
    required double recommendedSavings,
    required double goalRequirement,
    required bool spendingRisk,
    required bool savingsRisk,
    required bool goalRisk,
  }) {
    final warnings =
        <String>[];

    if (monthlyIncome <= 0) {
      warnings.add(
        'Yansi needs your income information before creating a fully personalized financial plan.',
      );
    }

    if (monthlyCommitments >
        monthlyIncome &&
        monthlyIncome > 0) {
      warnings.add(
        'Your recorded recurring commitments are higher than your recorded monthly income.',
      );
    }

    if (spendingRisk) {
      warnings.add(
        'Your current spending pattern may exceed the amount available after commitments and planned savings.',
      );
    }

    if (savingsRisk) {
      warnings.add(
        'Your current spending pattern may make the planned savings target difficult to achieve.',
      );
    }

    if (goalRisk) {
      warnings.add(
        'Your current planned savings may not be enough to reach all recorded financial goals on time.',
      );
    }

    if (available < 0) {
      warnings.add(
        'Your planned commitments and savings currently exceed your recorded available monthly income.',
      );
    }

    if (currentSpending >
        projectedSpending &&
        projectedSpending > 0) {
      warnings.add(
        'Current spending data needs review because the projection is inconsistent with the current total.',
      );
    }

    return warnings;
  }

  // ==========================================================
  // SUGGESTIONS
  // ==========================================================

  List<String> _buildSuggestions({
    required double monthlyIncome,
    required double monthlyCommitments,
    required double historicalSpending,
    required double householdEstimate,
    required double recommendedSavings,
    required double available,
    required double currentSpending,
    required double projectedSpending,
    required double goalRequirement,
    required List<String> billSuggestions,
  }) {
    final suggestions =
        <String>[];

    if (monthlyIncome <= 0) {
      suggestions.add(
        'Tell Yansi your regular income so I can build a more personalized budget.',
      );
    }

    if (householdEstimate > 0) {
      suggestions.add(
        'Your learned household requirement is approximately ${householdEstimate.toStringAsFixed(0)} per month. Yansi will use this when planning future budgets.',
      );
    }

    if (recommendedSavings > 0) {
      suggestions.add(
        'Your current planned savings target is approximately ${recommendedSavings.toStringAsFixed(0)} per month.',
      );
    }

    if (goalRequirement > 0) {
      suggestions.add(
        'Your recorded goals currently require approximately ${goalRequirement.toStringAsFixed(0)} per month to stay on target.',
      );
    }

    if (historicalSpending > 0 &&
        currentSpending >
            historicalSpending * 1.10) {
      suggestions.add(
        'Your current spending is more than 10% above your recent historical average.',
      );
    }

    if (projectedSpending >
            available &&
        available > 0) {
      suggestions.add(
        'Yansi recommends reviewing discretionary purchases for the remainder of the month.',
      );
    }

    if (billSuggestions.isNotEmpty) {
      suggestions.addAll(
        billSuggestions.take(2),
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        'Yansi is learning your financial patterns and will improve the plan as more LifeOS history becomes available.',
      );
    }

    return _unique(
      suggestions,
    );
  }

  // ==========================================================
  // ACTIONS
  // ==========================================================

  List<String> _buildActions({
    required bool spendingRisk,
    required bool savingsRisk,
    required bool goalRisk,
    required HouseholdReport
        householdReport,
  }) {
    final actions =
        <String>[];

    if (spendingRisk) {
      actions.add(
        'Review discretionary spending.',
      );
    }

    if (savingsRisk) {
      actions.add(
        'Review this month spending against the savings target.',
      );
    }

    if (goalRisk) {
      actions.add(
        'Review financial goals and required monthly saving.',
      );
    }

    if (householdReport
        .requirements
        .isNotEmpty) {
      actions.add(
        'Review predicted household requirements.',
      );
    }

    if (actions.isEmpty) {
      actions.add(
        'Continue normal spending and let Yansi keep learning your patterns.',
      );
    }

    return _unique(
      actions,
    );
  }

  // ==========================================================
  // UNIQUE LIST
  // ==========================================================

  List<String> _unique(
    List<String> values,
  ) {
    final result =
        <String>[];

    for (final value in values) {
      if (!result.contains(value)) {
        result.add(value);
      }
    }

    return result;
  }
}
