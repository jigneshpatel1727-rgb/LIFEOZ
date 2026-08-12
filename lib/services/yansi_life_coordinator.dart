import '../models/life_memory.dart';
import 'yansi_memory.dart';
import 'purchase_memory.dart';
import 'financial_memory.dart';
import 'household_intelligence.dart';
import 'bill_analysis.dart';
import 'personal_budget_coordinator.dart';

/// ============================================================
/// YANSI LIFE COORDINATOR
/// ============================================================
///
/// The central coordination layer of LifeOS.
///
/// Yansi uses this layer to connect the five LifeOS cores:
///
/// 1. Financial Life
/// 2. Goals & Growth
/// 3. Productivity
/// 4. Household
/// 5. Life Diary / Calendar
///
/// The user does NOT need to manually move information between
/// cores. Yansi decides where information belongs and can use
/// information from one core to improve another.
///
/// Example:
///
/// "I want to buy a new house in two years."
///
/// Yansi can connect:
///
/// Goal
///   ↓
/// Financial planning
///   ↓
/// Savings target
///   ↓
/// Spending analysis
///   ↓
/// Monthly budget
///
/// Another example:
///
/// Grocery bill
///   ↓
/// Purchase history
///   ↓
/// Household pattern
///   ↓
/// Future shopping list
///   ↓
/// Budget impact
///
/// IMPORTANT:
/// This coordinator only prepares information and
/// recommendations. It does not perform irreversible
/// financial or external actions automatically.
/// ============================================================

class YansiLifeSnapshot {
  final DateTime generatedAt;

  final int totalMemories;

  final int financeMemories;

  final int goalMemories;

  final int productivityMemories;

  final int householdMemories;

  final int diaryMemories;

  final int calendarMemories;

  final int generalMemories;

  final double monthlyPurchases;

  final double monthlyIncome;

  final double monthlyCommitments;

  final double plannedSavings;

  final double householdMonthlyEstimate;

  final double currentMonthSpending;

  final double projectedMonthSpending;

  final List<String> householdRequirements;

  final List<String> financialWarnings;

  final List<String> financialSuggestions;

  final List<String> priorityActions;

  const YansiLifeSnapshot({
    required this.generatedAt,
    required this.totalMemories,
    required this.financeMemories,
    required this.goalMemories,
    required this.productivityMemories,
    required this.householdMemories,
    required this.diaryMemories,
    required this.calendarMemories,
    required this.generalMemories,
    required this.monthlyPurchases,
    required this.monthlyIncome,
    required this.monthlyCommitments,
    required this.plannedSavings,
    required this.householdMonthlyEstimate,
    required this.currentMonthSpending,
    required this.projectedMonthSpending,
    required this.householdRequirements,
    required this.financialWarnings,
    required this.financialSuggestions,
    required this.priorityActions,
  });
}

class YansiLifeCoordinator {
  final YansiMemory yansiMemory;

  final PurchaseMemory purchaseMemory;

  final FinancialMemory financialMemory;

  late final HouseholdIntelligence householdIntelligence;

  late final BillAnalysis billAnalysis;

  late final PersonalBudgetCoordinator
      personalBudgetCoordinator;

  YansiLifeCoordinator({
    required this.yansiMemory,
    required this.purchaseMemory,
    required this.financialMemory,
  }) {
    householdIntelligence =
        HouseholdIntelligence(
      yansiMemory,
    );

    billAnalysis =
        BillAnalysis(
      purchaseMemory,
    );

    personalBudgetCoordinator =
        PersonalBudgetCoordinator(
      financialMemory:
          financialMemory,
      purchaseMemory:
          purchaseMemory,
      billAnalysis:
          billAnalysis,
      householdIntelligence:
          householdIntelligence,
    );
  }

  // ==========================================================
  // CREATE COMPLETE LIFEOS SNAPSHOT
  // ==========================================================

