import 'lifeos_data_store.dart';

/// Cross-core intelligence adapter for Yansi.
/// Keeps the five LifeOS domains connected without coupling the UI to them.
class YansiLifeIntelligence {
  final LifeOSDataStore store;

  const YansiLifeIntelligence(this.store);

  Map<String, dynamic> analyze({String currency = ''}) {
    final money = store.read('money');
    final goals = store.read('goals');
    final tasks = store.read('tasks');
    final household = store.read('household');
    final calendar = store.read('calendar');

    final expenses = money.where((r) => r['type'] == 'expense').fold<double>(
      0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));
    final income = money.where((r) => r['type'] == 'income').fold<double>(
      0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));
    final openTasks = tasks.where((r) => r['completed'] != true).length;
    final completedTasks = tasks.where((r) => r['completed'] == true).length;

    return {
      'currency': currency,
      'money': {'income': income, 'expenses': expenses, 'balance': income - expenses},
      'goals': {'total': goals.length},
      'productivity': {
        'openTasks': openTasks,
        'completedTasks': completedTasks,
        'completionRate': tasks.isEmpty ? 0.0 : completedTasks / tasks.length,
      },
      'household': {'items': household.length},
      'calendar': {'events': calendar.length},
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  String insight(Map<String, dynamic> report) {
    final money = Map<String, dynamic>.from(report['money'] as Map);
    final expenses = (money['expenses'] as num).toDouble();
    final income = (money['income'] as num).toDouble();
    final openTasks = report['productivity']['openTasks'] as int;

    if (income > 0 && expenses > income) {
      return 'Your spending is currently above recorded income. I recommend reviewing Money before adding new commitments.';
    }
    if (openTasks >= 5) {
      return 'You have several open tasks. I can help prioritize them and carry unfinished work forward.';
    }
    return 'Your LifeOS data is connected across the five cores. Ask me for a report, prediction, or recommendation.';
  }
}
