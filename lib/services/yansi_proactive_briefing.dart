import 'lifeos_data_store.dart';

/// Builds a quiet, explainable daily briefing from LifeOS records.
/// This layer only recommends; it never performs sensitive actions.
class YansiProactiveBriefing {
  final LifeOSDataStore store;

  const YansiProactiveBriefing(this.store);

  Map<String, dynamic> generate({DateTime? now}) {
    final current = now ?? DateTime.now();
    final tasks = store.read('tasks');
    final calendar = store.read('calendar');
    final money = store.read('money');
    final household = store.read('household');
    final goals = store.read('goals');

    final openTasks = tasks.where((r) => r['completed'] != true).length;
    final expenses = money.where((r) => r['type'] == 'expense').fold<double>(
      0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));

    final priorities = <String>[];
    if (openTasks > 0) priorities.add('$openTasks task${openTasks == 1 ? '' : 's'} still open');
    if (calendar.isNotEmpty) priorities.add('${calendar.length} calendar item${calendar.length == 1 ? '' : 's'} to review');
    if (household.isNotEmpty) priorities.add('${household.length} household item${household.length == 1 ? '' : 's'} recorded');
    if (goals.isNotEmpty) priorities.add('${goals.length} goal${goals.length == 1 ? '' : 's'} in progress');

    final greeting = current.hour < 12
        ? 'Good morning.'
        : current.hour < 17
            ? 'Good afternoon.'
            : 'Good evening.';

    return {
      'generatedAt': current.toIso8601String(),
      'greeting': greeting,
      'priorities': priorities,
      'recordedExpenseTotal': expenses,
      'openTaskCount': openTasks,
      'calendarCount': calendar.length,
      'householdCount': household.length,
      'goalCount': goals.length,
      'suggestion': priorities.isEmpty
          ? 'Your LifeOS looks quiet. I am here when you need me.'
          : 'I found a few things worth reviewing. You remain in control of every action.',
    };
  }
}
