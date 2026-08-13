/// Correlates permitted health/activity observations with verified routine patterns.
class YansiHealthRoutineCorrelationEngine {
  const YansiHealthRoutineCorrelationEngine();

  List<Map<String, dynamic>> correlate({
    required List<Map<String, dynamic>> healthSignals,
    required List<Map<String, dynamic>> routines,
  }) {
    final correlations = <Map<String, dynamic>>[];

    for (final health in healthSignals) {
      if (health['permissionGranted'] != true) continue;

      final healthType =
          (health['type'] ?? '').toString().toLowerCase();

      for (final routine in routines) {
        final pattern =
            (routine['pattern'] ?? '').toString().toLowerCase();

        if (healthType.isEmpty || pattern.isEmpty) continue;

        if (healthType.contains(pattern) ||
            pattern.contains(healthType)) {
          correlations.add({
            'healthType': healthType,
            'routine': pattern,
            'relationship': 'possible_routine_signal',
            'requiresUserReview': true,
          });
        }
      }
    }

    return List.unmodifiable(correlations);
  }
}
