/// Converts a guarded Yansi decision into a normalized LifeOS action request.
class YansiActionAdapter {
  const YansiActionAdapter();

  Map<String, dynamic> prepare({
    required String actionType,
    required Map<String, dynamic> payload,
    required Map<String, dynamic> executionGuard,
  }) {
    final allowed = executionGuard['executionAllowed'] == true;

    return {
      'actionType': actionType,
      'payload': Map<String, dynamic>.from(payload),
      'ready': allowed,
      'executionAllowed': allowed,
      'requiresConfirmation': !allowed,
      'source': 'yansi',
    };
  }
}
