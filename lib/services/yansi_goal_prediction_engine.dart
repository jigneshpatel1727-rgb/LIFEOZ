/// Finds goal-oriented signals and proposes the next useful step.
class YansiGoalPredictionEngine {
  const YansiGoalPredictionEngine();

  List<String> suggestNextSteps(List<Map<String, dynamic>> memories) {
    final text = memories.map((m) => m.values.join(' ')).join(' ').toLowerCase();
    final suggestions = <String>[];

    if (text.contains('goal')) {
      suggestions.add('Review the next unfinished goal milestone.');
    }
    if (text.contains('task') || text.contains('todo')) {
      suggestions.add('Check pending tasks and carry forward what remains.');
    }
    if (text.contains('expense') || text.contains('payment')) {
      suggestions.add('Review recent financial activity for useful savings opportunities.');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Observe new LifeOS activity and wait for a stronger personal signal.');
    }
    return List.unmodifiable(suggestions);
  }
}
