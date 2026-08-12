/// Safety boundary for Yansi actions across the five LifeOS cores.
///
/// Read-only analysis can proceed immediately. Mutating or sensitive actions
/// require an explicit confirmation token from the UI/voice layer.
class YansiActionExecutionGuard {
  static const Set<String> _mutatingActions = {
    'add_expense',
    'delete_expense',
    'add_task',
    'complete_task',
    'delete_task',
    'add_household_item',
    'delete_household_item',
    'add_calendar_event',
    'delete_calendar_event',
    'add_goal',
    'delete_goal',
  };

  bool requiresConfirmation(String action) => _mutatingActions.contains(action);

  bool canExecute({
    required String action,
    required bool confirmed,
  }) {
    if (!requiresConfirmation(action)) return true;
    return confirmed;
  }

  String explanation(String action) {
    if (!requiresConfirmation(action)) {
      return 'This is a read-only LifeOS action.';
    }
    return 'I understood "$action". I need your confirmation before I change your LifeOS data.';
  }
}
