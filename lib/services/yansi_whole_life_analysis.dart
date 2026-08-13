import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-core LifeOS analysis for Yansi.
///
/// This layer intentionally stays local-first: it combines permitted LifeOS
/// records into a compact, explainable snapshot. It does not diagnose health
/// or psychology and it does not send private records to external services.
class YansiWholeLifeAnalysis {
  final SharedPreferences prefs;
  const YansiWholeLifeAnalysis({required this.prefs});

  List<Map<String, dynamic>> _read(String key) {
    final raw = prefs.getStringList(key) ?? const <String>[];
    return raw.map((v) {
      try {
        return Map<String, dynamic>.from(jsonDecode(v) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((e) => e.isNotEmpty).toList();
  }

  Future<YansiLifeSnapshot> build() async {
    final tasks = _read('yansi_tasks');
    final expenses = _read('yansi_expenses');
    final reminders = _read('yansi_reminders');
    final goals = _read('yansi_goals');
    final household = _read('yansi_household');

    final openTasks = tasks.where((e) => e['completed'] != true).length;
    final completedTasks = tasks.length - openTasks;
    final taskRate = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    double spending = 0;
    final categories = <String, double>{};
    for (final e in expenses) {
      final amount = (e['amount'] as num?)?.toDouble() ?? 0;
      spending += amount;
      final category = '${e['category'] ?? 'Other'}';
      categories[category] = (categories[category] ?? 0) + amount;
    }

    final now = DateTime.now();
    final upcoming = reminders.where((e) {
      final d = DateTime.tryParse('${e['dueDate'] ?? e['date'] ?? ''}');
      return d != null && !d.isBefore(now) && d.difference(now).inDays <= 30;
    }).length;

    final staleGoals = goals.where((e) {
      final d = DateTime.tryParse('${e['updatedAt'] ?? e['date'] ?? ''}');
      return d == null || now.difference(d).inDays >= 14;
    }).length;

    String? dominantCategory;
    if (categories.isNotEmpty) {
      dominantCategory = categories.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      ).key;
    }

    final signals = <YansiLifeSignal>[];
    if (openTasks >= 5) {
      signals.add(const YansiLifeSignal(
        area: 'PRODUCTIVITY',
        message: 'Several tasks are still open. Prioritising a small number may reduce overload.',
        priority: 'MEDIUM',
      ));
    }
    if (upcoming > 0) {
      signals.add(YansiLifeSignal(
        area: 'CALENDAR',
        message: '$upcoming upcoming reminder${upcoming == 1 ? '' : 's'} fall within 30 days.',
        priority: upcoming >= 3 ? 'HIGH' : 'MEDIUM',
      ));
    }
    if (staleGoals > 0) {
      signals.add(YansiLifeSignal(
        area: 'GOALS',
        message: '$staleGoals goal${staleGoals == 1 ? '' : 's'} have little recent activity.',
        priority: 'MEDIUM',
      ));
    }
    if (dominantCategory != null) {
      signals.add(YansiLifeSignal(
        area: 'MONEY',
        message: '$dominantCategory is currently the largest stored expense category.',
        priority: 'LOW',
      ));
    }
    if (household.isNotEmpty) {
      signals.add(const YansiLifeSignal(
        area: 'HOUSEHOLD',
        message: 'Household purchase history is available for future recurring-item analysis.',
        priority: 'LOW',
      ));
    }

    signals.sort((a, b) {
      const rank = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};
      return (rank[b.priority] ?? 0).compareTo(rank[a.priority] ?? 0);
    });

    return YansiLifeSnapshot(
      openTasks: openTasks,
      completedTasks: completedTasks,
      taskCompletionRate: taskRate,
      totalStoredSpending: spending,
      expenseCategories: Map.unmodifiable(categories),
      upcomingReminders: upcoming,
      goals: goals.length,
      staleGoals: staleGoals,
      householdRecords: household.length,
      signals: List.unmodifiable(signals),
      generatedAt: now,
    );
  }
}

class YansiLifeSnapshot {
  final int openTasks;
  final int completedTasks;
  final double taskCompletionRate;
  final double totalStoredSpending;
  final Map<String, double> expenseCategories;
  final int upcomingReminders;
  final int goals;
  final int staleGoals;
  final int householdRecords;
  final List<YansiLifeSignal> signals;
  final DateTime generatedAt;

  const YansiLifeSnapshot({
    required this.openTasks,
    required this.completedTasks,
    required this.taskCompletionRate,
    required this.totalStoredSpending,
    required this.expenseCategories,
    required this.upcomingReminders,
    required this.goals,
    required this.staleGoals,
    required this.householdRecords,
    required this.signals,
    required this.generatedAt,
  });
}

class YansiLifeSignal {
  final String area;
  final String message;
  final String priority;
  const YansiLifeSignal({required this.area, required this.message, required this.priority});
}
