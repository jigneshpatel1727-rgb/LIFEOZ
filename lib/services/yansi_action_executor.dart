import 'lifeos_data_store.dart';
import 'yansi_action_execution_guard.dart';
import 'yansi_action_router.dart';
import 'yansi_core_execution_handlers.dart';

/// Executes deterministic LifeOS actions. Mutating actions always pass
/// through the explicit confirmation guard and core payload validation.
class YansiActionExecutor {
  final LifeOSDataStore store;
  final YansiActionExecutionGuard guard;
  final YansiCoreExecutionHandlers handlers;

  YansiActionExecutor(
    this.store, {
    YansiActionExecutionGuard? guard,
    YansiCoreExecutionHandlers? handlers,
  })  : guard = guard ?? const YansiActionExecutionGuard(),
        handlers = handlers ?? const YansiCoreExecutionHandlers();

  Future<YansiExecutionResult> execute(
    YansiActionIntent intent, {
    required bool confirmed,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async {
    final action = _guardName(intent.action);
    if (guard.requiresConfirmation(action) && !confirmed) {
      return YansiExecutionResult(
        executed: false,
        confirmationRequired: true,
        message: guard.explanation(action),
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final id = '${now}_${DateTime.now().microsecondsSinceEpoch}';

    switch (intent.action) {
      case 'money.addExpense':
        final plan = handlers.prepareExpense(data);
        if (plan['valid'] != true) {
          return const YansiExecutionResult(
            executed: false,
            message: 'I need a valid expense amount and category.',
          );
        }
        await store.append('money', {
          'id': id,
          'type': 'expense',
          'timestamp': now,
          ...data,
        });
        return const YansiExecutionResult(
          executed: true,
          message: 'Done. I added the expense to LifeOS.',
        );

      case 'productivity.addTask':
        final plan = handlers.prepareTask(data);
        if (plan['valid'] != true) {
          return const YansiExecutionResult(
            executed: false,
            message: 'I need a task title before I can add it.',
          );
        }
        await store.append('tasks', {
          'id': id,
          'type': 'task',
          'timestamp': now,
          'completed': false,
          ...data,
        });
        return const YansiExecutionResult(
          executed: true,
          message: 'Done. I added the task to LifeOS.',
        );

      case 'household.addItem':
        await store.append('household', {
          'id': id,
          'type': 'household_item',
          'timestamp': now,
          'completed': false,
          ...data,
        });
        return const YansiExecutionResult(
          executed: true,
          message: 'Done. I added it to your household list.',
        );

      case 'calendar.addEvent':
        await store.append('calendar', {
          'id': id,
          'type': 'calendar_event',
          'timestamp': now,
          ...data,
        });
        return const YansiExecutionResult(
          executed: true,
          message: 'Done. I added the event to your LifeOS calendar.',
        );

      case 'goals.addGoal':
        await store.append('goals', {
          'id': id,
          'type': 'goal',
          'timestamp': now,
          'completed': false,
          'progress': 0,
          ...data,
        });
        return const YansiExecutionResult(
          executed: true,
          message: 'Done. I added the goal to LifeOS.',
        );

      default:
        return const YansiExecutionResult(
          executed: false,
          message: 'I can analyze that, but this action is not connected yet.',
        );
    }
  }

  String _guardName(String action) {
    switch (action) {
      case 'money.addExpense':
        return 'add_expense';
      case 'productivity.addTask':
        return 'add_task';
      case 'household.addItem':
        return 'add_household_item';
      case 'calendar.addEvent':
        return 'add_calendar_event';
      case 'goals.addGoal':
        return 'add_goal';
      default:
        return action;
    }
  }
}

class YansiExecutionResult {
  final bool executed;
  final bool confirmationRequired;
  final String message;

  const YansiExecutionResult({
    required this.executed,
    this.confirmationRequired = false,
    required this.message,
  });
}