  YansiLifeSnapshot createSnapshot({
    DateTime? date,
  }) {
    final target =
        date ?? DateTime.now();

    final memories =
        yansiMemory.getAll();

    final finance =
        _countCore(
      memories,
      MemoryCore.finance,
    );

    final goals =
        _countCore(
      memories,
      MemoryCore.goals,
    );

    final productivity =
        _countCore(
      memories,
      MemoryCore.productivity,
    );

    final household =
        _countCore(
      memories,
      MemoryCore.household,
    );

    final diary =
        _countCore(
      memories,
      MemoryCore.diary,
    );

    final calendar =
        _countCore(
      memories,
      MemoryCore.calendar,
    );

    final general =
        _countCore(
      memories,
      MemoryCore.general,
    );

    final financialProfile =
        financialMemory.getProfile();

    final householdReport =
        householdIntelligence
            .generateReport();

    final budgetPlan =
        personalBudgetCoordinator
            .createPlan(
      month: target,
    );

    final billReport =
        billAnalysis.analyze(
      month: target,
    );

    final requirements =
        householdReport.requirements
            .map(
              (item) => item.item,
            )
            .toList();

    final warnings =
        <String>[
      ...budgetPlan.warnings,
      ...billReport.warnings,
    ];

    final suggestions =
        <String>[
      ...budgetPlan.suggestions,
      ...billReport.suggestions,
    ];

    final priorityActions =
        <String>[
      ...budgetPlan.actions,
    ];

    return YansiLifeSnapshot(
      generatedAt:
          DateTime.now(),

      totalMemories:
          memories.length,

      financeMemories:
          finance,

      goalMemories:
          goals,

      productivityMemories:
          productivity,

      householdMemories:
          household,

      diaryMemories:
          diary,

      calendarMemories:
          calendar,

      generalMemories:
          general,

      monthlyPurchases:
          billReport.monthlyTotal,

      monthlyIncome:
          financialProfile
              .monthlyIncome,

      monthlyCommitments:
          financialProfile
              .monthlyCommitments,

      plannedSavings:
          budgetPlan
              .recommendedSavings,

      householdMonthlyEstimate:
          householdReport
              .estimatedMonthlyCost,

      currentMonthSpending:
          budgetPlan
              .currentMonthSpending,

      projectedMonthSpending:
          budgetPlan
              .projectedMonthSpending,

      householdRequirements:
          List.unmodifiable(
        requirements,
      ),

      financialWarnings:
          List.unmodifiable(
        _unique(warnings),
      ),

      financialSuggestions:
          List.unmodifiable(
        _unique(suggestions),
      ),

      priorityActions:
          List.unmodifiable(
        _unique(priorityActions),
      ),
    );
  }

  // ==========================================================
  // UNDERSTAND WHERE A MEMORY BELONGS
  // ==========================================================

  MemoryCore classifyText(
    String text,
  ) {
    final lower =
        text.toLowerCase();

    if (_containsAny(
      lower,
      [
        'spent',
        'paid',
        'salary',
        'income',
        'expense',
        'money',
        'investment',
        'saving',
        'fuel',
        'petrol',
        'bill',
      ],
    )) {
      return MemoryCore.finance;
    }

    if (_containsAny(
      lower,
      [
        'goal',
        'target',
        'dream',
        'future',
        'want to achieve',
        'want to save for',
      ],
    )) {
      return MemoryCore.goals;
    }

    if (_containsAny(
      lower,
      [
        'task',
        'remind me',
        'remember to',
        'need to',
        'have to',
        'meeting',
        'call',
        'finish',
      ],
    )) {
      return MemoryCore.productivity;
    }

    if (_containsAny(
      lower,
      [
        'grocery',
        'rice',
        'milk',
        'oil',
        'vegetable',
        'household',
        'shopping',
        'detergent',
      ],
    )) {
      return MemoryCore.household;
    }

    if (_containsAny(
      lower,
      [
        'birthday',
        'anniversary',
        'renewal',
        'appointment',
        'due date',
        'service',
        'checkup',
      ],
    )) {
      return MemoryCore.calendar;
    }

    if (_containsAny(
      lower,
      [
        'i feel',
        'feeling',
        'happy',
        'sad',
        'tired',
        'stressed',
        'worried',
        'frustrated',
        'my day',
      ],
    )) {
      return MemoryCore.diary;
    }

    return MemoryCore.general;
  }

