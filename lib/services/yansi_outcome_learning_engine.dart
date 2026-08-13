/// Turns verified outcomes into future-learning signals.
class YansiOutcomeLearningEngine {
  const YansiOutcomeLearningEngine();

  Map<String, dynamic> learn({
    required Map<String, dynamic> outcome,
  }) {
    final success = outcome['success'] == true;
    return {
      'type': 'outcome_learning',
      'core': outcome['core'],
      'operation': outcome['operation'],
      'success': success,
      'signal': success ? 'successful_action_pattern' : 'failed_action_pattern',
      'shouldImproveFuturePlanning': true,
      'source': 'verified_execution',
    };
  }
}
