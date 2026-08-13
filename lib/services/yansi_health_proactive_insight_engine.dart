/// Produces cautious proactive insights from permitted health/routine signals.
class YansiHealthProactiveInsightEngine {
  const YansiHealthProactiveInsightEngine();

  List<Map<String, dynamic>> suggest({
    required List<Map<String, dynamic>> correlations,
    required bool quietHours,
  }) {
    if (quietHours) return const [];

    return correlations.map((item) {
      final healthType = item['healthType']?.toString() ?? 'health';
      final routine = item['routine']?.toString() ?? 'routine';
      return {
        'type': 'health_routine_insight',
        'message': 'A possible relationship was observed between $healthType and $routine.',
        'confidence': 'observational',
        'requiresUserReview': true,
        'medicalAdvice': false,
      };
    }).toList(growable: false);
  }
}