  // ==========================================================
  // CROSS-CORE INSIGHT
  // ==========================================================

  List<String> crossCoreInsights() {
    final snapshot =
        createSnapshot();

    final insights =
        <String>[];

    // --------------------------------------------------------
    // FINANCE + HOUSEHOLD
    // --------------------------------------------------------

    if (snapshot.householdMonthlyEstimate >
        0) {
      insights.add(
        'Household requirements are estimated at approximately ${snapshot.householdMonthlyEstimate.toStringAsFixed(0)} per month and should be considered in the financial plan.',
      );
    }

    // --------------------------------------------------------
    // FINANCE + GOALS
    // --------------------------------------------------------

    if (snapshot.plannedSavings > 0) {
      insights.add(
        'Yansi is considering approximately ${snapshot.plannedSavings.toStringAsFixed(0)} of planned monthly savings while coordinating financial goals.',
      );
    }

    // --------------------------------------------------------
    // SPENDING + BUDGET
    // --------------------------------------------------------

    if (snapshot.projectedMonthSpending >
        snapshot.monthlyIncome &&
        snapshot.monthlyIncome > 0) {
      insights.add(
        'Projected spending requires attention because it may exceed recorded monthly income.',
      );
    }

    // --------------------------------------------------------
    // PRODUCTIVITY
    // --------------------------------------------------------

    if (snapshot.productivityMemories > 0) {
      insights.add(
        'Yansi has ${snapshot.productivityMemories} productivity records that can be used to improve future planning.',
      );
    }

    // --------------------------------------------------------
    // DIARY
    // --------------------------------------------------------

    if (snapshot.diaryMemories > 0) {
      insights.add(
        'Yansi has personal diary context that can help provide more personalized conversations and suggestions.',
      );
    }

    return _unique(insights);
  }

  // ==========================================================
  // DAILY YANSI BRIEFING
  // ==========================================================

  List<String> dailyBriefing() {
    final snapshot =
        createSnapshot();

    final briefing =
        <String>[];

    if (snapshot.householdRequirements
        .isNotEmpty) {
      briefing.add(
        'Household: ${snapshot.householdRequirements.take(3).join(', ')} may be needed.',
      );
    }

    if (snapshot.financialWarnings
        .isNotEmpty) {
      briefing.add(
        snapshot.financialWarnings.first,
      );
    }

    if (snapshot.priorityActions
        .isNotEmpty) {
      briefing.add(
        snapshot.priorityActions.first,
      );
    }

    if (briefing.isEmpty) {
      briefing.add(
        'Everything looks normal. I will continue watching your LifeOS patterns.',
      );
    }

    return _unique(briefing);
  }

  // ==========================================================
  // YANSI PERSONAL STATUS
  // ==========================================================

  String personalStatus() {
    final snapshot =
        createSnapshot();

    if (snapshot.financialWarnings
        .isNotEmpty) {
      return snapshot
          .financialWarnings
          .first;
    }

    if (snapshot.householdRequirements
        .isNotEmpty) {
      return 'I have identified ${snapshot.householdRequirements.length} household requirements that may need attention.';
    }

    if (snapshot.priorityActions
        .isNotEmpty) {
      return snapshot
          .priorityActions
          .first;
    }

    return 'I am continuously learning your LifeOS patterns and watching for anything useful.';
  }

  // ==========================================================
  // CORE COUNT
  // ==========================================================

  int _countCore(
    List<LifeMemory> memories,
    MemoryCore core,
  ) {
    return memories
        .where(
          (memory) =>
              memory.core == core,
        )
        .length;
  }

  // ==========================================================
  // STRING HELPER
  // ==========================================================

  bool _containsAny(
    String text,
    List<String> values,
  ) {
    for (final value in values) {
      if (text.contains(value)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // UNIQUE
  // ==========================================================

  List<String> _unique(
    List<String> values,
  ) {
    final result =
        <String>[];

    for (final value in values) {
      if (value.trim().isEmpty) {
        continue;
      }

      if (!result.contains(value)) {
        result.add(value);
      }
    }

    return result;
  }
}
