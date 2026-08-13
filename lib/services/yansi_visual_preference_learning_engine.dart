/// Learns presentation preferences from explicit user-approved feedback.
class YansiVisualPreferenceLearningEngine {
  const YansiVisualPreferenceLearningEngine();

  Map<String, dynamic> learn({
    required Map<String, dynamic> currentPreferences,
    required List<Map<String, dynamic>> feedback,
  }) {
    final next = Map<String, dynamic>.from(currentPreferences);

    for (final item in feedback) {
      if (item['approved'] != true) continue;

      final key = item['preference']?.toString();
      final value = item['value'];

      if (key == null || key.isEmpty || value == null) continue;

      next[key] = value;
    }

    return {
      'preferences': Map.unmodifiable(next),
      'learnedFromApprovedFeedback': true,
      'autonomousCodeChange': false,
      'userControlled': true,
    };
  }
}
