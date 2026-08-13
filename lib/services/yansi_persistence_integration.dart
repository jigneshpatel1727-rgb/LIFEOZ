import 'lifeos_data_store.dart';
import 'yansi_core_execution_handlers.dart';

/// Integrates validated Yansi core plans with the existing local data store.
///
/// This class deliberately requires an already-approved execution decision.
/// It does not replace YansiActionExecutor and never bypasses confirmation.
class YansiPersistenceIntegration {
  final LifeOSDataStore store;
  final YansiCoreExecutionHandlers handlers;

  const YansiPersistenceIntegration(
    this.store, {
    this.handlers = const YansiCoreExecutionHandlers(),
  });

  Future<bool> persistExpense({
    required Map<String, dynamic> payload,
    required bool executionAllowed,
  }) async {
    if (!executionAllowed) return false;

    final plan = handlers.prepareExpense(payload);
    if (plan['valid'] != true) return false;

    final now = DateTime.now().toUtc().toIso8601String();
    await store.append('money', {
      'id': '${now}_${DateTime.now().microsecondsSinceEpoch}',
      'type': 'expense',
      'timestamp': now,
      ...payload,
    });
    return true;
  }

  Future<bool> persistTask({
    required Map<String, dynamic> payload,
    required bool executionAllowed,
  }) async {
    if (!executionAllowed) return false;

    final plan = handlers.prepareTask(payload);
    if (plan['valid'] != true) return false;

    final now = DateTime.now().toUtc().toIso8601String();
    await store.append('tasks', {
      'id': '${now}_${DateTime.now().microsecondsSinceEpoch}',
      'type': 'task',
      'timestamp': now,
      'completed': false,
      ...payload,
    });
    return true;
  }
}
