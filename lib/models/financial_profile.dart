import 'dart:convert';

/// ============================================================
/// FINANCIAL PROFILE
/// ============================================================
///
/// Stores the user's financial planning information.
///
/// This is NOT a bank account and does not move money.
/// It is a LifeOS planning model used by Yansi.
///
/// Historical records should remain permanent.
/// ============================================================

class FinancialIncome {
  final String id;
  final String name;
  final double amount;
  final String frequency;
  final DateTime createdAt;

  const FinancialIncome({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialIncome.fromMap(
    Map<String, dynamic> map,
  ) {
    return FinancialIncome(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Income',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      frequency:
          map['frequency'] as String? ?? 'monthly',
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialIncome.fromJson(
    String value,
  ) {
    return FinancialIncome.fromMap(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}

/// ============================================================
/// FINANCIAL COMMITMENT
/// ============================================================

class FinancialCommitment {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String frequency;
  final DateTime? dueDate;
  final DateTime createdAt;

  const FinancialCommitment({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.createdAt,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialCommitment.fromMap(
    Map<String, dynamic> map,
  ) {
    return FinancialCommitment(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Commitment',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category:
          map['category'] as String? ?? 'Other',
      frequency:
          map['frequency'] as String? ?? 'monthly',
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.tryParse(
              map['dueDate'] as String,
            ),
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialCommitment.fromJson(
    String value,
  ) {
    return FinancialCommitment.fromMap(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}

/// ============================================================
/// FINANCIAL GOAL
/// ============================================================

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final DateTime createdAt;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.targetDate,
  });

  double get remaining {
    final value =
        targetAmount - currentAmount;

    return value < 0 ? 0 : value;
  }

  double get progressPercent {
    if (targetAmount <= 0) {
      return 0;
    }

    final progress =
        (currentAmount / targetAmount) * 100;

    if (progress < 0) {
      return 0;
    }

    if (progress > 100) {
      return 100;
    }

    return progress;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialGoal.fromMap(
    Map<String, dynamic> map,
  ) {
    return FinancialGoal(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Goal',
      targetAmount:
          (map['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount:
          (map['currentAmount'] as num?)?.toDouble() ?? 0,
      targetDate: map['targetDate'] == null
          ? null
          : DateTime.tryParse(
              map['targetDate'] as String,
            ),
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialGoal.fromJson(
    String value,
  ) {
    return FinancialGoal.fromMap(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}

/// ============================================================
/// COMPLETE FINANCIAL PROFILE
/// ============================================================

class FinancialProfile {
  final String currency;

  final List<FinancialIncome> incomes;

  final List<FinancialCommitment> commitments;

  final List<FinancialGoal> goals;

  final double monthlySavingsTarget;

  final DateTime updatedAt;

  const FinancialProfile({
    required this.currency,
    required this.incomes,
    required this.commitments,
    required this.goals,
    required this.monthlySavingsTarget,
    required this.updatedAt,
  });

  double get monthlyIncome {
    double total = 0;

    for (final income in incomes) {
      total += _monthlyAmount(
        income.amount,
        income.frequency,
      );
    }

    return total;
  }

  double get monthlyCommitments {
    double total = 0;

    for (final commitment in commitments) {
      total += _monthlyAmount(
        commitment.amount,
        commitment.frequency,
      );
    }

    return total;
  }

  double get totalGoalRemaining {
    return goals.fold(
      0.0,
      (total, goal) =>
          total + goal.remaining,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'incomes':
          incomes.map((e) => e.toMap()).toList(),
      'commitments':
          commitments.map((e) => e.toMap()).toList(),
      'goals':
          goals.map((e) => e.toMap()).toList(),
      'monthlySavingsTarget':
          monthlySavingsTarget,
      'updatedAt':
          updatedAt.toIso8601String(),
    };
  }

  factory FinancialProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawIncomes =
        map['incomes'] as List<dynamic>? ?? [];

    final rawCommitments =
        map['commitments'] as List<dynamic>? ?? [];

    final rawGoals =
        map['goals'] as List<dynamic>? ?? [];

    return FinancialProfile(
      currency:
          map['currency'] as String? ?? '₹',
      incomes: List.unmodifiable(
        rawIncomes.map(
          (item) => FinancialIncome.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      ),
      commitments: List.unmodifiable(
        rawCommitments.map(
          (item) =>
              FinancialCommitment.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      ),
      goals: List.unmodifiable(
        rawGoals.map(
          (item) => FinancialGoal.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      ),
      monthlySavingsTarget:
          (map['monthlySavingsTarget'] as num?)
                  ?.toDouble() ??
              0,
      updatedAt: DateTime.tryParse(
            map['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory FinancialProfile.fromJson(
    String value,
  ) {
    return FinancialProfile.fromMap(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  static double _monthlyAmount(
    double amount,
    String frequency,
  ) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return amount * 30;

      case 'weekly':
        return amount * 4.345;

      case 'yearly':
      case 'annual':
        return amount / 12;

      case 'quarterly':
        return amount / 3;

      case 'half-yearly':
      case 'half yearly':
        return amount / 6;

      case 'one-time':
      case 'one time':
        return 0;

      case 'monthly':
      default:
        return amount;
    }
  }
}
