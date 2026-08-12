import 'lifeos_data_store.dart';

/// Read-only reporting layer for Yansi's five LifeOS cores.
/// It never mutates user data.
class YansiLifeReport {
  final LifeOSDataStore store;

  const YansiLifeReport(this.store);

  Map<String, dynamic> build() {
    final money = store.read('money');
    final tasks = store.read('tasks');
    final household = store.read('household');
    final calendar = store.read('calendar');
    final goals = store.read('goals');

    final completedTasks = tasks.where((r) => r['completed'] == true).length;
    final completedGoals = goals.where((r) => r['completed'] == true).length;

    return {
      'money': {
        'records': money.length,
        'expenses': money.where((r) => r['type'] == 'expense').length,
      },
      'productivity': {
        'total_tasks': tasks.length,
        'completed_tasks': completedTasks,
        'completion_percent': tasks.isEmpty ? 0 : (completedTasks * 100 / tasks.length).round(),
      },
      'household': {'items': household.length},
      'calendar': {'events': calendar.length},
      'goals': {
        'total_goals': goals.length,
        'completed_goals': completedGoals,
      },
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  String summary() {
    final report = build();
    final productivity = report['productivity'] as Map<String, dynamic>;
    final goals = report['goals'] as Map<String, dynamic>;
    return 'LifeOS report: ${productivity['completed_tasks']} of '
        '${productivity['total_tasks']} tasks completed, '
        '${goals['completed_goals']} of ${goals['total_goals']} goals completed.';
  }
}
