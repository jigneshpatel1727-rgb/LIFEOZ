import 'lifeos_data_store.dart';

/// Safe action layer for Yansi. It converts understood commands into
/// explicit intents. Sensitive actions are never silently executed.
class YansiActionRouter {
  final LifeOSDataStore store;

  const YansiActionRouter(this.store);

  YansiActionIntent classify(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return const YansiActionIntent.none();

    if (text.contains('add expense') || text.contains('spent ') || text.contains('paid ')) {
      return const YansiActionIntent('money.addExpense');
    }
    if (text.contains('add task') || text.contains('remind me')) {
      return const YansiActionIntent('productivity.addTask');
    }
    if (text.contains('buy ') || text.contains('shopping') || text.contains('grocery')) {
      return const YansiActionIntent('household.addItem');
    }
    if (text.contains('add event') || text.contains('schedule') || text.contains('renewal') || text.contains('bill due')) {
      return const YansiActionIntent('calendar.addEvent', requiresConfirmation: true);
    }
    if (text.contains('set goal') || text.contains('add goal') || text.contains('my goal')) {
      return const YansiActionIntent('goals.addGoal', requiresConfirmation: true);
    }
    if (text.contains('delete') || text.contains('remove') || text.contains('cancel') || text.contains('pay ')) {
      return const YansiActionIntent('sensitive.action', requiresConfirmation: true);
    }
    if (text.contains('budget') || text.contains('spending') || text.contains('money')) {
      return const YansiActionIntent('money.analyze');
    }
    if (text.contains('goal')) return const YansiActionIntent('goals.analyze');
    if (text.contains('task') || text.contains('work')) return const YansiActionIntent('productivity.analyze');
    if (text.contains('calendar') || text.contains('bill')) return const YansiActionIntent('calendar.analyze');
    if (text.contains('household') || text.contains('grocery')) return const YansiActionIntent('household.analyze');

    return const YansiActionIntent('conversation');
  }
}

class YansiActionIntent {
  final String action;
  final bool requiresConfirmation;

  const YansiActionIntent(this.action, {this.requiresConfirmation = false});
  const YansiActionIntent.none() : action = 'none', requiresConfirmation = false;
}
