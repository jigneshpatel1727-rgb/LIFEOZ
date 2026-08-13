/// Chooses a safer/faster action strategy from verified historical outcomes.
class YansiAdaptiveActionIntelligence {
  const YansiAdaptiveActionIntelligence();

  Map<String, dynamic> choose({
    required List<Map<String, dynamic>> outcomes,
    required String core,
    required String operation,
  }) {
    final matching = outcomes.where((item) =>
        item['core'] == core && item['operation'] == operation).toList();
    final successes = matching.where((item) => item['success'] == true).length;
    final failures = matching.where((item) => item['success'] == false).length;

    return {
      'core': core,
      'operation': operation,
      'previousAttempts': matching.length,
      'verifiedSuccesses': successes,
      'verifiedFailures': failures,
      'strategy': failures > successes ? 'cautious_retry_or_ask' : 'standard_verified_path',
    };
  }
}
