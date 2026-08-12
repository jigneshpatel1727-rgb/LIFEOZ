import 'lifeos_data_store.dart';
import 'yansi_action_execution_guard.dart';
import 'yansi_action_router.dart';

/// Executes the small, deterministic subset of LifeOS actions that Yansi can
/// safely perform locally. The executor never treats a natural-language
/// command as permission to mutate data without confirmation.
class YansiActionExecutor {
  final LifeOSDataStore store;
  final YansiActionExecutionGuard guard;

  const YansiActionExecutor(
    this.store, {
    this.guard = const YansiActionExecutionGuard(),
  });

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
