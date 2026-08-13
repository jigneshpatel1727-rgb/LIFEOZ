/// Normalizes routed intents into executable LifeOS core operations.
/// The adapter describes the operation; the owning core remains responsible
/// for persistence and final verification.
class YansiCoreExecutionAdapter {
  const YansiCoreExecutionAdapter();

  Map<String, dynamic> prepare({
    required String core,
    required String request,
  }) {
    final operation = _operationFor(core, request.toLowerCase());
    return {
      'core': core,
      'operation': operation,
      'request': request,
      'execution': 'delegated_to_core',
      'verificationRequired': true,
    };
  }

  String _operationFor(String core, String request) {
    switch (core) {
      case 'expenses':
        if (request.contains('delete') || request.contains('remove')) return 'delete_expense';
        return 'record_or_update_expense';
      case 'tasks':
        if (request.contains('complete') || request.contains('done')) return 'complete_task';
        return 'create_or_update_task';
      case 'goals':
        return 'update_goal_progress';
      case 'calendar':
        return 'create_or_update_event';
      case 'household':
        return 'create_or_update_shopping_item';
      default:
        return 'assist_and_route';
    }
  }
}
