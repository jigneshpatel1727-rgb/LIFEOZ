import '../models/life_memory.dart';
import 'yansi_memory.dart';

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

  YansiLifeCoordinator({required this.yansiMemory});

  YansiLifeSnapshot createSnapshot({DateTime? date}) {
    final memories = yansiMemory.getAll();
    int count(MemoryCore core) => memories.where((m) => m.core == core).length;
    double total(MemoryCore core) => memories.where((m) => m.core == core).fold(0.0, (v, m) => v + (m.amount ?? 0));

    final finance = memories.where((m) => m.core == MemoryCore.finance).toList();
    final income = finance.where((m) => (m.category + ' ' + m.originalText).toLowerCase().contains('income') || (m.category + ' ' + m.originalText).toLowerCase().contains('salary')).fold(0.0, (v, m) => v + (m.amount ?? 0));
    final spending = total(MemoryCore.finance);

    return YansiLifeSnapshot(
      generatedAt: DateTime.now(),
      totalMemories: memories.length,
      financeMemories: count(MemoryCore.finance),
      goalMemories: count(MemoryCore.goals),
      productivityMemories: count(MemoryCore.productivity),
      householdMemories: count(MemoryCore.household),
      diaryMemories: count(MemoryCore.diary),
      calendarMemories: count(MemoryCore.calendar),
      generalMemories: count(MemoryCore.general),
      monthlyPurchases: spending,
      monthlyIncome: income,
      monthlyCommitments: 0,
      plannedSavings: 0,
      householdMonthlyEstimate: total(MemoryCore.household),
      currentMonthSpending: spending,
      projectedMonthSpending: spending,
      householdRequirements: memories.where((m) => m.core == MemoryCore.household).take(10).map((m) => m.entity ?? m.originalText).toList(),
      financialWarnings: const [],
      financialSuggestions: const [],
      priorityActions: memories.where((m) => m.core == MemoryCore.productivity).take(5).map((m) => m.originalText).toList(),
    );
  }

  List<String> crossCoreInsights() {
    final s = createSnapshot();
    final result = <String>[];
    if (s.projectedMonthSpending > s.monthlyIncome && s.monthlyIncome > 0) {
      result.add('Projected spending may exceed recorded income.');
    }
    if (s.householdMonthlyEstimate > 0) {
      result.add('Household activity is connected to your financial picture.');
    }
    if (s.goalMemories > 0) {
      result.add('Your goals are connected to your LifeOS history.');
    }
    return result;
  }

  List<String> dailyBriefing() {
    final s = createSnapshot();
    if (s.priorityActions.isNotEmpty) return [s.priorityActions.first];
    if (s.householdRequirements.isNotEmpty) return ['Household: ${s.householdRequirements.first}'];
    return ['Everything looks normal. Yansi is watching your LifeOS patterns.'];
  }

  String personalStatus() => dailyBriefing().first;
}
