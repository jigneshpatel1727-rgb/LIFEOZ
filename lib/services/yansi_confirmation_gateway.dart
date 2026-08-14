/// Security boundary between Yansi intelligence and action execution.
/// The gateway validates a proposal and explicit confirmation, but never executes actions itself.
class YansiConfirmationGateway {
  const YansiConfirmationGateway();

  Map<String, dynamic> validateProposal({
    required Map<String, dynamic> proposal,
    required bool explicitConfirmation,
    required bool userAuthenticated,
  }) {
    final id = '${proposal['proposalId'] ?? ''}'.trim();
    final state = '${proposal['readiness'] ?? ''}'.trim().toLowerCase();
    final sensitive = proposal['sensitive'] == true;
    final requiresConfirmation = proposal['requiresConfirmation'] != false;

    if (id.isEmpty) return _deny('missing_proposal_id');
    if (!userAuthenticated) return _deny('user_not_authenticated');
    if (state != 'ready_to_ask') return _deny('proposal_not_ready');
    if (requiresConfirmation && !explicitConfirmation) return _deny('confirmation_required');
    if (sensitive && !explicitConfirmation) return _deny('sensitive_action_requires_confirmation');

    return {
      'allowedToDispatch': true,
      'proposalId': id,
      'reason': 'Proposal passed the confirmation boundary. A separate action executor must still perform the operation.',
    };
  }

  Map<String, dynamic> _deny(String reason) => {
        'allowedToDispatch': false,
        'reason': reason,
      };
}
