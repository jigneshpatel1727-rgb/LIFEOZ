/// Final execution guard for Yansi data-changing actions.
class YansiActionExecutionGuard {
  const YansiActionExecutionGuard();

  static const _mutatingActions = <String>{
    'add_expense',
    'add_task',
    'add_household_item',
    'add_calendar_event',
    'add_goal',
    'prioritize_tasks',
    'review_reminders',
    'analyze_spending',
    'activate_goal',
    'predict_household',
  };

  bool requiresConfirmation(String action) =>
      _mutatingActions.contains(action);

  bool canExecute({
    required String action,
    required bool confirmed,
  }) {
    if (!requiresConfirmation(action)) return true;
    return confirmed;
  }

  String explanation(String action) {
    if (requiresConfirmation(action)) {
      return 'I prepared $action, but I need your confirmation before I make a change.';
    }
    return 'This action is read-only and does not require confirmation.';
  }

  Map<String, dynamic> check({
    required Map<String, dynamic> authorization,
    required bool explicitConfirmation,
  }) {
    final sensitive = authorization['sensitive'] == true;
    final authorized = authorization['authorized'] == true;
    final permitted =
        authorized && (!sensitive || explicitConfirmation);

    return {
      'permitted': permitted,
      'sensitive': sensitive,
      'explicitConfirmation': explicitConfirmation,
      'executionAllowed': permitted,
      'reason': permitted
          ? 'approved'
          : 'confirmation_or_authorization_required',
    };
  }
}
