/// Tailors a guarded recommendation from fused personal and LifeOS context.
class YansiPersonalizedDecisionEngine {
  const YansiPersonalizedDecisionEngine();

  Map<String, dynamic> decide({
    required Map<String, dynamic> fusedContext,
    required Map<String, dynamic> prioritySignal,
  }) {
    final decision = (prioritySignal['decision'] ?? 'silent').toString();
    if (decision == 'silent') {
      return {
        'mode': 'silent',
        'recommendation': null,
        'requiresConfirmation': false,
      };
    }

    return {
      'mode': 'personalized',
      'recommendation': prioritySignal['selectedSignal'],
      'personalContextUsed': fusedContext['personalizationEnabled'] == true,
      'requiresConfirmation': true,
      'autoExecute': false,
    };
  }
}
