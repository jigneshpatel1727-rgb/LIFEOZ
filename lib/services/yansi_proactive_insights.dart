import 'lifeos_data_store.dart';

class YansiInsight {
  final String id;
  final String message;
  final String category;
  final String priority;
  const YansiInsight({required this.id, required this.message, required this.category, required this.priority});
}

/// Produces conservative, read-only proactive suggestions from LifeOS data.
class YansiProactiveInsights {
  final LifeOSDataStore store;
  const YansiProactiveInsights(this.store);

  List<YansiInsight> generate() {
    final insights = <YansiInsight>[];
    final tasks = store.read('tasks');
    final goals = store.read('goals');
    final calendar = store.read('calendar');
    final expenses = store.read('money').where((r) => r['type'] == 'expense').toList();

    final pending = tasks.where((r) => r['completed'] != true).length;
    if (pending > 0) {
      insights.add(YansiInsight(
        id: 'pending_tasks',
        message: 'You have $pending pending task${pending == 1 ? '' : 's'}. I can help you prioritize them.',
        category: 'productivity',
        priority: pending >= 5 ? 'high' : 'normal',
      ));
    }

    final openGoals = goals.where((r) => r['completed'] != true).length;
    if (openGoals > 0) {
      insights.add(YansiInsight(
        id: 'open_goals',
        message: 'You have $openGoals active goal${openGoals == 1 ? '' : 's'}.',
        category: 'goals',
        priority: 'normal',
      ));
    }

    final now = DateTime.now();
    final soon = calendar.where((r) {
      final raw = r['dueDate']?.toString() ?? r['timestamp']?.toString();
      final date = raw == null ? null : DateTime.tryParse(raw);
      if (date == null) return false;
      final d = date.difference(now);
      return !d.isNegative && d <= const Duration(days: 7);
    }).length;
    if (soon > 0) {
      insights.add(YansiInsight(
        id: 'calendar_soon',
        message: '$soon calendar item${soon == 1 ? '' : 's'} due within 7 days.',
        category: 'calendar',
        priority: 'high',
      ));
    }

    if (expenses.length >= 10) {
      insights.add(const YansiInsight(
        id: 'expense_review',
        message: 'You have enough recent expense records for a useful spending review.',
        category: 'money',
        priority: 'normal',
      ));
    }
    return insights;
  }
}
