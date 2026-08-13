/// Safe core execution handlers for normalized Yansi requests.
///
/// This layer validates payloads and returns an execution plan. It does not
/// mutate persistent data; the existing authorization/execution guard remains
/// the final gate before a real repository write.
class YansiCoreExecutionHandlers {
  const YansiCoreExecutionHandlers();

  Map<String, dynamic> prepareExpense(Map<String, dynamic> payload) {
    final amount = payload['amount'];
    final category = (payload['category'] ?? '').toString().trim();

    return {
      'core': 'expense',
      'operation': 'add',
      'valid': amount is num && amount > 0 && category.isNotEmpty,
      'payload': Map<String, dynamic>.from(payload),
      'mutatesData': true,
      'requiresExecutionGuard': true,
    };
  }

  Map<String, dynamic> prepareTask(Map<String, dynamic> payload) {
    final title = (payload['title'] ?? '').toString().trim();

    return {
      'core': 'task',
      'operation': 'add',
      'valid': title.isNotEmpty,
      'payload': Map<String, dynamic>.from(payload),
      'mutatesData': true,
      'requiresExecutionGuard': true,
    };
  }

  Map<String, dynamic> prepare({
    required String core,
    required Map<String, dynamic> payload,
  }) {
    switch (core) {
      case 'expense':
        return prepareExpense(payload);
      case 'task':
        return prepareTask(payload);
      default:
        return {
          'core': core,
          'operation': 'unsupported',
          'valid': false,
          'payload': Map<String, dynamic>.from(payload),
          'mutatesData': false,
          'requiresExecutionGuard': true,
        };
    }
  }
}
