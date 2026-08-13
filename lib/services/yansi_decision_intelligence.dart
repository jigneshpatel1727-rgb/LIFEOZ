/// Converts personal context and predictive signals into explainable options.
/// Yansi recommends; the user remains the decision maker for sensitive actions.
class YansiDecisionIntelligence {
  const YansiDecisionIntelligence();

  List<String> options({
    required List<String> priorities,
    required String situation,
  }) {
    final result = <String>[];
    final text = situation.trim();

    if (text.isNotEmpty) {
      result.add('Understand the situation using Yansi personal context.');
    }
    for (final priority in priorities.take(5)) {
      result.add('Consider: $priority');
    }
    if (result.isEmpty) {
      result.add('No strong personal signal is available yet.');
    }
    return List.unmodifiable(result);
  }

  String reasoningNote() =>
      'Recommendations are based on available LifeOS context and observed patterns; Yansi should explain the relevant context before sensitive actions.';
}
