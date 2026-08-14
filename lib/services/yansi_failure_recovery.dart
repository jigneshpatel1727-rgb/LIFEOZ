/// Determines a safe recovery strategy from an action execution outcome.
/// It never retries or executes anything itself.
class YansiFailureRecovery {
  const YansiFailureRecovery();

  Map<String, dynamic> decide({
    required String action,
    required bool authorized,
    required bool executed,
    String? error,
    int priorFailures = 0,
    bool retrySafe = false,
  }) {
    if (!authorized) {
      return _result('stop', 'The action was not authorized. No retry is permitted.');
    }
    if (executed) {
      return _result('complete', 'The action completed successfully.');
    }
    if (priorFailures >= 2) {
      return _result('ask_user', 'The action has failed repeatedly. Yansi should ask the user before attempting anything else.');
    }
    if (retrySafe && priorFailures == 0) {
      return _result('retry_once', 'The failure appears recoverable and this action has not been retried yet.');
    }
    return _result('ask_user', 'The action could not be completed${error == null ? '' : ': $error'}. Yansi should explain the failure and ask what to do next.');
  }

  Map<String, dynamic> _result(String strategy, String reason) => {
        'strategy': strategy,
        'reason': reason,
        'canAutoRetry': strategy == 'retry_once',
        'requiresUserDecision': strategy == 'ask_user',
      };
}
