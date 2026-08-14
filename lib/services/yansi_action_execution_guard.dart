/// Final execution guard for Yansi data-changing actions.
/// The guard is deliberately stricter than the language router: only known
/// domain mutations can cross into the executor.
class YansiActionExecutionGuard {
  const YansiActionExecutionGuard();

  static const allowedActions = <String>{
    'add_expense',
    'add_task',
    'add_household_item',
    'add_calendar_event',
    'add_goal',
  };

  static const _mutatingActions = <String>{
    ...allowedActions,
    'prioritize_tasks',
    'review_reminders',
    'analyze_spending',
    'activate_goal',
    'predict_household',
  };

  bool isAllowlisted(String action) => allowedActions.contains(action);

  bool requiresConfirmation(String action) =>
      _mutatingActions.contains(action);

  bool canExecute({
    required String action,
    required bool confirmed,
  }) {
    if (!isAllowlisted(action)) return false;
    if (!requiresConfirmation(action)) return true;
    return confirmed;
  }

  String explanation(String action) {
    if (!isAllowlisted(action)) {
      return 'This operation is not on Yansi\'s approved action allowlist.';
    }
    if (requiresConfirmation(action)) {
      return 'I prepared $action, but I need your confirmation before I make a change.';
    }
    return 'This action is read-only and does not require confirmation.';
  }

  Map<String, dynamic> check({
    required Map<String, dynamic> authorization,
    required bool explicitConfirmation,
  }) {
    final action = '${authorization['action'] ?? ''}'.trim().toLowerCase();
    final sensitive = authorization['sensitive'] == true;
    final authorized = authorization['authorized'] == true;
    final allowlisted = isAllowlisted(action);
    final permitted =
        authorized && allowlisted && (!sensitive || explicitConfirmation);

    return {
      'permitted': permitted,
      'sensitive': sensitive,
      'allowlisted': allowlisted,
      'explicitConfirmation': explicitConfirmation,
      'executionAllowed': permitted,
      'reason': permitted
          ? 'approved'
          : (!allowlisted ? 'operation_not_allowlisted' : 'confirmation_or_authorization_required'),
    };
  }
}
