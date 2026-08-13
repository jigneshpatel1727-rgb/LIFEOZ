/// Builds non-destructive learning signals from user-approved interactions.
/// It records what can improve future assistance without rewriting Yansi itself.
class YansiProactiveLearningEngine {
  const YansiProactiveLearningEngine();

  Map<String, dynamic> learn({
    required String interaction,
    required String outcome,
    String? preference,
  }) {
    return {
      'interaction': interaction.trim(),
      'outcome': outcome.trim(),
      'preference': preference?.trim(),
      'learnedAt': DateTime.now().toIso8601String(),
      'learningType': 'user_context',
    };
  }

  String guidance() =>
      'Yansi may learn from approved interactions and LifeOS history, but learning must not autonomously rewrite or deploy application code.';
}
