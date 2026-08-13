/// Gives Yansi a consistent recovery path when an operation fails or is uncertain.
class YansiFailureRecoveryEngine {
  const YansiFailureRecoveryEngine();

  Map<String, dynamic> recover({
    required String operation,
    required String reason,
    bool retryable = true,
  }) {
    return {
      'operation': operation,
      'reason': reason,
      'retryable': retryable,
      'state': retryable ? 'retry_or_ask' : 'blocked',
      'message': retryable
          ? 'The operation was not confirmed. Yansi should retry safely or ask the user.'
          : 'The operation cannot continue safely without resolving the issue.',
    };
  }
}
