import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_profile.dart';

/// ============================================================
/// FINANCIAL MEMORY
/// ============================================================
///
/// Permanent financial planning storage.
///
/// Yansi can learn:
/// - Income
/// - Recurring commitments
/// - Financial goals
/// - Savings target
///
/// There is intentionally no normal delete operation.
/// ============================================================

class FinancialMemory {
  static const String _profileKey =
      'lifeos_financial_profile';

  final SharedPreferences prefs;

  FinancialMemory(
    this.prefs,
  );

  // ==========================================================
  // LOAD PROFILE
  // ==========================================================

  FinancialProfile getProfile({
    String currency = '₹',
  }) {
    final value =
        prefs.getString(_profileKey);

    if (value == null ||
        value.trim().isEmpty) {
      return FinancialProfile(
        currency: currency,
        incomes: const [],
        commitments: const [],
        goals: const [],
        monthlySavingsTarget: 0,
        updatedAt: DateTime.now(),
      );
    }

    try {
      return FinancialProfile.fromJson(
        value,
      );
    } catch (_) {
      return FinancialProfile(
        currency: currency,
        incomes: const [],
        commitments: const [],
        goals: const [],
        monthlySavingsTarget: 0,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ==========================================================
  // SAVE COMPLETE PROFILE
  // ==========================================================

  Future<bool> saveProfile(
    FinancialProfile profile,
  ) async {
    try {
      return await prefs.setString(
        _profileKey,
        profile.toJson(),
      );
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // ADD INCOME
  // ==========================================================

  Future<bool> addIncome(
    FinancialIncome income, {
    String currency = '₹',
  }) async {
    final profile =
        getProfile(
      currency: currency,
    );

    final incomes =
        List<FinancialIncome>.from(
      profile.incomes,
    );

    incomes.add(income);

    return saveProfile(
      FinancialProfile(
        currency: profile.currency,
        incomes: List.unmodifiable(
          incomes,
        ),
        commitments:
            profile.commitments,
        goals: profile.goals,
        monthlySavingsTarget:
            profile.monthlySavingsTarget,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // ADD COMMITMENT
  // ==========================================================

  Future<bool> addCommitment(
    FinancialCommitment commitment, {
    String currency = '₹',
  }) async {
    final profile =
        getProfile(
      currency: currency,
    );

    final commitments =
        List<FinancialCommitment>.from(
      profile.commitments,
    );

    commitments.add(commitment);

    return saveProfile(
      FinancialProfile(
        currency: profile.currency,
        incomes: profile.incomes,
        commitments:
            List.unmodifiable(
          commitments,
        ),
        goals: profile.goals,
        monthlySavingsTarget:
            profile.monthlySavingsTarget,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // ADD GOAL
  // ==========================================================

  Future<bool> addGoal(
    FinancialGoal goal, {
    String currency = '₹',
  }) async {
    final profile =
        getProfile(
      currency: currency,
    );

    final goals =
        List<FinancialGoal>.from(
      profile.goals,
    );

    goals.add(goal);

    return saveProfile(
      FinancialProfile(
        currency: profile.currency,
        incomes: profile.incomes,
        commitments:
            profile.commitments,
        goals: List.unmodifiable(
          goals,
        ),
        monthlySavingsTarget:
            profile.monthlySavingsTarget,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // SET SAVINGS TARGET
  // ==========================================================

  Future<bool> setMonthlySavingsTarget(
    double amount, {
    String currency = '₹',
  }) async {
    final profile =
        getProfile(
      currency: currency,
    );

    return saveProfile(
      FinancialProfile(
        currency: profile.currency,
        incomes: profile.incomes,
        commitments:
            profile.commitments,
        goals: profile.goals,
        monthlySavingsTarget:
            amount < 0 ? 0 : amount,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // QUICK FINANCIAL SUMMARY
  // ==========================================================

  Map<String, double> summary({
    String currency = '₹',
  }) {
    final profile =
        getProfile(
      currency: currency,
    );

    final income =
        profile.monthlyIncome;

    final commitments =
        profile.monthlyCommitments;

    final savings =
        profile.monthlySavingsTarget;

    final available =
        income -
            commitments -
            savings;

    return {
      'monthlyIncome': income,
      'monthlyCommitments':
          commitments,
      'monthlySavingsTarget':
          savings,
      'availableAfterCommitmentsAndSavings':
          available,
    };
  }

  // ==========================================================
  // GOAL REQUIRED MONTHLY SAVING
  // ==========================================================

  double requiredMonthlySavingForGoal(
    FinancialGoal goal,
  ) {
    if (goal.remaining <= 0) {
      return 0;
    }

    final target =
        goal.targetDate;

    if (target == null) {
      return 0;
    }

    final now =
        DateTime.now();

    final months =
        ((target.year - now.year) * 12) +
            target.month -
            now.month;

    if (months <= 0) {
      return goal.remaining;
    }

    return goal.remaining /
        months;
  }

  // ==========================================================
  // TOTAL REQUIRED FOR ALL GOALS
  // ==========================================================

  double requiredMonthlySavingForGoals() {
    final profile =
        getProfile();

    double total = 0;

    for (final goal
        in profile.goals) {
      total +=
          requiredMonthlySavingForGoal(
        goal,
      );
    }

    return total;
  }

  // ==========================================================
  // NO DELETE METHODS
  // ==========================================================
  //
  // LifeOS keeps financial history.
  //
  // ==========================================================
}
