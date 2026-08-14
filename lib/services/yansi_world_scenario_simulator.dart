/// Simulates possible future world situations for reasoning and preparation.
/// It does not claim predictions are facts and never executes external actions.
class YansiWorldScenarioSimulator {
  const YansiWorldScenarioSimulator();

  List<Map<String, dynamic>> simulate({
    required List<Map<String, dynamic>> situations,
    List<Map<String, dynamic>> objectives = const [],
    int horizonHours = 24,
  }) {
    final horizon = horizonHours.clamp(1, 24 * 30);
    final scenarios = <Map<String, dynamic>>[];

    for (final situation in situations.take(12)) {
      final label = '${situation['label'] ?? situation['place'] ?? situation['destination'] ?? 'situation'}';
      final relevance = ((situation['relevance'] as num?)?.toInt() ?? 50).clamp(0, 100);
      scenarios.add({
        'scenario': 'continuation_of_$label',
        'horizonHours': horizon,
        'relevance': relevance,
        'evidence': situation,
        'status': 'possible',
        'confidence': (relevance / 100).clamp(0.0, 1.0),
        'objectiveAlignment': objectives.isNotEmpty,
        'action': 'reason_only',
      });
    }

    scenarios.sort((a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int));
    return scenarios.take(12).toList();
  }

  Map<String, dynamic> compare({
    required List<Map<String, dynamic>> scenarios,
  }) {
    if (scenarios.isEmpty) {
      return {
        'mode': 'continue_observing',
        'scenarios': const [],
        'certainty': 'developing',
      };
    }
    final ranked = [...scenarios]..sort((a, b) =>
        ((b['relevance'] as num?)?.toInt() ?? 0).compareTo((a['relevance'] as num?)?.toInt() ?? 0));
    return {
      'mode': 'compare_possible_futures',
      'scenarios': ranked.take(8).toList(),
      'leadingScenario': ranked.first,
      'certainty': 'context_dependent',
      'noScenarioIsPresentedAsCertain': true,
    };
  }
}
