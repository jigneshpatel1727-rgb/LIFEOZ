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
      return YansiActionIntent('money.addExpense', requiresConfirmation: false);
    }
    if (text.contains('add task') || text.contains('remind me')) {
      return YansiActionIntent('productivity.addTask', requiresConfirmation: false);
    }
    if (text.contains('buy ') || text.contains('shopping') || text.contains('grocery')) {
      return YansiActionIntent('household.addItem', requiresConfirmation: false);
    }
    if (text.contains('delete') || text.contains('remove') || text.contains('cancel') || text.contains('pay ')) {
      return YansiActionIntent('sensitive.action', requiresConfirmation: true);
    }
    if (text.contains('budget') || text.contains('spending') || text.contains('money')) {
      return YansiActionIntent('money.analyze');
    }
    if (text.contains('goal')) return YansiActionIntent('goals.analyze');
    if (text.contains('task') || text.contains('work')) return YansiActionIntent('productivity.analyze');
    if (text.contains('calendar') || text.contains('renewal') || text.contains('bill')) return YansiActionIntent('calendar.analyze');
    if (text.contains('household') || text.contains('grocery')) return YansiActionIntent('household.analyze');

    return const YansiActionIntent('conversation');
  }
}

class YansiActionIntent {
  final String action;
  final bool requiresConfirmation;

  const YansiActionIntent(this.action, {this.requiresConfirmation = false});
  const YansiActionIntent.none() : action = 'none', requiresConfirmation = false;
}
