/// A transparent, non-executing proposal for a future Yansi action.
/// Proposals describe intent and required authorization; they never perform work.
class YansiActionProposal {
  final String id;
  final String title;
  final String intent;
  final String reason;
  final String actionType;
  final String core;
  final List<String> affectedData;
  final bool sensitive;
  final bool requiresConfirmation;
  final String readiness;
  final DateTime createdAt;

  const YansiActionProposal({
    required this.id,
    required this.title,
    required this.intent,
    required this.reason,
    required this.actionType,
    required this.core,
    required this.affectedData,
    required this.sensitive,
    required this.requiresConfirmation,
    required this.readiness,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'intent': intent,
        'reason': reason,
        'actionType': actionType,
        'core': core,
        'affectedData': affectedData,
        'sensitive': sensitive,
        'requiresConfirmation': requiresConfirmation,
        'readiness': readiness,
        'createdAt': createdAt.toIso8601String(),
      };
}

class YansiActionProposalBuilder {
  const YansiActionProposalBuilder();

  YansiActionProposal build({
    required String id,
    required String title,
    required String intent,
    required String reason,
    required String actionType,
    required String core,
    required List<String> affectedData,
    required String readiness,
    bool sensitive = true,
  }) {
    final safeReadiness = readiness.trim().toLowerCase();
    final requiresConfirmation = sensitive || safeReadiness == 'ready_to_ask';
    return YansiActionProposal(
      id: id,
      title: title,
      intent: intent,
      reason: reason,
      actionType: actionType,
      core: core,
      affectedData: List.unmodifiable(affectedData),
      sensitive: sensitive,
      requiresConfirmation: requiresConfirmation,
      readiness: safeReadiness,
      createdAt: DateTime.now(),
    );
  }
}
