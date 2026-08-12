import 'yansi_brain.dart';

/// Single orchestration boundary for Yansi.
///
/// UI code should depend on this coordinator rather than directly coupling
/// itself to individual intelligence modules. Domain services can be added
/// behind this boundary without changing the Yansi-facing experience.
class YansiCoordinator {
  final YansiBrain brain;

  const YansiCoordinator({required this.brain});

  Future<YansiResult> handle(String input, {String? voicePath}) {
    return brain.process(input, voicePath: voicePath);
  }

  Future<YansiLifeSnapshot> snapshot() async {
    final memory = await brain.getMemory();
    final summary = await brain.getSummary();

    final openTasks = memory.where((item) =>
        item['type'] == 'task' && item['completed'] != true).length;
    final goals = memory.where((item) => item['type'] == 'goal').length;
    final household = memory.where((item) => item['type'] == 'household').length;
    final reminders = memory.where((item) => item['type'] == 'reminder').length;

    return YansiLifeSnapshot(
      recordCount: memory.length,
      openTasks: openTasks,
      goals: goals,
      householdItems: household,
      reminders: reminders,
      income: (summary['income'] as num?)?.toDouble() ?? 0,
      expenses: (summary['expenses'] as num?)?.toDouble() ?? 0,
      balance: (summary['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class YansiLifeSnapshot {
  final int recordCount;
  final int openTasks;
  final int goals;
  final int householdItems;
  final int reminders;
  final double income;
  final double expenses;
  final double balance;

  const YansiLifeSnapshot({
    required this.recordCount,
    required this.openTasks,
    required this.goals,
    required this.householdItems,
    required this.reminders,
    required this.income,
    required this.expenses,
    required this.balance,
  });
}
