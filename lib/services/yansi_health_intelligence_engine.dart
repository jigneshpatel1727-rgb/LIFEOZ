/// Normalizes permitted health/wearable observations into LifeOS signals.
/// This layer does not diagnose conditions or make medical decisions.
class YansiHealthIntelligenceEngine {
  const YansiHealthIntelligenceEngine();

  Map<String, dynamic> analyze(List<Map<String, dynamic>> observations) {
    final permitted = observations.where((item) => item['permissionGranted'] == true).toList(growable: false);
    final byType = <String, int>{};
    for (final item in permitted) {
      final type = (item['type'] ?? 'general').toString();
      byType[type] = (byType[type] ?? 0) + 1;
    }

    return {
      'observedCount': permitted.length,
      'signalTypes': Map.unmodifiable(byType),
      'source': 'user_permitted_health_data',
      'analysisMode': 'trend_only',
      'medicalDiagnosis': false,
      'requiresUserReview': true,
    };
  }
}
