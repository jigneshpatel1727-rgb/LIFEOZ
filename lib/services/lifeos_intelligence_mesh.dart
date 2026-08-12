import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-core intelligence layer. It turns separate LifeOS records into one
/// compact state that Yansi and futuristic surfaces can reason over.
class LifeOSIntelligenceMesh {
  final SharedPreferences prefs;
  LifeOSIntelligenceMesh(this.prefs);

  LifeOSPulse snapshot() {
    final expenses = _records('yansi_expenses');
    final tasks = _records('yansi_tasks');
    final reminders = _records('yansi_reminders');
    final household = _records('yansi_household');
    final goals = _records('yansi_goals');
    final diary = _records('yansi_diary');

    final spending = expenses.fold<double>(0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));
    final openTasks = tasks.where((r) => r['completed'] != true).length;
    final completedTasks = tasks.where((r) => r['completed'] == true).length;

    return LifeOSPulse(
      totalExpenses: spending,
      expenseCount: expenses.length,
      openTasks: openTasks,
      completedTasks: completedTasks,
      reminders: reminders.length,
      householdItems: household.length,
      goals: goals.length,
      diaryEntries: diary.length,
      taskCompletion: tasks.isEmpty ? 0 : completedTasks / tasks.length,
    );
  }

  List<Map<String, dynamic>> _records(String key) {
    return (prefs.getStringList(key) ?? const <String>[]).map((raw) {
      try {
        return Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((record) => record.isNotEmpty).toList();
  }
}

class LifeOSPulse {
  final double totalExpenses;
  final int expenseCount;
  final int openTasks;
  final int completedTasks;
  final int reminders;
  final int householdItems;
  final int goals;
  final int diaryEntries;
  final double taskCompletion;

  const LifeOSPulse({
    required this.totalExpenses,
    required this.expenseCount,
    required this.openTasks,
    required this.completedTasks,
    required this.reminders,
    required this.householdItems,
    required this.goals,
    required this.diaryEntries,
    required this.taskCompletion,
  });

  bool get hasActivity => expenseCount + openTasks + reminders + householdItems + goals + diaryEntries > 0;
}
