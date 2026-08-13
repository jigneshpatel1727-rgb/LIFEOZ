/// Converts a selected Yansi signal into a guarded action proposal.
/// This layer proposes actions; it never executes sensitive actions by itself.
class YansiActionOrchestrationEngine {
  const YansiActionOrchestrationEngine();

  Map<String, dynamic> propose({
    required Map<String, dynamic> selectedSignal,
    required bool userActive,
  }) {
    final domain = (selectedSignal['domain'] ?? 'general').toString();
    final proposal = switch (domain) {
      'calendar' => 'review_calendar_item',
      'productivity' => 'review_pending_task',
      'expense' => 'review_spending_signal',
      'goals' => 'review_goal_signal',
      'health' => 'review_health_signal',
      'web' => 'review_web_information',
      _ => 'review_personal_signal',
    };
    return {
      'proposal': proposal,
      'domain': domain,
      'userActive': userActive,
      'requiresConfirmation': true,
      'autoExecute': false,
      'guard': 'existing_action_permissions',
    };
  }
}
